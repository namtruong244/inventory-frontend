# Smart Inventory — Tài liệu mô tả giao diện (Design Brief)

Dành cho team thiết kế. Mô tả app mobile (iOS/Android) quản lý đồ đạc / tài sản cá nhân: những màn hình nào, trên mỗi màn có gì, người dùng làm được gì, và hệ thống giao diện hiện tại.

---

## 1. Tổng quan sản phẩm

- **Mục đích:** biết đồ của mình đang ở đâu, còn bao nhiêu, cái nào sắp hết hạn / hết bảo hành, cái nào đã cho mượn.
- **Người dùng:** cá nhân / hộ gia đình, dùng một tay trên điện thoại.
- **Ngôn ngữ:** Tiếng Anh + Tiếng Việt (đổi trong Settings). Chuỗi Việt thường dài hơn chuỗi Anh → layout phải chịu được chữ dài.
- **Theme:** Light (mặc định) và Dark, cả hai phải được thiết kế.
- **Offline:** app dùng được khi mất mạng; thay đổi được xếp hàng và tự đồng bộ lại.

### Khái niệm cốt lõi
| Khái niệm | Ý nghĩa |
| :--- | :--- |
| **Vị trí (Box/Location)** | Cây lưu trữ lồng nhau: Phòng → Tủ → Kệ → Hộp → Ngăn kéo (+ Khác). Mỗi vị trí có mã QR riêng. |
| **Vật phẩm (Item)** | Món đồ nằm trong một vị trí. Có số lượng, ảnh, trạng thái, danh mục, thông số tuỳ biến. |
| **Mượn/trả (Loan)** | Cho người khác mượn một món (toàn bộ hoặc một phần số lượng), có hạn trả. |
| **Cảnh báo** | Hết hạn, sắp hết hạn, tồn kho thấp, quá hạn trả, sắp hết bảo hành. |
| **Thùng rác** | Xoá là chuyển vào thùng rác, khôi phục được trong 30 ngày. |

### Trạng thái vật phẩm (mỗi trạng thái có màu + icon riêng)
| Trạng thái | Màu | Ghi chú |
| :--- | :--- | :--- |
| Stored (Đang cất) | Matcha (xanh lá) | mặc định |
| In use (Đang dùng) | Sky (xanh dương) | |
| Lent (Đang cho mượn) | Amber (cam vàng) | |
| Broken (Hỏng) | Coral (đỏ) | |
| Disposed (Đã bỏ) | Slate (xám) | |
| Lost (Mất) | Lilac (tím) | |

### Loại vị trí (mỗi loại có icon riêng)
Room, Cabinet, Shelf, Box, Drawer, Other.

### Danh mục mặc định
Electronics, Clothing, Tools & Hardware, Kitchen & Dining, Medicine & Health, Documents & Books, Gaming & Media, Office & Stationery, Personal & Misc. Người dùng tự thêm/xoá danh mục; mỗi danh mục có icon suy ra từ tên.

---

## 2. Hệ thống giao diện hiện tại (Design System)

Phong cách **soft / neo-morphic**: nền xám rất nhạt, card trắng bo tròn lớn, bóng mềm thay cho viền cứng, điểm nhấn màu lime.

### Màu (Light / Dark)
| Token | Light | Dark | Dùng cho |
| :--- | :--- | :--- | :--- |
| background | #F7F8FA | #0B0B0D | nền trang |
| surface | #FFFFFF | #18181B | card, sheet, dialog |
| fill | #F1F3F6 | #27272A | ô nhập, chip, nền segmented |
| border | #E9EBEF | #3F3F46 | đường kẻ mảnh (ít dùng) |
| textPrimary | #18181B | #F4F4F5 | chữ chính |
| textSecondary | #5F5F68 | #A1A1AA | chữ phụ |
| textMuted | #686872 | #909098 | placeholder, disabled |
| primary | #18181B | #52525B | nút chính (tối), chip được chọn |
| **accent (lime)** | #C8F169 | #C8F169 | trạng thái active, CTA, progress; nội dung trên nó dùng `onAccent` #1B2406 (không dùng trắng) |
| danger soft/strong | #FFE9E4 / #9F2D1C | #3A1A1C / #FCA5A5 | lỗi, quá hạn |
| warning soft/strong | #FFF3C4 / #7A4B07 | #3A2B0E / #FCD34D | cảnh báo |
| success soft/strong | #EAF8CC / #3F6212 | #0F2E22 / #6EE7B7 | còn hàng, thành công |
| info soft/strong | #E4F0FF / #1D4ED8 | #16233B / #93C5FD | thông tin |

