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
- **Offline mode:** sau mỗi lần sync thành công, `inventory_provider_offline.dart` lưu snapshot (box, item, loan, category) vào `SharedPreferences` qua `lib/services/offline_store.dart`, khóa theo user. Khi `fetchAllData` không chạm được server (lỗi không phải `ApiException`), app nạp snapshot, đặt `isOffline`/`isConnected=false` và không auto-seed. Chỉ `updateItemQuantity` (consume/restock) được xếp hàng khi offline (giá trị tuyệt đối, giữ giá trị mới nhất mỗi item) và phát lại ở đầu lần sync kế tiếp; các thao tác khác vẫn cần mạng.
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
- Theme: font Inter (`google_fonts`), màu chính `#18181B`, nền `#F8F9FA`, card bo góc 24, input filled `#F4F4F6`. Dùng `Theme.of(context)` thay vì hardcode màu mới; màu status lấy từ `ItemStatus.color`, icon vị trí từ `StorageType.icon`.
- Form field dùng `AppFormField`; ảnh dùng `AppImageView`; breadcrumb dùng `BreadcrumbBar`; chọn/di chuyển vị trí dùng `LocationPickerSheet`, `MoveItemSheet`, `MoveLocationDialog`.
- Text hiển thị trong app là tiếng Anh.
- Các file screen rất lớn (1.5k–2k dòng): khi sửa, tách widget con mới vào `lib/widgets/` thay vì làm file phình thêm.

## Thư viện chính

`provider`, `http`, `shared_preferences`, `mobile_scanner` (quét QR/barcode), `qr_flutter`, `pdf` + `printing` (xuất tem/PDF), `image_picker`, `google_sign_in`, `flutter_slidable`, `intl`, `uuid`.

## Test

- Widget test bọc screen trong `ChangeNotifierProvider<InventoryProvider>` + `MaterialApp`; gọi `SharedPreferences.setMockInitialValues({})` trước.
- Model test kiểm tra round-trip `fromJson`/`toJson` (xem `attributes_test.dart`, `consumable_and_status_test.dart`).
- Không sửa `build/`, `ios/Pods`, file generated của platform trừ khi thật sự cần (vd. Info.plist quyền camera, URL scheme Google Sign-In).
