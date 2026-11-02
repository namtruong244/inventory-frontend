# Smart Inventory — Flutter app

App mobile (iOS/Android) quản lý đồ đạc và tài sản cá nhân: sắp xếp theo cây vị trí lưu trữ (Room → Cabinet → Shelf → Box → Drawer), theo dõi tồn kho, cho mượn/trả, quét QR/barcode, cảnh báo hết hạn/bảo hành và in tem QR/barcode ra PDF.

Backend là REST API Go nằm ở [`../BE_GoLang`](../BE_GoLang). Đặc tả API chuẩn: [`../BE_GoLang/AGENTS.md`](../BE_GoLang/AGENTS.md).

## Tính năng

- **Vị trí lưu trữ dạng cây** — tạo, di chuyển, breadcrumb, in tem QR cho từng vị trí.
- **Vật phẩm** — thông số động (custom attributes), ảnh, danh mục, ngưỡng tồn kho riêng (`minQuantity`), trạng thái `stored | inUse | lent | broken | disposed`.
- **Mượn/trả** — theo dõi người mượn, hạn trả, cảnh báo quá hạn.
- **Quét mã** — camera hoặc ảnh trong thư viện; khớp tem vị trí, barcode, serial number.
- **Cảnh báo & báo cáo** — sắp hết hàng, hết hạn, hết bảo hành; báo cáo tồn kho dạng văn bản (sao chép được).
- **Tem QR/barcode** — xuất PDF để in dán lên vị trí lưu trữ (chưa hỗ trợ tem cho vật phẩm).
- **Thùng rác** — khôi phục item/vị trí đã xoá trong 30 ngày.
- **Offline-first** — dùng được khi mất mạng; thay đổi được xếp hàng và tự đồng bộ khi có mạng lại.
- **Đăng nhập** email/mật khẩu hoặc Google; giao diện **tiếng Anh + tiếng Việt**, light/dark mode.

## Yêu cầu

- Flutter SDK có Dart `^3.13.4`
- Xcode (iOS) và/hoặc Android Studio (Android)
- Backend đang chạy (local hoặc server) — xem [`../BE_GoLang`](../BE_GoLang)

## Chạy app

Cần hai terminal: một chạy backend, một chạy app.

```bash
# Terminal 1 — backend (từ thư mục FE_Flutter)
cd ../BE_GoLang
cp .env.example .env     # tuỳ chọn, chỉ lần đầu; không có .env thì backend dùng cấu hình dev mặc định
make db-up && make run   # API tại http://localhost:8080, chạy foreground

# Terminal 2 — app (từ thư mục FE_Flutter)
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

**Base URL của API** được chọn theo thứ tự ưu tiên:

1. `--dart-define=API_BASE_URL=...` lúc build
2. URL đã lưu trong màn **Settings** của app
3. Mặc định: `http://localhost:8080`; trên **mọi thiết bị Android** là `http://10.0.2.2:8080` (chỉ đúng với emulator)

Điện thoại Android thật không tới được `10.0.2.2`: truyền IP LAN của máy chạy backend, ví dụ `--dart-define=API_BASE_URL=http://192.168.1.10:8080`, hoặc đổi URL trong Settings.

**iPhone thật (release):**

```bash
./run_ios_release.sh                          # tự dò IP LAN của Mac và iPhone đang cắm
./run_ios_release.sh <API_URL>                # chỉ định backend
./run_ios_release.sh <API_URL> <DEVICE_ID>    # chỉ định cả thiết bị
```

## Phát triển

```bash
flutter analyze                     # phải sạch trước khi commit
flutter test                        # unit + widget test
flutter test test/attributes_test.dart
flutter test --dart-define=LIVE_API=true   # bật thêm nhóm test gọi backend thật tại localhost:8080
flutter gen-l10n                    # sinh lại code l10n sau khi sửa file .arb
```

**E2E (Maestro):** flow nằm trong [`.maestro/`](.maestro), kế hoạch và tiến độ ở [`E2E_TEST_PLAN.md`](E2E_TEST_PLAN.md).

```bash
scripts/run_e2e.sh [android|ios] smoke   # tự bật backend, build với E2E=true, chạy Maestro
```

Hiện chỉ có suite `smoke`; suite `full` (F1–F15) chưa làm, xem tiến độ trong `E2E_TEST_PLAN.md`.

## Cấu trúc thư mục

```
lib/
├── main.dart                 MaterialApp, theme, MultiProvider
├── models/                   Toàn bộ model + fromJson/toJson/copyWith viết tay
├── services/
│   ├── api_service.dart      HTTP client duy nhất, phiên đăng nhập, base URL
│   ├── offline_store.dart    Snapshot dữ liệu và hàng đợi offline
│   └── sync_policy.dart      Phân loại lỗi khi đồng bộ
├── providers/                InventoryProvider (một ChangeNotifier duy nhất, chia module bằng part/extension)
├── screens/                  Các màn hình
├── widgets/                  Widget, bottom sheet dùng chung (soft UI, AppIcon, ...)
├── theme/app_theme.dart      Theme light/dark + AppColors
├── l10n/                     ARB en/vi và code sinh ra
└── utils/                    Định dạng, chuẩn hoá tiếng Việt không dấu, friendlyError
assets/google_fonts/          Font được bundle (không tải lúc chạy)
design/                       File thiết kế (pen.dev) — xem DESIGN_BRIEF.md
.maestro/, scripts/           Test E2E
openapi.yaml                  OpenAPI spec tham khảo
```

## Thư viện chính

`provider` · `http` · `shared_preferences` · `flutter_secure_storage` · `path_provider` · `mobile_scanner` · `qr_flutter` · `pdf` + `printing` · `image_picker` · `google_sign_in` · `google_fonts` · `flutter_svg` · `flutter_slidable` · `intl` · `uuid`

## Tài liệu liên quan

- [`CLAUDE.md`](CLAUDE.md) — quy ước code, kiến trúc chi tiết (offline sync, UI, l10n, test)
- [`../CLAUDE.md`](../CLAUDE.md) — hợp đồng API giữa BE và FE, business rules
- [`DESIGN_BRIEF.md`](DESIGN_BRIEF.md) — định hướng thiết kế
- [`../BE_GoLang/AGENTS.md`](../BE_GoLang/AGENTS.md) — đặc tả API chuẩn (schema, endpoint, business rules)