Màu pastel cho tag/progress (`AppTones`): coral #D64535, amber #B86E00, matcha #4D7C0F, sky #2F6FCB, lilac #7C5CD6, slate #64748B, ink #1E293B.

**Ràng buộc truy cập:** chữ phụ phải đạt tương phản WCAG AA (≥ 4.5:1) trên background/surface/fill ở cả 2 theme. Mọi vùng chạm có nhãn accessibility, mọi nút icon có tooltip.

### Hình khối & chữ
- Card: nền trắng, **bo 24px**, bóng mềm (blur 24, offset y 8, độ mờ ~6% ở Light / 35% ở Dark), không viền.
- Font: **Plus Jakarta Sans** (đã bundle trong app).
- Padding ngang màn hình thường là **24px**.
- Mục có chi tiết con có chevron `>` ở cuối.
- Trạng thái ưu tiên **chip màu / thanh tiến độ** hơn chữ thuần.

### Bộ component dựng sẵn (cần thiết kế lại hoặc giữ đồng bộ)
| Component | Mô tả |
| :--- | :--- |
| SoftCard | Card nền surface bo 24 + bóng mềm |
| SoftChip | Nhãn trạng thái / tag màu (Expired, Low stock, Overdue, Lent, Returned…) |
| SoftFilterChip | Chip lọc (All / Stored / Lent …), có trạng thái chọn |
| SoftBar | Thanh tiến độ ngang |
| SoftRing | Vòng tròn tiến độ |
| SoftIconTile | Ô vuông bo chứa icon |
| SoftSearchField | Ô tìm kiếm |
| AppFormField | Ô nhập form (nhãn, lỗi, helper) |
| AppImageView | Hiển thị ảnh (có placeholder) |
| BreadcrumbBar | Đường dẫn vị trí (Phòng › Tủ › Kệ), bấm được |
| EmptyStateCard | Trạng thái trống kèm nút hành động |
| Toast (success / error / warning / info) + Confirm dialog | Phản hồi & xác nhận |
| SyncStatusBar | Thanh trạng thái offline / đang chờ đồng bộ, hiển thị toàn app |

### Icon
Bộ icon SVG tự thiết kế: lưới 24, **nét 2.2, đầu bo tròn**, mũi tên một ngạnh. Hiện chỉ phủ phần lớn glyph đang dùng; glyph chưa có rơi về Material Icons → nên thiết kế trọn bộ.

### Mẫu tương tác chung
- **Bottom sheet** dùng rất nhiều (chọn vị trí, cho mượn, nhập số lượng, menu hành động…).
- **Nhấn giữ** item/vị trí → menu hành động; vuốt chỉ là lối tắt.
- **Pull-to-refresh** trên mọi danh sách dữ liệu server.
- **Xoá** → toast có nút **Undo** (vì có thùng rác), không dùng câu "không thể hoàn tác".
- Form chưa lưu mà thoát → hộp thoại hỏi bỏ thay đổi.
- Lưu thất bại: ở lại màn, giữ nguyên dữ liệu đã nhập, báo lỗi thân thiện.
- Mỗi danh sách cần **trạng thái trống** có nút hành động rõ ràng.

---

## 3. Điều hướng

