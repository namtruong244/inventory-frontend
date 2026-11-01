# Kế hoạch test E2E bằng Maestro

Mục tiêu: tự động test toàn bộ luồng chính của app trên Android emulator / iOS simulator, chạy với backend local (`BE_GoLang`).

## Tiến độ

> Cập nhật lần cuối: 2026-10-30
> Trạng thái: ⬜ Chưa làm · 🟡 Đang làm · ✅ Xong · ⏭️ Bỏ qua

### Tổng quan theo giai đoạn

| Giai đoạn | Nội dung | Trạng thái | Ghi chú |
| :--- | :--- | :--- | :--- |
| 1 | Bước 0 (id cho login, bottom nav, form box/item) + `seed.js` + subflows + `run_e2e.sh`, chạy được S1–S2 | ✅ | S1–S2 pass trên iOS simulator (iPhone 16), ~2m45s |
| 2 | S3–S5 + id còn lại → smoke suite ổn định (~5 phút) | ⬜ | |
| 3 | F1–F10 → phủ business rules cốt lõi | ⬜ | |
| 4 | F11–F15 → full suite hoàn chỉnh | ⬜ | |
| 5 | GitHub Actions chạy smoke cho mỗi PR (tùy chọn) | ⬜ | |

### Hạ tầng

- [x] Widget helper `e2eId(id, child)` bọc `Semantics(identifier:)`
- [x] Gắn id: màn login
- [x] Gắn id: bottom nav (Home/Box/Item/Setting, nút quét, nút "+")
- [x] Gắn id: form box / form item
- [ ] Gắn id: item details (lend, return, move, stock +/-, delete)
- [ ] Gắn id: Settings, Scan (nút chọn ảnh), Alerts, Trash, Lending tracker
- [x] Cờ `--dart-define=E2E=true` (`kE2E` trong `lib/utils/e2e.dart`; chưa có animation lặp cần tắt)
- [x] `.maestro/config.yaml`
- [x] `.maestro/scripts/seed.js` (đăng ký user, tạo box/item qua API)
- [ ] Subflows: `login` ✅, `logout` ✅, `create_box` ✅, `open_tab` ✅, `fresh_start` ✅, `dismiss_keyboard` ✅, `create_item` ⬜, `scan_image` ⬜
- [ ] Script sinh ảnh QR/barcode (từ label/barcode do `seed.js` tạo) để nạp bằng `addMedia`
- [x] `scripts/run_e2e.sh` (backend → build → install → maestro → teardown)

### Flows

| # | Flow | Suite | Android | iOS | Ghi chú |
| :--- | :--- | :--- | :--- | :--- | :--- |
| S1 | `auth_register_login` | smoke | ⬜ | ✅ | |
| S2 | `first_run` | smoke | ⬜ | ✅ | |
| S3 | `box_tree` | smoke | ⬜ | ⬜ | |
| S4 | `item_crud` | smoke | ⬜ | ⬜ | |
| S5 | `lend_return` | smoke | ⬜ | ⬜ | |
| F1 | `box_move` | full | ⬜ | ⏭️ | |
| F2 | `box_delete_trash` | full | ⬜ | ⏭️ | |
| F3 | `item_custom_attributes` | full | ⬜ | ⏭️ | dùng `addMedia` (Android) |
| F4 | `low_stock` | full | ⬜ | ⏭️ | |
| F5 | `partial_lend` | full | ⬜ | ⏭️ | |
| F6 | `stock_history` | full | ⬜ | ⏭️ | |
| F7 | `item_move` | full | ⬜ | ⏭️ | |
| F8 | `scan_image` | full | ⬜ | ⏭️ | dùng `addMedia` (Android) |
| F9 | `search` | full | ⬜ | ⏭️ | |
| F10 | `alerts` | full | ⬜ | ⏭️ | |
| F11 | `settings` | full | ⬜ | ⏭️ | |
| F12 | `reports_export` | full | ⬜ | ⏭️ | |
| F13 | `offline_sync` | full | ⬜ | ⏭️ | `setAirplaneMode` chỉ Android |
| F14 | `session_expiry` | full | ⬜ | ⏭️ | |
| F15 | `multi_user_isolation` | full | ⬜ | ⏭️ | |

### Nhật ký

