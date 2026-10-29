# Frontend — Flutter app (package `inventory`)

Rule chung BE↔FE và business rules: [../CLAUDE.md](../CLAUDE.md). Đặc tả API chuẩn nằm ở `../BE_GoLang/AGENTS.md`; file `AGENtS.md` trong thư mục này là bản cũ, đừng dựa vào nó.

## Lệnh thường dùng

```bash
flutter pub get
flutter analyze                     # flutter_lints; phải sạch trước khi kết thúc
flutter test                        # toàn bộ test
flutter test test/attributes_test.dart
flutter run --dart-define=API_BASE_URL=http://localhost:8080
./run_ios_release.sh [API_URL] [DEVICE_ID]   # release trên iPhone thật
```
`test/api_integration_test.dart` có nhóm "Backend Live API Integration" gọi backend thật tại `localhost:8080`; nhóm này bị skip mặc định, bật bằng `flutter test --dart-define=LIVE_API=true` khi BE đang chạy.

## Kiến trúc

```
lib/main.dart                       MaterialApp + theme, MultiProvider
lib/models/inventory_models.dart    Toàn bộ model: Box, Item, LendingRecord, User, InventoryHealth,
                                    ScanLookupResult, enum StorageType/ItemStatus, CategoryHelper
lib/services/api_service.dart       HTTP client duy nhất (package http), session, base URL
lib/providers/inventory_provider.dart  ChangeNotifier duy nhất giữ state toàn app
lib/screens/                        Màn hình (*_screen.dart), điều hướng bằng Navigator.push + MaterialPageRoute
lib/widgets/                        Widget/bottom sheet tái sử dụng
lib/utils/formatters.dart           AppFormatters.formatCurrency / formatQuantity
```