### Bottom navigation (màn chính)
```
 Home   Box   [ QR ]   Item   Setting            (+)
```
- 4 tab: **Home, Box, Item, Setting**.
- Nút **quét QR ở giữa**: nền tối, icon lime, nổi bật hơn các tab.
- Nút **"+" thêm nhanh** màu lime, nổi cạnh thanh nav, **chỉ hiện ở tab Box và Item** (ẩn ở Home) để vừa tầm ngón cái.
- Thanh nav chia đều (`spaceEvenly`), phải không tràn trên màn hẹp.
- Các màn còn lại (chi tiết, tạo/sửa, cảnh báo, mượn/trả…) mở chồng lên bằng push thông thường.

### Luồng vào app
`Splash → Login/Đăng ký → Home`. Hết phiên (401) tự đưa về đăng nhập. Không có chế độ khách.

---

## 4. Mô tả từng màn hình

### 4.1 Splash
Logo + tagline, nút "Continue to App". Nền sáng theo theme (không còn nền tối riêng).

### 4.2 Đăng nhập / Đăng ký
- Một màn, chuyển qua lại giữa **Sign in** và **Create account**.
- Trường: họ tên (chỉ khi đăng ký), email, mật khẩu (nút ẩn/hiện).
- Nút **Continue with Google** (có logo Google).
- Dòng điều khoản "By continuing you agree to…", link đổi chế độ ("Don't have an account? / Already have an account?").
- Lời chào "Welcome back / Welcome {tên}".
- Trạng thái: lỗi validate từng ô (email không hợp lệ, mật khẩu tối thiểu, thiếu tên), lỗi xác thực, lỗi Google.

### 4.3 Home (tab 1)
Cuộn dọc, kéo để refresh. Từ trên xuống:
1. **Header:** lời chào "Hey {tên}", tagline "Track & manage your inventory", **nút chuông cảnh báo** (có chấm/badge số lượng), **thanh tìm kiếm** (bấm mở màn Search).
2. **Banner kết nối:** hiện khi không kết nối được backend, có nút Retry.
3. **Banner cảnh báo:** "Action required" (có số lượng cảnh báo, nút Review) hoặc "All clear".
4. **Khối số liệu nhanh (InventoryMetricsBanner):** Total assets, Est. value (tổng giá trị), On loan, Containers.
   - **Tài khoản mới (chưa có vị trí nào):** thay bằng **FirstRoomsCard** — chọn nhanh các phòng thường gặp (Living room, Kitchen…) để tạo hàng loạt.
5. **Hai thẻ module nhanh:** *Alerts* và *Lending* (mỗi thẻ có số đếm / "No loans").
6. **Recent items:** danh sách món vừa thêm/dùng, link "View all", chip Low stock, tên vị trí. Trạng thái trống: "Add your first item".

### 4.4 Box — Cây vị trí (tab 2)
- Tiêu đề "Storage hierarchy", ô tìm kiếm "Search locations…".
- **Chip lọc:** All / Rooms / Cabinets & Shelves / Boxes & Drawers.
- Nút chuyển **dạng cây ↔ danh sách phẳng**, nút **Expand all / Collapse all**.
- Mỗi dòng (BoxCard): icon theo loại, tên, số món + số container con, chevron, thụt lề theo cấp.
- Hành động: bấm → mở chi tiết; nhấn giữ/vuốt → menu (Edit, Move, Add sub-container, Delete).
- Trống: "No locations yet — Create first location". Tìm không ra: "No matching locations found".
- Nút "+" nổi → tạo vị trí mới.

### 4.5 Chi tiết vị trí (Box details)
- **Breadcrumb** trên cùng (bấm cấp trên để quay lại).
- Tên, loại, mô tả, mã QR (xem "Show QR code" / "View full QR code").
- **Box summary / Overview:** số món, số container con, cảnh báo hết hạn.
- **Nested containers:** danh sách con.
- **Items in this container:** danh sách món (ItemCard), tag Expired / sắp hết hạn "Expires in N days".
- Trống: "No direct items stored here".
- Menu "More options": Edit location, Move location, Delete location, **Export barcodes**, **Print thermal label**.
- Nút nhanh: Add item, Add container.