| Ngày | Việc đã làm | Vấn đề / quyết định |
| :--- | :--- | :--- |
| 2026-10-30 | Lập kế hoạch | Chọn Maestro, selector theo `Semantics(identifier:)` |
| 2026-10-30 | Giai đoạn 1: id login/nav/form box+item/logout, `.maestro/`, `seed.js`, `run_e2e.sh`, S1–S2 | BE rate limit `/auth/*` 30 req/15 phút/IP (cứng) → full suite nhiều user sẽ dính 429; cần nới limit khi E2E hoặc restart BE giữa các lượt |
| 2026-10-30 | Chạy S1–S2 trên iOS simulator: pass | Máy không có Android emulator nên Android chưa chạy. iOS giữ Keychain sau `clearState` → `fresh_start` tự logout; `hideKeyboard` không chạy trên iOS → chạm ra ngoài (`dismiss_keyboard`); nút submit phải `scrollUntilVisible`; lần chạm đầu sau login có thể bị bỏ qua → `logout` chạm nav_setting hai lần. Rate limit: BE đọc `AUTH_RATE_LIMIT` (mặc định 30), `run_e2e.sh` đặt 100000. Maestro 2.12.0 cài tay vào `~/.maestro-cli/maestro/bin` (brew formula cần build openjdk từ mã nguồn trên Mac Intel) → thêm vào PATH |

---

## 1. Kiến trúc

```
FE_Flutter/.maestro/
├── config.yaml                # thứ tự, tags
├── subflows/                  # tái sử dụng
│   ├── login.yaml
│   ├── logout.yaml
│   ├── create_box.yaml        # params: NAME, TYPE, PARENT
│   ├── create_item.yaml
│   ├── open_tab.yaml
│   └── scan_image.yaml        # addMedia ảnh QR → chọn ảnh ở tab Scan
├── scripts/
│   └── seed.js                # gọi API trực tiếp để tạo dữ liệu nhanh
├── media/                     # ảnh QR/barcode sinh ra cho test scan
├── smoke/                     # ~5 phút, chạy mỗi lần sửa
└── full/                      # toàn bộ, chạy trước release
scripts/run_e2e.sh             # bật backend → build app → chạy maestro
```

**Nguyên tắc:**

- **Mỗi flow độc lập:** `launchApp: clearState: true` + `seed.js` (`runScript` + `http.post`) đăng ký **user mới** `e2e_${timestamp}@test.local` và tạo sẵn box/item qua API. Không phụ thuộc thứ tự, không cần dọn DB.
- **Selector bằng id, không bằng text:** app có 2 ngôn ngữ vi/en nên text dễ vỡ. Gắn `Semantics(identifier: 'login_email')` vào widget quan trọng, Maestro dùng `id: login_email`.
- **App id khác nhau:** Android `com.example.inventory`, iOS `com.namtruong244.personal-inventory` → truyền qua `-e APP_ID=...`.

## 2. Bước 0: chuẩn bị app (sửa FE)

| Việc | Chi tiết |
| :--- | :--- |
| Gắn `Semantics(identifier:)` | Login (email, password, nút sign in/register, toggle); bottom nav (Home/Box/Item/Setting, nút quét giữa, nút "+" nổi ở tab Box/Item); field form box/item; action item details (lend, return, move, stock +/-, delete); mục Settings; nút chọn ảnh ở Scan; nút Undo trên toast Trash |
| Helper `e2eId(String id, Widget child)` | Bọc cho gọn, tránh lặp code |
| Build E2E | `--dart-define=API_BASE_URL=...`: Android emulator `http://10.0.2.2:8080`, iOS simulator `http://localhost:8080` |
| Tắt animation khi E2E (khuyên làm) | `--dart-define=E2E=true` để tắt shimmer/spinner lặp, Maestro khỏi chờ lâu |

## 3. Danh sách flow

### Smoke (P0)

| # | Flow | Kiểm tra |
| :--- | :--- | :--- |
| S1 | `auth_register_login` | Đăng ký email → vào Home → logout → login lại; sai mật khẩu → lỗi; mật khẩu < 8 ký tự bị chặn ở form |
| S2 | `first_run` | User mới thấy `FirstRoomsCard` → chọn nhanh vài phòng → tạo hàng loạt |
| S3 | `box_tree` | Tạo Room → Cabinet → Shelf → Box; breadcrumb đúng; điều hướng vào/ra |
| S4 | `item_crud` | Nút "+" → chọn vị trí → form item (tên, số lượng, "Chi tiết thêm": minQuantity) → xem chi tiết → sửa → xóa (vào Trash, toast có Undo); thoát form chưa lưu → hỏi xác nhận |
| S5 | `lend_return` | Lend item `stored` → status `lent`, hiện ở Lending tracker → return (có hộp xác nhận) → về `stored` |