- `InventoryProvider` chia file bằng `part` + `extension`: state/field, khởi tạo và sync ở `inventory_provider.dart`; từng module ở `inventory_provider_{settings,boxes,items,lending,alerts,reports,trash,offline}.dart`. Extension cùng library nên dùng được field private; gọi `_notify()` thay vì `notifyListeners()` (tránh cảnh báo protected member). Logic mới đặt vào đúng module, đừng làm file chính phình thêm.
- **Offline mode:** sau mỗi lần sync thành công, `inventory_provider_offline.dart` lưu snapshot (box, item, loan, category) qua `lib/services/offline_store.dart`, khóa theo user: snapshot là file JSON trong thư mục app support (`path_provider`; ghi gộp — chỉ bản mới nhất, atomic tmp+rename, trên 500 bản ghi thì encode ở isolate khác; không có thư mục thì rơi về SharedPreferences, và snapshot cũ trong SharedPreferences vẫn đọc được), hàng đợi/failed ops vẫn ở SharedPreferences. Test widget cần `OfflineStore.directoryProvider = () async => null`. Test flush có `InventoryProvider(api: FakeApi())` (xem `test/offline_flush_test.dart`). **Cache-first:** `_initialize` nạp snapshot (`_restoreFromCache`) ngay sau `ApiService.init()`, trước mọi request mạng, rồi thăm dò `/health` (timeout 3s, `_probeServerNow`); không tới được server thì `_goOffline()` và bỏ qua chuỗi request 15s (sóng yếu không được làm app trống). `fetchAllData` cũng thăm dò trước. Boxes, items và loans được tải vào biến tạm và chỉ thay list + ghi snapshot khi **cả ba** thành công: lỗi mạng giữa chừng → `_goOffline()` (giữ cache), lỗi khác (4xx/parse) → giữ nguyên dữ liệu, không ghi snapshot, không auto-seed. Không bao giờ ghi snapshot từ dữ liệu tải dở. Không có phiên Google giả: `loginWithGoogle` lỗi thì ném lỗi. Mọi mutation trong provider đi qua `_commit(PendingOp, call)`: gọi API, nếu mất mạng (hoặc còn thay đổi cũ đang chờ, để giữ thứ tự) thì xếp hàng `PendingOp` và coi như thành công. Hàng đợi phát lại theo thứ tự ở đầu `fetchAllData`/khi `_probeServer` thấy server sống lại, mỗi lần chỉ một lượt flush (`_flushing`), op xong thì xoá theo `id` (không ghi đè cả hàng đợi). Phân loại lỗi ở `lib/services/sync_policy.dart`: mất mạng/timeout/5xx/408/429 → giữ và dừng; 401 → dừng, giữ hàng đợi, `ApiService.onUnauthorized` đưa user về đăng nhập (`SessionGuard`); 4xx nghiệp vụ → bỏ op (409 của `updateItem`/`updateBox` được đưa vào danh sách `failedOps` để user chọn Keep mine/Discard); op hỏng (lỗi parse/cast) thử tối đa 3 lần rồi vào `failedOps`. Số lượng offline xếp hàng dạng `adjustQuantity` (delta). `updateItem`/`updateBox` khi phát lại gửi `updatedAt` làm phiên bản gốc (409 nếu server đã đổi). `logout()` trả `false` nếu còn thay đổi chưa đồng bộ (UI hỏi rồi gọi `logout(force: true)`), và xoá snapshot + hàng đợi của user. ID của box/item/loan do client sinh và gửi kèm `id` khi tạo (BE idempotent) nên không cần ánh xạ ID tạm. **Tự đồng bộ:** `AutoSync` (`lib/widgets/auto_sync.dart`, bọc trong `MaterialApp.builder`) gọi `onAppResumed()` khi app quay lại foreground và mỗi 30s (`startAutoSync`) — chỉ sync khi đang offline hoặc còn thay đổi chờ. **Cài đặt** (tiền tệ, đơn vị, ngày cảnh báo...) đi qua `_saveSetting` → `_commit('updateSettings')` và được cache trong `OfflineStore.saveSettings` để mở app offline vẫn đúng. `fetchAllData` tải boxes/items/loans song song; loans = active + overdue + một trang `GET /lending/history` (đã trả), không còn N request theo item. `adjustQuantity` mang theo `key` (idempotency) dùng chung cho lần gọi trực tiếp và lần phát lại. Thêm mutation mới: dùng `_commit` và thêm case tương ứng vào `_applyPending`.
- **Một provider duy nhất** `InventoryProvider`. UI đọc qua `context.watch/read<InventoryProvider>()` hoặc `Consumer`. Không thêm state-management lib khác.
- UI **không gọi `ApiService` trực tiếp** — đi qua method của provider (provider expose `api` nhưng chỉ dùng cho trường hợp đặc biệt đã có sẵn).
- Mutation trong provider theo mẫu **optimistic update**: sửa list local → `notifyListeners()` → gọi API → thay bằng dữ liệu server → trả `bool` thành công; lỗi thì `debugPrint` và trả `false` để UI báo lỗi.
- `ApiService`: base URL ưu tiên `--dart-define=API_BASE_URL` > URL lưu trong `SharedPreferences` (đổi được ở Settings) > mặc định (`localhost`, Android emulator `10.0.2.2`). Token + user lưu trong `flutter_secure_storage`. Lỗi backend ném `ApiException(statusCode, code, message)`.
- **Không có dữ liệu mẫu:** tài khoản mới để trống, không có seed (đã xoá `inventory_provider_seed.dart` và nút seed ở Settings). `fetchAllData` không bao giờ tự tạo dữ liệu. Khi chưa có vị trí nào, Home hiện `FirstRoomsCard` (chọn nhanh các phòng thường gặp, tạo hàng loạt bằng `addBox`); các danh sách trống dùng nút hành động (`EmptyStateCard`/nút "Thêm món đồ đầu tiên").
- **Thêm nhanh:** `startAddItemFlow(context)` (`lib/widgets/add_item_flow.dart`) chọn vị trí (gợi ý nơi dùng gần nhất) rồi mở form; chưa có vị trí thì đi tạo vị trí. FAB "+" ở Home và các nút "Add item" đều dùng nó. Form item: tên/số lượng/vị trí ở đầu, phần còn lại nằm trong "Chi tiết thêm" (mở sẵn khi sửa), danh mục mặc định là danh mục dùng gần nhất, có nút quét mã vạch, và `PopScope` hỏi trước khi thoát nếu chưa lưu.
- **Mọi mutation phải chờ kết quả:** UI `await` provider rồi mới báo thành công; provider dùng `_commitOrRollback(op, call, restore)` để hoàn tác thay đổi lạc quan khi server từ chối (lỗi 409 thì `_commit` tự tải lại dữ liệu nên không hoàn tác). Màn lưu thất bại thì ở lại, giữ nguyên dữ liệu đã nhập.
- **Cho mượn/trả:** `LendItemSheet.show(context, initialItem: item)` (`lib/widgets/lend_item_sheet.dart`); mở từ item thì item đã chọn sẵn, từ màn Lending thì chọn trong danh sách có ô tìm kiếm. Trả đồ luôn qua `confirmAndReturnLoan` (có hộp xác nhận).
- **Menu hành động:** nhấn giữ item/vị trí mở `showItemActionsSheet` / `showBoxActionsSheet` (`lib/widgets/item_box_actions.dart`); vuốt chỉ là lối tắt.
- **Breadcrumb:** bấm cấp trên thì quay lại màn đã mở (`OpenBoxRoutes` trong `box_details_screen.dart` theo dõi các màn box đang mở) hoặc thay thế màn hiện tại, không chồng thêm màn.
- **Tìm kiếm không dấu:** mọi so khớp văn bản người dùng gõ đi qua `normalizeVi`/`containsNormalized` (`lib/utils/text_normalize.dart`), khớp với hàm SQL `f_unaccent_vi` ở BE. Ngày hiển thị qua `formatDate(context, d)` (`lib/utils/date_format.dart`) để theo locale, không dùng `DateFormat('MMM dd, yyyy')`.
- **Không có guest mode:** backend không có user ẩn danh, mọi API (trừ auth/health) cần JWT thật nên đã gỡ "Continue as Guest".
- `deleteBox` mặc định `cascade=false` (server trả 409 nếu box còn nội dung); UI đã xác nhận nên truyền `cascade: true`. `deleteBox`/`deleteItem` rollback state local khi API lỗi.