### 4.6 Tạo / Sửa vị trí
Form: Name (vd "Living room oak cabinet"), Storage type (chọn 1 trong 6, có icon), Parent container (chọn qua LocationPickerSheet, có thể để trống = gốc), Description, QR label ID (sinh sẵn, sửa được). Nút Save location / Save changes; khi sửa có nút Delete. Toast thành công/lỗi.

### 4.7 Item — Danh sách vật phẩm (tab 3)
- Tiêu đề "Item catalog" + "N assets tracked".
- Ô tìm kiếm (tên, barcode, serial).
- **Chip lọc:** All / Stored / In use / Lent / Low stock / Expiring… và lọc theo vị trí ("All storage locations").
- Mỗi **ItemCard:** ảnh/icon danh mục, tên, số lượng + đơn vị, đường dẫn vị trí ("In: Kitchen › Shelf"), chip trạng thái (Lent, In use), chip cảnh báo (Low stock, Expired, Expires in N d).
- Hành động: bấm → chi tiết; nhấn giữ/vuốt → menu (Edit, Move, Lend/Return, Delete).
- Trống: "No items found — Add your first item" (nếu chưa có vị trí thì dẫn đi tạo vị trí).

### 4.8 Chi tiết vật phẩm
Màn dài, gồm các card:
1. **Ảnh sản phẩm** (carousel/gallery nhiều ảnh) + nút quay lại, menu "More options".
2. **Tên, trạng thái (chip), danh mục, số lượng.**
3. **Hành động chính** thay đổi theo trạng thái: *Take out to use* / *Return to storage*, *Lend item* / *Return*, *Consume* (đồ tiêu hao), *Restock*, *Move*.
4. **Cảnh báo tồn kho:** ngưỡng hiện tại, "Low stock warning", "Out of stock — Restock", nút Change.
5. **Hạn sử dụng:** "Expires soon in N days" / "Product has expired" / "Fresh — N days remaining".
6. **Bảo hành:** Warranty active / expired, "Valid until {ngày}".
7. **Thông tin mua hàng:** ngày mua, giá mua, serial number, barcode (có nút Copy).
8. **Vị trí lưu trữ:** breadcrumb + nút Move.
9. **Đang cho mượn:** người mượn, liên hệ, ngày cho mượn, hạn trả, tag Overdue.
10. **Thông số (Specifications):** bảng key–value tuỳ biến (màu, RAM…).
11. **Ảnh hoá đơn / bảo hành.**
12. **Lịch sử tồn kho** (Stock history).
- Menu: Edit item details, Move location, Delete item.

### 4.9 Tạo / Sửa vật phẩm
Form chia mục, **chỉ phần đầu hiện sẵn**, phần còn lại thu gọn trong "More details" (mở sẵn khi sửa).
- **Cơ bản:** Item name, Quantity, Unit (chọn), Storage location (picker hoặc quét QR), Category (sheet chọn / tạo mới), Cover photo.
- **More details:** Description, Serial number, Product barcode (nút Scan barcode), Purchase price, Purchase date, Status.
- **Consumable item** (công tắc: pin, khẩu trang, thực phẩm) → hiện thêm **Low stock alert threshold**.
- **Perishable / Expiry** (hạn dùng) và **Warranty expiry**.
- **Ảnh sản phẩm + ảnh hoá đơn** (chụp / thư viện / dán URL / ảnh mẫu).
- **Specifications:** thêm thuộc tính tuỳ ý (có gợi ý sẵn).
- Nút Save item; thoát khi chưa lưu → hộp thoại Discard.
- Lỗi: "Please fix the highlighted fields".

### 4.10 Tìm kiếm toàn cục
Ô tìm kiếm lớn, tìm không dấu theo tên / barcode / serial / vị trí. Chip lọc: All / Items / Locations / Stored / In use / Lent / Perishable. Kết quả chia nhóm *Items* và *Storage locations*; mỗi dòng có "Qty". Trạng thái: chưa gõ ("Search your entire inventory"), không kết quả ("No results for …").

