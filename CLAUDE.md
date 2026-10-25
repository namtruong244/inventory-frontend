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

- `InventoryProvider` chia file bằng `part` + `extension`: state/field, khởi tạo và sync ở `inventory_provider.dart`; từng module ở `inventory_provider_{settings,boxes,items,lending,seed,alerts,reports}.dart`. Extension cùng library nên dùng được field private; gọi `_notify()` thay vì `notifyListeners()` (tránh cảnh báo protected member). Logic mới đặt vào đúng module, đừng làm file chính phình thêm.
- **Offline mode:** sau mỗi lần sync thành công, `inventory_provider_offline.dart` lưu snapshot (box, item, loan, category) qua `lib/services/offline_store.dart`, khóa theo user: snapshot là file JSON trong thư mục app support (`path_provider`; ghi gộp — chỉ bản mới nhất, atomic tmp+rename, trên 500 bản ghi thì encode ở isolate khác; không có thư mục thì rơi về SharedPreferences, và snapshot cũ trong SharedPreferences vẫn đọc được), hàng đợi/failed ops vẫn ở SharedPreferences. Test widget cần `OfflineStore.directoryProvider = () async => null`. Test flush có `InventoryProvider(api: FakeApi())` (xem `test/offline_flush_test.dart`). Khi `fetchAllData` không chạm được server (lỗi không phải `ApiException`), app nạp snapshot, đặt `isOffline`/`isConnected=false` và không auto-seed. Mọi mutation trong provider đi qua `_commit(PendingOp, call)`: gọi API, nếu mất mạng (hoặc còn thay đổi cũ đang chờ, để giữ thứ tự) thì xếp hàng `PendingOp` và coi như thành công. Hàng đợi phát lại theo thứ tự ở đầu `fetchAllData`/khi `_probeServer` thấy server sống lại, mỗi lần chỉ một lượt flush (`_flushing`), op xong thì xoá theo `id` (không ghi đè cả hàng đợi). Phân loại lỗi ở `lib/services/sync_policy.dart`: mất mạng/timeout/5xx/408/429 → giữ và dừng; 401 → dừng, giữ hàng đợi, `ApiService.onUnauthorized` đưa user về đăng nhập (`SessionGuard`); 4xx nghiệp vụ → bỏ op (409 của `updateItem`/`updateBox` được đưa vào danh sách `failedOps` để user chọn Keep mine/Discard); op hỏng (lỗi parse/cast) thử tối đa 3 lần rồi vào `failedOps`. Số lượng offline xếp hàng dạng `adjustQuantity` (delta). `updateItem`/`updateBox` khi phát lại gửi `updatedAt` làm phiên bản gốc (409 nếu server đã đổi). `logout()` trả `false` nếu còn thay đổi chưa đồng bộ (UI hỏi rồi gọi `logout(force: true)`), và xoá snapshot + hàng đợi của user. ID của box/item/loan do client sinh và gửi kèm `id` khi tạo (BE idempotent) nên không cần ánh xạ ID tạm. Thêm mutation mới: dùng `_commit` và thêm case tương ứng vào `_applyPending`.
- **Một provider duy nhất** `InventoryProvider`. UI đọc qua `context.watch/read<InventoryProvider>()` hoặc `Consumer`. Không thêm state-management lib khác.
- UI **không gọi `ApiService` trực tiếp** — đi qua method của provider (provider expose `api` nhưng chỉ dùng cho trường hợp đặc biệt đã có sẵn).
- Mutation trong provider theo mẫu **optimistic update**: sửa list local → `notifyListeners()` → gọi API → thay bằng dữ liệu server → trả `bool` thành công; lỗi thì `debugPrint` và trả `false` để UI báo lỗi.
- `ApiService`: base URL ưu tiên `--dart-define=API_BASE_URL` > URL lưu trong `SharedPreferences` (đổi được ở Settings) > mặc định (`localhost`, Android emulator `10.0.2.2`). Token + user lưu trong `SharedPreferences`. Lỗi backend ném `ApiException(statusCode, code, message)`.
- **Không có guest mode:** backend không có user ẩn danh, mọi API (trừ auth/health) cần JWT thật nên đã gỡ "Continue as Guest".
- `deleteBox` mặc định `cascade=false` (server trả 409 nếu box còn nội dung); UI đã xác nhận nên truyền `cascade: true`. `deleteBox`/`deleteItem` rollback state local khi API lỗi.

## Model & JSON

- Mọi model có `fromJson` / `toJson` / `copyWith` viết tay (không dùng codegen như json_serializable/freezed).
- Key JSON là camelCase khớp backend. Enum map bằng `.name` (`inUse`, `drawer`...).
- Ngày (`purchaseDate`, `expiryDate`, `warrantyExpiryDate`) là `DateTime?` ở FE, gửi dạng `YYYY-MM-DD` (ngày lịch local, `ApiService._dateOnly`); backend lưu chuỗi ngày. Xoá `minQuantity` được báo bằng `clearMinQuantity: true` trong `updateItem`.
- Thêm field mới: cập nhật constructor, `fromJson`, `toJson`, `copyWith`, payload trong `createItem`/`updateItem` của `ApiService`, và backend tương ứng.
- Logic tính toán dẫn xuất nằm trong model (`isExpired`, `isLowStock`, `daysUntilExpiry`...), không rải trong widget.

## UI conventions

- Dùng `AppFeedback.showSuccess/showError/showWarning/showInfo` cho toast và `AppFeedback.showConfirmDialog` cho xác nhận — không gọi `ScaffoldMessenger`/`showDialog` thô.
- Hiển thị tiền/số lượng qua `provider.formatPrice()` / `provider.formatQty()` (theo currency & unit trong settings).
- Theme: `lib/theme/app_theme.dart` — `buildAppTheme(Brightness)` + `AppColors` (ThemeExtension: background, surface, fill, border, textPrimary/Secondary/Muted; lấy bằng `AppColors.of(context)`). Màu mới **không hardcode** `Color(0x…)`, dùng `AppColors`/`Theme.of(context)`. Dark mode đã hỗ trợ toàn app (mặc định vẫn là Light, đổi ở Settings); màn mới phải dùng `context.colors` để không vỡ dark. Màn splash/scanner tối theo thiết kế. Font Inter được bundle trong `assets/google_fonts/` (`GoogleFonts.config.allowRuntimeFetching = false`, không tải font lúc chạy). Màu status lấy từ `ItemStatus.color`, icon vị trí từ `StorageType.icon`.
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