### Full (P1)

| # | Flow | Kiểm tra |
| :--- | :--- | :--- |
| F1 | `box_move` | Move box sang parent khác; thử move vào chính nó/con cháu → bị chặn; move về root |
| F2 | `box_delete_trash` | Xóa box → Undo trên toast; xóa lại → Trash → khôi phục; xóa vĩnh viễn |
| F3 | `item_custom_attributes` | Thêm/xóa custom attribute, category; lưu & mở lại giữ nguyên |
| F4 | `low_stock` | `quantity=5, min=3` → giảm còn 3 → xuất hiện ở Alerts; tăng lên → biến mất; `min` rỗng → không theo dõi |
| F5 | `partial_lend` | Cho mượn 2/5 đơn vị (lentQuantity) → low stock tính theo `quantity + lentQuantity` |
| F6 | `stock_history` | +/- tồn kho → sheet lịch sử có đủ bản ghi |
| F7 | `item_move` | Move item sang box khác qua location picker |
| F8 | `scan_image` | `addMedia` ảnh QR label box → tab Scan → chọn ảnh → mở box; ảnh barcode item → mở item; ảnh mã lạ → "Thêm vật phẩm" → tạo item với mã điền sẵn |
| F9 | `search` | Tìm theo tên, có dấu/không dấu (text_normalize), không có kết quả |
| F10 | `alerts` | Seed item sắp hết hạn, hết bảo hành, mượn quá hạn → đúng mục, đúng số đếm |
| F11 | `settings` | Đổi ngôn ngữ vi↔en, theme sáng/tối, profile, backend URL |
| F12 | `reports_export` | Mở report sheet, export barcodes, thermal label → chỉ assert preview/share sheet mở |
| F13 | `offline_sync` | `setAirplaneMode` (Android) → tạo item → sync bar báo pending → bật mạng → đã đồng bộ (kiểm bằng `seed.js` GET) |
| F14 | `session_expiry` | Seed token hết hạn / xóa token → app về màn login (session_guard) |
| F15 | `multi_user_isolation` | User A tạo box; user B login không thấy; scan label của A → không tìm thấy |

### Ngoài phạm vi / hạn chế

| Phần | Cách xử lý |
| :--- | :--- |
| Google Sign-In | Bỏ qua E2E, test tay (hoặc sau này dùng tài khoản test riêng) |
| Camera quét QR thật | Tab Scan không có nhập mã thủ công → dùng "chọn ảnh từ thư viện" + `addMedia` (F8). Tùy chọn: Android emulator virtual scene camera với ảnh QR, không đưa vào CI |
| Chọn ảnh (image_picker) | `addMedia` của Maestro nạp ảnh vào gallery rồi chọn (F3, Android) |
| In / PDF | Chỉ kiểm tra dialog mở; nội dung PDF đã có unit test `pdf_export_test.dart` |

## 4. Cách chạy

`scripts/run_e2e.sh [android|ios] [smoke|full]`:

1. `cd BE_GoLang && make db-up`, chạy `make run` ở nền, chờ `/health` trả OK.
2. `flutter build apk --debug` (hoặc build iOS simulator) với dart-define ở mục 2, cài lên máy ảo đang bật.
3. `maestro test .maestro/<suite> --include-tags=... -e APP_ID=... --format junit --output report.xml`.
4. Tắt backend. Kết quả: `~/.maestro/tests/` (kèm ảnh chụp màn hình) + `report.xml`.

**Thiết bị chính:** Android emulator Pixel API 34. iOS simulator (iPhone 15) chỉ chạy smoke vì `setAirplaneMode` / `addMedia` bị hạn chế trên iOS.

## 5. Lộ trình

| Giai đoạn | Việc | Kết quả |
| :--- | :--- | :--- |
| 1 | Bước 0 cho login, bottom nav, form box/item; `seed.js`, subflows, `run_e2e.sh` | Chạy được S1–S2 |
| 2 | S3–S5 + id còn lại | Smoke suite ổn định (~5 phút) |
| 3 | F1–F10 | Phủ business rules cốt lõi |
| 4 | F11–F15 | Full suite |
| 5 (tùy chọn) | GitHub Actions: Ubuntu runner + `reactivecircus/android-emulator-runner`, Postgres service cho backend; chạy smoke trên PR | E2E tự động |

**Lưu ý:** Bước 0 sửa nhiều file trong `lib/`, nhưng chỉ bọc widget, không đổi logic.