## Model & JSON

- Mọi model có `fromJson` / `toJson` / `copyWith` viết tay (không dùng codegen như json_serializable/freezed).
- Key JSON là camelCase khớp backend. Enum map bằng `.name` (`inUse`, `drawer`...).
- Ngày (`purchaseDate`, `expiryDate`, `warrantyExpiryDate`) là `DateTime?` ở FE, gửi dạng `YYYY-MM-DD` (ngày lịch local, `ApiService._dateOnly`); backend lưu chuỗi ngày. Xoá `minQuantity` được báo bằng `clearMinQuantity: true` trong `updateItem`.
- Thêm field mới: cập nhật constructor, `fromJson`, `toJson`, `copyWith`, payload trong `createItem`/`updateItem` của `ApiService`, và backend tương ứng.
- Logic tính toán dẫn xuất nằm trong model (`isExpired`, `isLowStock`, `daysUntilExpiry`...), không rải trong widget.

## UI conventions

- Màu chữ phụ (`textSecondary`, `textMuted`) phải đạt tương phản WCAG AA (4,5:1) trên `background/surface/fill` ở cả hai theme; `test/contrast_test.dart` kiểm tra.
- Nhãn trạng thái, đếm số lượng, ngày... phải qua l10n (có plural bằng ICU), không ghép chuỗi tiếng Anh trong code.
- Dùng `AppFeedback.showSuccess/showError/showWarning/showInfo` cho toast và `AppFeedback.showConfirmDialog` cho xác nhận — không gọi `ScaffoldMessenger`/`showDialog` thô.
- Hiển thị tiền/số lượng qua `provider.formatPrice()` / `provider.formatQty()` (theo currency & unit trong settings).
- Theme: `lib/theme/app_theme.dart` — `buildAppTheme(Brightness)` + `AppColors` (ThemeExtension: background, surface, fill, border, textPrimary/Secondary/Muted; lấy bằng `AppColors.of(context)`). Màu mới **không hardcode** `Color(0x…)`, dùng `AppColors`/`Theme.of(context)`. Dark mode đã hỗ trợ toàn app (mặc định vẫn là Light, đổi ở Settings); màn mới phải dùng `context.colors` để không vỡ dark. Màn scanner (camera) giữ nền tối theo thiết kế; splash dùng nền sáng như phần còn lại. Font Plus Jakarta Sans (và Inter cho PDF) được bundle trong `assets/google_fonts/` (`GoogleFonts.config.allowRuntimeFetching = false`, không tải font lúc chạy). Màu status lấy từ `ItemStatus.color`, icon vị trí từ `StorageType.icon`.
- **Phong cách soft/neo-morphic:** nền `#F7F8FA`, card trắng bo 24px + bóng mềm `context.colors.cardShadow` (không viền cứng), màu nhấn lime `context.colors.accent` (+ `onAccent` cho nội dung trên nó; `primary` vẫn là màu tối cho nút chính). Màu pastel cố định cho tag/progress nằm ở `AppTones` (coral, amber, matcha, sky, lilac...). Widget dựng sẵn ở `lib/widgets/soft_ui.dart`: `SoftCard`, `SoftChip` (status/tag), `SoftFilterChip`, `SoftBar`, `SoftRing`, `SoftIconTile`, `SoftSearchField`. Trạng thái ưu tiên chip màu / thanh tiến độ hơn là chữ thuần; mục có chi tiết con thì có chevron `>` ở cuối.
- **Icon:** dùng `AppIcon(Icons.xxx)` (`lib/widgets/app_icon.dart`) thay cho `Icon` — vẽ SVG tự thiết kế (nét 2.2, bo tròn, mũi tên một ngạnh) cho mọi glyph đã khai báo, glyph chưa có thì rơi về font Material. Thêm glyph mới: thêm một dòng `g([Icons.x], "<path .../>")` trong file đó (lưới 24, `currentColor`); `test/app_icon_test.dart` kiểm tra mọi SVG parse được. Trong file `part of` không import được — import ở file chủ.
- **Bottom nav:** Home/Box/Item/Setting + nút quét QR ở giữa (tối, icon lime) + nút thêm nhanh "+" (lime) cạnh thanh nav để vừa tầm ngón cái; không còn FAB riêng.
- Xoá item/box là chuyển vào Trash (khôi phục trong 30 ngày): dùng `TrashActions.confirm` + `TrashActions.showMoved` (toast có Undo), không viết lại câu chữ "cannot be undone".
- Lỗi hiển thị cho người dùng đi qua `friendlyError(e)` (`lib/utils/friendly_error.dart`); không in `$e`/`toString()` của exception lên UI, log bằng `debugPrint`.
- Danh sách cuộn dữ liệu từ server bọc bằng `AppRefresh` (pull-to-refresh → `fetchAllData`). Trạng thái offline/hàng đợi hiển thị toàn app bởi `SyncStatusBar` (bọc trong `MaterialApp.builder`), không tự làm banner riêng ở từng màn.
- Truy cập: vùng chạm tuỳ biến dùng `Tappable` (`lib/widgets/tappable.dart`, có `semanticLabel`) thay vì `GestureDetector` trần; mọi `IconButton` phải có `tooltip`.
- Form field dùng `AppFormField`; ảnh dùng `AppImageView`; breadcrumb dùng `BreadcrumbBar`; chọn/di chuyển vị trí dùng `LocationPickerSheet`, `MoveItemSheet`, `MoveLocationDialog`.
- Text hiển thị: app hỗ trợ **en + vi** qua gen-l10n (`l10n.yaml`, ARB ở `lib/l10n/app_en.arb` là template, `app_vi.arb`; dùng `AppLocalizations.of(context)`, import `../l10n/app_localizations.dart`; `flutter pub get`/`flutter gen-l10n` sinh code). Chuỗi mới phải thêm vào cả hai ARB. Toàn bộ UI đã localize: widget dùng `context.l10n.xxx` (`lib/l10n/l10n_ext.dart`); code không có context (provider, model, `friendlyError`) dùng `AppL10n.current.xxx` (đồng bộ ở `MaterialApp.builder`, không tự rebuild khi đổi ngôn ngữ). Không hardcode chuỗi hiển thị; `test/l10n_parity_test.dart` kiểm tra en/vi khớp key + placeholder. Ngoại lệ giữ tiếng Anh: tên danh mục/đơn vị mặc định, gợi ý thuộc tính, chuỗi kỹ thuật/log. Widget test dùng `MaterialApp` phải khai báo `localizationsDelegates: AppLocalizations.localizationsDelegates`.
- Các file screen rất lớn (1.5k–2k dòng): khi sửa, tách widget con mới vào `lib/widgets/` thay vì làm file phình thêm.

## Thư viện chính

`provider`, `http`, `shared_preferences`, `mobile_scanner` (quét QR/barcode), `qr_flutter`, `pdf` + `printing` (xuất tem/PDF), `image_picker`, `google_sign_in`, `flutter_slidable`, `intl`, `uuid`.

## Test

- Widget test bọc screen trong `ChangeNotifierProvider<InventoryProvider>` + `MaterialApp`; gọi `SharedPreferences.setMockInitialValues({})` trước.
- Model test kiểm tra round-trip `fromJson`/`toJson` (xem `attributes_test.dart`, `consumable_and_status_test.dart`).
- Không sửa `build/`, `ios/Pods`, file generated của platform trừ khi thật sự cần (vd. Info.plist quyền camera, URL scheme Google Sign-In).