### 4.11 Cảnh báo (Alerts / Lifecycle alerts)
Các nhóm, mỗi nhóm một section, trạng thái "All good" khi trống:
- **Expired items** ("Expired N days ago on …")
- **Expiring soon (perishables)** ("Expires in N days on …")
- **Low stock warnings** ("Only X remaining, threshold Y")
- **Overdue borrowed items** (người mượn, "N days overdue")
- **Warranties ending soon** ("Warranty ends in N days")
Bấm dòng → chi tiết món.

### 4.12 Mượn / trả (Lending tracker)
- Tab/segment: **Active / History** (có Overdue nổi bật).
- Thẻ khoản mượn: tên món, "Lent to {người}", hạn trả, chip Lent / **Overdue** (đỏ) / Returned; nút **Mark as returned** (có hộp xác nhận).
- Nút **Lend item** → LendItemSheet.
- Trống: "No active loans — all your items are safely stored", "No lending history".

### 4.13 Sheet cho mượn (Lend an item)
Chọn món (danh sách có ô tìm, chỉ món còn hàng; nếu mở từ món thì đã chọn sẵn) → Quantity to lend (để trống = cho mượn hết) → Borrower name (bắt buộc), Contact (SĐT/email, tuỳ chọn) → Expected return date → Notes → Save loan.

### 4.14 Quét QR (nút giữa bottom nav)
- Camera toàn màn hình (nền sáng theo theme), khung ngắm, nút **Flashlight**, nút **Gallery** (chọn ảnh có QR). **Không** có nhập mã tay, không có chế độ barcode riêng.
- Quét ra:
  - **Vị trí** → "Found container" → mở chi tiết vị trí.
  - **Món đồ** → "Found item" → mở chi tiết món.
  - **Không biết** → "Unknown code" với lựa chọn *Add new item* (chọn vị trí để gán mã) hoặc *Scan again*.
- Có tuỳ chọn "Keep scanning" (quét liên tục) và gợi ý "Point at a box QR…".
- Lỗi: "No QR found in image".

### 4.15 Hiển thị QR / In tem
- **QR display:** mã QR lớn, nhãn, nút **Print label**.
- **Thermal label sheet:** tem 50×30mm in nhiệt, Copy ID, Print.
- **Export barcodes sheet:** xuất PDF nhiều tem (tất cả vị trí / một vị trí / A4 decal / thermal 50×30), xem trước (Print preview), lưu/chia sẻ PDF, trạng thái "Generating PDF…".

### 4.16 Sheet chọn vị trí (LocationPickerSheet)
Dùng ở nhiều nơi (tạo món, di chuyển, chọn cha). Ô tìm, duyệt cây từng cấp (vào trong "Sub-containers inside"), "Current location", chọn trực tiếp mức hiện tại, **tạo vị trí ngay tại chỗ** ("Create location here"), nút **Scan QR** để chọn bằng mã. Trống: "No locations available".

### 4.17 Các sheet/dialog nhỏ khác
- **Item actions / Box actions sheet:** menu nhấn giữ.
- **Move item sheet / Move location dialog:** di chuyển (cây vị trí không cho chuyển vào chính nó hoặc con cháu).
- **Stock sheets:** *Restock* (Quantity to add, xem tổng sau khi thêm), *Consume/Use* (Use 1 / 2 / 5 / All, hiển thị "Remaining after use", cảnh báo "will be out of stock", "Quantity has dropped to…").
- **Stock history sheet:** lịch sử thay đổi số lượng.
- **Item photo modal:** Camera / Gallery / dán URL / ảnh mẫu; loại ảnh: sản phẩm, hoá đơn giấy, thẻ bảo hành.
- **Category sheets:** chọn/tạo danh mục.
- **Attribute sheets:** thêm/sửa thông số (tên, giá trị, gợi ý).
- **Barcode scan sheet:** quét barcode sản phẩm khi tạo món.
- **Failed ops tile:** thay đổi bị từ chối khi đồng bộ (xung đột) → chọn *Keep mine* / *Discard*.

### 4.18 Thùng rác (Trash)
Danh sách món + vị trí đã xoá (khôi phục trong 30 ngày). Mỗi dòng: **Restore**, **Delete permanently**. Nút **Empty trash** (xác nhận). Trống: "Trash is empty". Lỗi tải: nút Retry.

### 4.19 Cài đặt (tab 4 — Settings)
Chia nhóm cuộn dọc:
- **Hồ sơ:** avatar/tên/email, Edit profile (tên hiển thị, vai trò/bộ phận).
- **Appearance:** Theme (System/Light/Dark), Language (System/English/Việt).
- **Inventory preferences:** Currency symbol, Default item unit, Time zone, Manage categories (thêm/xoá/tìm danh mục).
- **Alerts:** Expiry warning window (số ngày trước khi hết hạn), Warranty warning window; công tắc *Low stock*, *Expiring*, *Overdue*.
- **Scanner:** Auto-open sau khi quét, Sound, Vibrate (công tắc).
- **Reports & Audit:** Inventory report (bản text sao chép được), **Inventory health breakdown** (phân bố trạng thái: in stock / lent / expired… dạng thanh), Export all box barcodes (PDF), Trash.
- **Backend (chỉ dev):** đổi URL API — ẩn, mở bằng cách chạm nhiều lần vào version.
- **Application info:** version, badge Developer.
- **Tài khoản:** Log out (hỏi nếu còn thay đổi chưa đồng bộ: Discard & log out / Cancel), Delete account (nhập "DELETE" để xác nhận).

### 4.20 Thanh đồng bộ (SyncStatusBar — toàn app)
Hiện trên mọi màn khi cần: *Offline*, *N thay đổi đang chờ*, *Cần xử lý* (có thay đổi bị từ chối). Bấm mở sheet chi tiết với nút **Sync now** / Dismiss. Không tự làm banner riêng ở từng màn.

---

## 5. Trạng thái cần thiết kế cho MỌI màn dữ liệu

| Trạng thái | Yêu cầu |
| :--- | :--- |
| Loading | skeleton hoặc spinner nhất quán |
| Empty | minh hoạ/icon + câu giải thích + nút hành động chính |
| Error | thông báo thân thiện + nút Retry |
| Offline | dữ liệu cache vẫn hiển thị + SyncStatusBar |
| Dữ liệu dài | tên dài, đường dẫn vị trí sâu (5 cấp) phải cắt gọn (ellipsis), chuỗi tiếng Việt dài |
| Dark mode | toàn bộ màn + sheet + dialog |
| Màn hẹp | không tràn ngang (ví dụ thanh nav, hàng chip) |

---

## 6. Quy tắc nghiệp vụ ảnh hưởng tới hiển thị

- **Low stock:** hiện khi có đặt ngưỡng và `số lượng + số đang cho mượn một phần ≤ ngưỡng`. Không đặt ngưỡng = không hiển thị cảnh báo.
- **Cho mượn:** chỉ món `Stored`/`In use` mới được cho mượn; khi mượn → trạng thái Lent; trả → về Stored.
- **Quá hạn trả:** hiển thị đỏ (Overdue) + số ngày trễ.
- **Hết hạn / bảo hành:** có 3 mức — còn lâu (xanh), sắp hết (vàng, "trong N ngày"), đã hết (đỏ).
- **Tiền / số lượng** hiển thị theo currency và đơn vị người dùng chọn trong Settings.
- **Ngày** hiển thị theo locale.

---

## 7. Đề nghị cho team thiết kế

1. Giữ ngôn ngữ soft UI (card bo 24, bóng mềm, lime accent) hoặc đề xuất hướng mới — nhưng phải giữ **hai theme**, **tương phản AA**, và hệ token màu ở mục 2 (đổi giá trị được, không đổi tên vai trò).
2. Cung cấp: bộ component (mục 2), bộ icon trọn gói, màn hình ở **Light + Dark**, **EN + VI**, và các trạng thái ở mục 5.
3. Ưu tiên thiết kế trước: Home, Box (cây), Item list, Item detail, Create/Edit item, Scanner, Settings; sau đó Alerts, Lending, Search, Trash, các sheet.
4. Mọi hành động thường dùng (thêm, quét) phải với tới được bằng một tay ở nửa dưới màn hình.
