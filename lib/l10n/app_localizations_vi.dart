// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get scanTitle => 'Quét QR & mã vạch';

  @override
  String scanFoundContainer(String name) {
    return 'Đã tìm thấy: \"$name\"';
  }

  @override
  String scanFoundItem(String name) {
    return 'Đã tìm thấy vật phẩm: \"$name\"';
  }

  @override
  String get scanOpenDetailsPrompt => 'Mở chi tiết ngay?';

  @override
  String get scanOpen => 'Mở';

  @override
  String get scanKeepScanning => 'Tiếp tục quét';

  @override
  String scanUnknownTitle(String code) {
    return 'Mã đã quét: $code';
  }

  @override
  String get scanUnknownMessage =>
      'Chưa có hộp hoặc vật phẩm nào khớp với mã này. Bạn có muốn tạo vật phẩm mới với mã này không?';

  @override
  String get scanAddNewItem => 'Thêm vật phẩm';

  @override
  String get scanPickLocationTitle => 'Vật phẩm được cất ở đâu?';

  @override
  String get scanPickLocationSubtitle => 'Chọn vị trí cho vật phẩm mới';

  @override
  String get scanPickLocationConfirm => 'Dùng vị trí này';

  @override
  String get scanModeLocation => 'QR vị trí';

  @override
  String get scanModeProduct => 'Mã vạch sản phẩm';

  @override
  String get scanHintProduct =>
      'Quét mã vạch sản phẩm (UPC/EAN) để điền sẵn hoặc tìm trong kho';

  @override
  String get scanHintLocation =>
      'Hướng camera vào mã QR của hộp để xem chi tiết và toàn bộ đồ bên trong';

  @override
  String get scanManualTitle => 'Nhập mã thủ công';

  @override
  String get scanManualLabel => 'Mã nhãn hoặc mã vạch';

  @override
  String get settingsAppearanceHeader => 'GIAO DIỆN & NGÔN NGỮ';

  @override
  String get settingsTheme => 'Giao diện';

  @override
  String get settingsThemeSubtitle => 'Giao diện sáng hoặc tối';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsLanguageSubtitle => 'Các màn đã dịch sẽ đổi ngôn ngữ ngay';

  @override
  String get languageSystem => 'Theo hệ thống';

  @override
  String get settingsScannerHeader => 'MÁY QUÉT & NHẬN DIỆN';

  @override
  String get settingsAlertsHeader => 'CẢNH BÁO';

  @override
  String get settingsVibrate => 'Rung khi quét';

  @override
  String get settingsVibrateSubtitle =>
      'Rung nhẹ khi nhận diện được QR/mã vạch';

  @override
  String get settingsSound => 'Âm thanh khi quét';

  @override
  String get settingsSoundSubtitle =>
      'Phát tiếng bíp khi quét thành công (chỉ trên máy này)';

  @override
  String get settingsAutoOpen => 'Tự mở chi tiết';

  @override
  String get settingsAutoOpenSubtitle =>
      'Tắt: hỏi trước khi mở hộp/vật phẩm vừa quét';

  @override
  String get settingsExpiring => 'Vật phẩm sắp hết hạn';

  @override
  String get settingsExpiringSubtitle =>
      'Tính vật phẩm hết hạn/sắp hết hạn vào số cảnh báo trong app (chưa có thông báo đẩy)';

  @override
  String get settingsOverdue => 'Khoản mượn quá hạn';

  @override
  String get settingsOverdueSubtitle =>
      'Tính khoản mượn quá hạn vào số cảnh báo trong app (chưa có thông báo đẩy)';

  @override
  String get settingsLowStock => 'Sắp hết hàng';

  @override
  String get settingsLowStockSubtitle =>
      'Tính vật phẩm dưới ngưỡng tối thiểu vào số cảnh báo trong app';

  @override
  String get trashConfirmItemTitle => 'Chuyển vào thùng rác?';

  @override
  String get trashConfirmBoxTitle => 'Chuyển vị trí vào thùng rác?';

  @override
  String trashConfirmMessage(String name, int days) {
    return '\"$name\" sẽ được chuyển vào thùng rác. Bạn có thể khôi phục trong $days ngày.';
  }

  @override
  String trashConfirmBoxMessage(String name, int days) {
    return '\"$name\" và mọi thứ bên trong sẽ được chuyển vào thùng rác. Bạn có thể khôi phục trong $days ngày.';
  }

  @override
  String get trashMoveAction => 'Chuyển vào thùng rác';

  @override
  String trashMovedToast(String name) {
    return 'Đã chuyển \"$name\" vào thùng rác';
  }

  @override
  String get trashUndo => 'Hoàn tác';

  @override
  String trashRestoredToast(String name) {
    return 'Đã khôi phục \"$name\"';
  }

  @override
  String trashRestoreFailed(String name) {
    return 'Không khôi phục được \"$name\". Hãy thử từ Thùng rác trong Cài đặt.';
  }

  @override
  String get syncOffline => 'Ngoại tuyến: đang hiển thị dữ liệu đã lưu';

  @override
  String get syncUnsynced => 'Có thay đổi chưa đồng bộ';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thay đổi đang chờ đồng bộ',
      zero: 'Không có thay đổi đang chờ',
    );
    return '$_temp0';
  }

  @override
  String syncNeedsAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mục cần bạn xử lý',
    );
    return '$_temp0';
  }

  @override
  String get syncSheetTitle => 'Trạng thái đồng bộ';

  @override
  String get syncOfflineBody =>
      'Bạn đang ngoại tuyến. Thay đổi được lưu trên máy và sẽ tự tải lên khi kết nối được với máy chủ.';

  @override
  String get syncOnlineBody => 'Một số thay đổi chưa lên được máy chủ.';

  @override
  String get syncRejectedTitle => 'Máy chủ đã từ chối';

  @override
  String get syncDismiss => 'Ẩn';

  @override
  String get syncNow => 'Đồng bộ ngay';

  @override
  String get lifecycleAlerts => 'Vòng đời & cảnh báo';

  @override
  String get allGood => 'Mọi thứ ổn!';

  @override
  String get noItemsAreExpiredExpiring =>
      'Không có vật phẩm nào hết hạn, sắp hết hạn hoặc quá hạn trả.';

  @override
  String get expiredItems => 'Vật phẩm đã hết hạn';

  @override
  String get expiringSoonPerishables => 'Sắp hết hạn (đồ dễ hỏng)';

  @override
  String get warrantiesEndingSoon => 'Bảo hành sắp hết';

  @override
  String get overdueBorrowedItems => 'Đồ cho mượn quá hạn';

  @override
  String get lowStockWarnings => 'Cảnh báo sắp hết hàng';

  @override
  String get commonStorage => 'Lưu trữ';

  @override
  String onlyRemainingThreshold(
    Object qty,
    Object unit,
    Object minQty,
    Object unit2,
  ) {
    return 'Chỉ còn $qty $unit (ngưỡng: ≤ $minQty $unit2)';
  }

  @override
  String get viewDetails => 'Xem chi tiết';

  @override
  String warrantyEndsInDays(Object daysLeft) {
    return 'Bảo hành hết hạn sau $daysLeft ngày';
  }

  @override
  String get borrowedItem => 'Đồ đang cho mượn';

  @override
  String commonBorrower(Object borrowerName, Object borrowerContact) {
    return 'Người mượn: $borrowerName • $borrowerContact';
  }

  @override
  String locationUpdatedSuccessfully(Object boxName) {
    return 'Đã cập nhật vị trí \"$boxName\"';
  }

  @override
  String locationCreatedSuccessfully(Object boxName) {
    return 'Đã tạo vị trí \"$boxName\"';
  }

  @override
  String get pleaseEnterAValidLocation => 'Vui lòng nhập tên vị trí hợp lệ';

  @override
  String get editLocation => 'Sửa vị trí';

  @override
  String get createRootLocation => 'Tạo vị trí gốc';

  @override
  String get createNestedContainer => 'Tạo ngăn chứa con';

  @override
  String get commonDelete => 'Xóa';

  @override
  String couldNotDeletePleaseTry(Object boxName) {
    return 'Không thể xóa \"$boxName\". Vui lòng thử lại.';
  }

  @override
  String get storageType => 'Loại nơi lưu trữ';

  @override
  String get commonName => 'Tên';

  @override
  String get eGLivingRoomOak =>
      'VD: Phòng khách, Tủ sách gỗ sồi, Hộp đồ điện tử';

  @override
  String get pleaseEnterAName => 'Vui lòng nhập tên';

  @override
  String get commonDescription => 'Mô tả';

  @override
  String get eGUpperShelfLeft =>
      'VD: Kệ trên, bên trái gần cửa sổ (không bắt buộc)';

  @override
  String get parentContainer => 'Ngăn chứa cha';

  @override
  String get qrLabelId => 'Mã nhãn QR';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get saveLocation => 'Lưu vị trí';

  @override
  String get locationNotFound => 'Không tìm thấy vị trí';

  @override
  String get exportBarcodes => 'Xuất mã vạch';

  @override
  String get moreOptions => 'Thêm tùy chọn';

  @override
  String get showQrCode => 'Hiện mã QR';

  @override
  String get commonOverview => 'Tổng quan';

  @override
  String nestedContainers(Object count) {
    return 'Ngăn chứa con ($count)';
  }

  @override
  String get addContainer => 'Thêm ngăn chứa';

  @override
  String get addContainerInside => 'Thêm ngăn chứa bên trong';

  @override
  String couldNotDeletePleaseTry2(Object name) {
    return 'Không thể xóa \"$name\". Vui lòng thử lại.';
  }

  @override
  String itemsInThisContainer(Object count) {
    return 'Vật phẩm trong ngăn này ($count)';
  }

  @override
  String get addItem => 'Thêm vật phẩm';

  @override
  String get noDirectItemsStoredHere =>
      'Chưa có vật phẩm nào được cất trực tiếp ở đây';

  @override
  String get moveLocation => 'Di chuyển vị trí';

  @override
  String get printThermalLabel => 'In tem nhiệt';

  @override
  String get viewFullQrCode => 'Xem mã QR đầy đủ';

  @override
  String get deleteLocation => 'Xóa vị trí';

  @override
  String get storageHierarchy => 'Cây vị trí lưu trữ';

  @override
  String get exportAllQrCodes => 'Xuất tất cả mã QR';

  @override
  String get newLocation => 'Vị trí mới';

  @override
  String get searchLocationsRoomsContainers =>
      'Tìm vị trí, phòng, ngăn chứa...';

  @override
  String commonAll(Object count) {
    return 'Tất cả ($count)';
  }

  @override
  String commonRooms(Object count) {
    return 'Phòng ($count)';
  }

  @override
  String cabinetsShelves(Object count) {
    return 'Tủ & kệ ($count)';
  }

  @override
  String boxesDrawers(Object count) {
    return 'Hộp & ngăn kéo ($count)';
  }

  @override
  String get switchToFlatList => 'Chuyển sang danh sách phẳng';

  @override
  String get switchToTreeView => 'Chuyển sang dạng cây';

  @override
  String get expandAll => 'Mở rộng tất cả';

  @override
  String get collapseAll => 'Thu gọn tất cả';

  @override
  String get noLocationsYet => 'Chưa có vị trí nào';

  @override
  String get tapNewLocationAboveTo =>
      'Nhấn \"Vị trí mới\" ở trên để tạo phòng hoặc hộp đầu tiên';

  @override
  String get noMatchingLocationsFound => 'Không tìm thấy vị trí phù hợp';

  @override
  String get trySearchingWithADifferent => 'Thử tìm bằng tên hoặc nhãn khác';

  @override
  String get commonMove => 'Di chuyển';

  @override
  String get commonEdit => 'Sửa';

  @override
  String get addSubContainer => 'Thêm ngăn chứa con';

  @override
  String get commonPath => 'Đường dẫn: ';

  @override
  String get trackManageYourInventory => 'Theo dõi & quản lý\nđồ đạc của bạn!';

  @override
  String get commonSearch => 'Tìm kiếm';

  @override
  String get commonHome => 'Trang chủ';

  @override
  String get commonBox => 'Vị trí';

  @override
  String get commonItem => 'Đồ đạc';

  @override
  String get commonSetting => 'Cài đặt';

  @override
  String get scanQrCode => 'Quét mã QR';

  @override
  String categoryCreated(Object created) {
    return 'Đã tạo danh mục \"$created\"';
  }

  @override
  String itemUpdatedSuccessfully(Object itemName) {
    return 'Đã cập nhật vật phẩm \"$itemName\"';
  }

  @override
  String itemAddedSuccessfully(Object itemName) {
    return 'Đã thêm vật phẩm \"$itemName\"';
  }

  @override
  String get pleaseEnterAValidQuantity => 'Nhập số lượng hợp lệ (từ 0 trở lên)';

  @override
  String get pleaseFixTheHighlightedFields =>
      'Vui lòng sửa các trường được đánh dấu';

  @override
  String get couldnTUploadThePhoto =>
      'Không tải được ảnh lên. Kiểm tra kết nối rồi thử lại.';

  @override
  String get editItem => 'Sửa vật phẩm';

  @override
  String get newItem => 'Vật phẩm mới';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonCreate => 'Tạo';

  @override
  String get productPhotos => 'Ảnh sản phẩm';

  @override
  String get receiptsWarrantyProof => 'Hóa đơn & bằng chứng bảo hành';

  @override
  String get saveItem => 'Lưu vật phẩm';

  @override
  String get basicInformation => 'Thông tin cơ bản';

  @override
  String get itemName => 'Tên vật phẩm';

  @override
  String get eGMacbookProFirst => 'VD: MacBook Pro, Hộp sơ cứu, Cáp USB';

  @override
  String get pleaseEnterItemName => 'Vui lòng nhập tên vật phẩm';

  @override
  String get commonCategory => 'Danh mục';

  @override
  String get selectCategory => 'Chọn danh mục';

  @override
  String get tapToChangeCategory => 'Chạm để đổi danh mục';

  @override
  String get commonQuantity => 'Số lượng';

  @override
  String get commonUnit => 'Đơn vị';

  @override
  String get selectUnit => 'Chọn đơn vị';

  @override
  String get lowStockAlertThresholdOptional =>
      'Ngưỡng cảnh báo sắp hết (không bắt buộc)';

  @override
  String get eG2AlertWhen => 'VD: 2 (cảnh báo khi số lượng ≤ số này)';

  @override
  String get storageLocation => 'Vị trí lưu trữ';

  @override
  String get selectStorageContainer => 'Chọn ngăn chứa';

  @override
  String get commonUnassigned => 'Chưa gán';

  @override
  String get colorConditionAccessoriesOptional =>
      'Màu sắc, tình trạng, phụ kiện (không bắt buộc)';

  @override
  String get consumableItem => 'Vật phẩm tiêu hao';

  @override
  String get consumableItemsBatteriesMasksFood =>
      'Đồ tiêu hao (pin, khẩu trang, thực phẩm, thuốc...)';

  @override
  String get assetStatus => 'Trạng thái tài sản';

  @override
  String get assetWarrantyDetails => 'Tài sản & bảo hành';

  @override
  String purchasePrice(Object currency) {
    return 'Giá mua ($currency)';
  }

  @override
  String get serialNumber => 'Số sê-ri';

  @override
  String get productBarcodeUpcEan => 'Mã vạch sản phẩm (UPC / EAN)';

  @override
  String get scanOrEnterProductBarcode => 'Quét hoặc nhập mã vạch sản phẩm';

  @override
  String get warrantyExpiry => 'Hạn bảo hành';

  @override
  String get perishableExpiry => 'Hạn sử dụng';

  @override
  String get receiptCaptured => 'Đã chụp hóa đơn';

  @override
  String get photoCaptured => 'Đã chụp ảnh';

  @override
  String get cameraIsnTAvailableCheck =>
      'Không dùng được camera. Hãy kiểm tra quyền camera của ứng dụng.';

  @override
  String get receiptSelected => 'Đã chọn hóa đơn';

  @override
  String get photoSelected => 'Đã chọn ảnh';

  @override
  String get couldnTOpenYourPhotos =>
      'Không mở được thư viện ảnh. Hãy kiểm tra quyền truy cập ảnh của ứng dụng.';

  @override
  String get commonCover => 'Ảnh bìa';

  @override
  String get notSet => 'Chưa đặt';

  @override
  String get selectStorageLocation => 'Chọn vị trí lưu trữ';

  @override
  String get chooseContainerOrScanQr => 'Chọn ngăn chứa hoặc quét QR để gán';

  @override
  String get setLocation => 'Đặt vị trí';

  @override
  String returnedToStorage(Object name) {
    return 'Đã cất \"$name\" về nơi lưu trữ';
  }

  @override
  String returnedToStorage2(Object name, Object boxName) {
    return 'Đã cất \"$name\" về nơi lưu trữ$boxName';
  }

  @override
  String movedBackToStorage(Object name) {
    return 'Đã chuyển \"$name\" về nơi lưu trữ';
  }

  @override
  String get itemNotFoundOrHas => 'Không tìm thấy vật phẩm hoặc đã bị xóa';

  @override
  String get goBack => 'Quay lại';

  @override
  String get editItemDetails => 'Sửa chi tiết vật phẩm';

  @override
  String get lendItem => 'Cho mượn';

  @override
  String get deleteItem => 'Xóa vật phẩm';

  @override
  String get commonConsumable => 'Tiêu hao';

  @override
  String get stockHistory => 'Lịch sử tồn kho';

  @override
  String get outOfStockRestock => 'Hết hàng (nhập thêm)';

  @override
  String commonConsume(Object unit) {
    return 'Sử dụng ($unit)';
  }

  @override
  String get returnToStorage => 'Cất về nơi lưu trữ';

  @override
  String get takeOutToUse => 'Lấy ra sử dụng';

  @override
  String get itemCatalog => 'Danh mục vật phẩm';

  @override
  String get searchItemsBarcodesSerials => 'Tìm vật phẩm, mã vạch, số sê-ri...';

  @override
  String commonStored(Object count) {
    return 'Đang cất ($count)';
  }

  @override
  String inUse(Object count) {
    return 'Đang dùng ($count)';
  }

  @override
  String commonLent(Object count) {
    return 'Đã cho mượn ($count)';
  }

  @override
  String alertsExpiring(Object count) {
    return 'Cảnh báo / Sắp hết hạn ($count)';
  }

  @override
  String lowStock(Object count) {
    return 'Sắp hết hàng ($count)';
  }

  @override
  String get allStorageLocations => 'Tất cả vị trí lưu trữ';

  @override
  String get noMatchingItemsFound => 'Không tìm thấy vật phẩm phù hợp';

  @override
  String get noItemsFound => 'Không có vật phẩm nào';

  @override
  String get trySearchingWithAnotherName =>
      'Thử tìm bằng tên khác hoặc bỏ bộ lọc';

  @override
  String get tapAddItemAboveTo =>
      'Nhấn \"Thêm vật phẩm\" ở trên để thêm tài sản đầu tiên';

  @override
  String get itemMarkedAsReturned => 'Đã đánh dấu vật phẩm là đã trả';

  @override
  String get commonReturn => 'Trả lại';

  @override
  String get commonLend => 'Cho mượn';

  @override
  String get selectDestinationContainer => 'Chọn ngăn chứa đích';

  @override
  String get chooseContainerOrScanIts =>
      'Chọn ngăn chứa hoặc quét QR của nó để thêm vật phẩm';

  @override
  String get addItemHere => 'Thêm vật phẩm vào đây';

  @override
  String get lendingTracker => 'Theo dõi cho mượn';

  @override
  String get commonLoans => 'Khoản mượn';

  @override
  String get itemsHavePassedTheirExpected =>
      'Một số vật phẩm đã quá hạn trả dự kiến.';

  @override
  String commonActive(Object count) {
    return 'Đang mượn ($count)';
  }

  @override
  String commonHistory(Object count) {
    return 'Lịch sử ($count)';
  }

  @override
  String get noActiveLoans => 'Không có khoản mượn nào đang diễn ra';

  @override
  String get allYourItemsAreSafely =>
      'Tất cả vật phẩm của bạn đều đang được cất an toàn.';

  @override
  String get noLendingHistory => 'Chưa có lịch sử cho mượn';

  @override
  String get returnedItemsWillAppearHere =>
      'Các vật phẩm đã trả sẽ hiện ở đây.';

  @override
  String get unknownItem => 'Vật phẩm không xác định';

  @override
  String lentTo(Object borrowerName) {
    return 'Cho $borrowerName mượn';
  }

  @override
  String commonLent2(Object count) {
    return 'Ngày mượn: $count';
  }

  @override
  String commonDue(Object count) {
    return 'Hạn trả: $count';
  }

  @override
  String get markAsReturned => 'Đánh dấu đã trả';

  @override
  String get confirmItemReturn => 'Xác nhận trả vật phẩm';

  @override
  String get confirmReturn => 'Xác nhận đã trả';

  @override
  String get itemMarkedAsReturnedSuccessfully =>
      'Đã đánh dấu vật phẩm là đã trả';

  @override
  String get lendAnItem => 'Cho mượn vật phẩm';

  @override
  String get selectItemToLend => 'Chọn vật phẩm cho mượn';

  @override
  String get chooseAnAvailableItem => 'Chọn một vật phẩm có sẵn...';

  @override
  String get quantityToLend => 'Số lượng cho mượn';

  @override
  String get enterAQuantityGreaterThan => 'Nhập số lượng lớn hơn 0';

  @override
  String onlyInStock(Object quantity) {
    return 'Chỉ còn $quantity trong kho';
  }

  @override
  String get borrowerName => 'Tên người mượn';

  @override
  String get eGJohnDoe => 'VD: Nguyễn Văn A';

  @override
  String get pleaseEnterBorrowerName => 'Vui lòng nhập tên người mượn';

  @override
  String get borrowerContact => 'Liên hệ người mượn';

  @override
  String get phoneNumberOrEmailOptional =>
      'Số điện thoại hoặc email (không bắt buộc)';

  @override
  String get expectedReturnDate => 'Ngày hẹn trả';

  @override
  String get selectDueDateOptional => 'Chọn ngày hẹn trả (không bắt buộc)';

  @override
  String get commonNotes => 'Ghi chú';

  @override
  String get eGBorrowedForPhotography => 'VD: Mượn để chụp ảnh dự án';

  @override
  String get pleaseSelectAnItem => 'Vui lòng chọn một vật phẩm';

  @override
  String get itemMarkedAsLentSuccessfully => 'Đã ghi nhận cho mượn';

  @override
  String get saveLoan => 'Lưu khoản mượn';

  @override
  String signedInAs(Object email) {
    return 'Đã đăng nhập với $email';
  }

  @override
  String get googleAuthenticationFailed => 'Xác thực Google thất bại';

  @override
  String welcomeBack(Object userName) {
    return 'Chào mừng trở lại, $userName!';
  }

  @override
  String welcomeUser(Object userName) {
    return 'Chào mừng, $userName!';
  }

  @override
  String get authenticationFailed => 'Xác thực thất bại';

  @override
  String get signInToSyncYour =>
      'Đăng nhập để đồng bộ đồ đạc & tài sản trên mọi thiết bị';

  @override
  String get continueWithGoogle => 'Tiếp tục với Google';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get pleaseEnterYourName => 'Vui lòng nhập tên của bạn';

  @override
  String get emailAddress => 'Địa chỉ email';

  @override
  String get pleaseEnterYourEmail => 'Vui lòng nhập email';

  @override
  String get pleaseEnterAValidEmail => 'Vui lòng nhập email hợp lệ';

  @override
  String get commonPassword => 'Mật khẩu';

  @override
  String get showOrHidePassword => 'Hiện hoặc ẩn mật khẩu';

  @override
  String get passwordIsRequired => 'Vui lòng nhập mật khẩu';

  @override
  String get passwordMustBeAtLeast => 'Mật khẩu phải có ít nhất 8 ký tự';

  @override
  String get createAccount => 'Tạo tài khoản';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get alreadyHaveAnAccountSign => 'Đã có tài khoản? Đăng nhập';

  @override
  String get donTHaveAnAccount => 'Chưa có tài khoản? Đăng ký';

  @override
  String get byContinuingYouAgreeTo =>
      'Khi tiếp tục, bạn đồng ý với Điều khoản dịch vụ & Chính sách quyền riêng tư';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonContinue => 'Tiếp tục';

  @override
  String get boxQrCode => 'Mã QR của hộp';

  @override
  String commonLabel(Object label) {
    return 'Nhãn: $label';
  }

  @override
  String get printLabel => 'In nhãn';

  @override
  String get commonAll2 => 'Tất cả';

  @override
  String get commonStored2 => 'Đang cất';

  @override
  String get inUse2 => 'Đang dùng';

  @override
  String get commonLent3 => 'Đã cho mượn';

  @override
  String get commonPerishable => 'Dễ hỏng';

  @override
  String get searchItemsSerialBarcodeBoxes =>
      'Tìm vật phẩm, số sê-ri, mã vạch, hộp...';

  @override
  String get searchYourEntireInventory => 'Tìm trong toàn bộ kho đồ';

  @override
  String get findItemsByNameBarcode =>
      'Tìm vật phẩm theo tên, mã vạch, số sê-ri hoặc vị trí lưu trữ';

  @override
  String noResultsFor(Object query) {
    return 'Không có kết quả cho \"$query\"';
  }

  @override
  String get tryADifferentNameSerial => 'Thử tên, số sê-ri hoặc mã vạch khác';

  @override
  String storageLocations(Object count) {
    return 'Vị trí lưu trữ ($count)';
  }

  @override
  String commonItems(Object count) {
    return 'Vật phẩm ($count)';
  }

  @override
  String get developerOptionsActivated => 'Đã bật tùy chọn nhà phát triển!';

  @override
  String tapMoreTimesToUnlock(Object remaining) {
    return 'Nhấn thêm $remaining lần nữa để mở công cụ nhà phát triển';
  }

  @override
  String get commonSettings => 'Cài đặt';

  @override
  String get preferencesTaxonomyInventoryTools =>
      'Tùy chọn, phân loại & công cụ kho đồ';

  @override
  String get taxonomyCategories => 'PHÂN LOẠI & DANH MỤC';

  @override
  String get manageCategories => 'Quản lý danh mục';

  @override
  String get inventoryPreferences => 'TÙY CHỌN KHO ĐỒ';

  @override
  String get currencySymbol => 'Ký hiệu tiền tệ';

  @override
  String get usedForPurchasePricesValuation => 'Dùng cho giá mua & định giá';

  @override
  String get defaultItemUnit => 'Đơn vị mặc định';

  @override
  String get preFilledUnitForNewly => 'Đơn vị điền sẵn cho vật phẩm mới';

  @override
  String get expiryWarningWindow => 'Cảnh báo hết hạn trước';

  @override
  String get daysBeforeExpirationToTrigger =>
      'Số ngày trước hạn sử dụng để cảnh báo';

  @override
  String get warrantyWarningWindow => 'Cảnh báo bảo hành trước';

  @override
  String get daysBeforeWarrantyEndsTo =>
      'Số ngày trước khi hết bảo hành để cảnh báo';

  @override
  String get timeZone => 'Múi giờ';

  @override
  String get usedToDecideWhatToday =>
      'Dùng để xác định \"hôm nay\" khi tính cảnh báo';

  @override
  String get reportsInventoryAudit => 'BÁO CÁO & KIỂM KÊ';

  @override
  String get exportAllBoxBarcodesPdf => 'Xuất mã vạch tất cả hộp (PDF)';

  @override
  String get generatePrintablePdfStickerSheet =>
      'Tạo tệp PDF tem dán có mã QR và tên của các hộp để in';

  @override
  String get exportInventoryReport => 'Xuất báo cáo kho đồ';

  @override
  String get generateCopyFormattedSummaryOf =>
      'Tạo và sao chép bản tóm tắt toàn bộ tài sản';

  @override
  String get commonTrash => 'Thùng rác';

  @override
  String get restoreOrPermanentlyDeleteRemoved =>
      'Khôi phục hoặc xóa vĩnh viễn vật phẩm & vị trí đã xóa';

  @override
  String get inventoryHealthBreakdown => 'Tình trạng kho đồ';

  @override
  String get statusDistributionInStockLent =>
      'Phân bố trạng thái: Còn hàng, Đã cho mượn, Sắp hết, Hết hạn';

  @override
  String get developerOptionsBackendApi =>
      'TÙY CHỌN NHÀ PHÁT TRIỂN & API BACKEND';

  @override
  String get developerModeDeactivated => 'Đã tắt chế độ nhà phát triển';

  @override
  String get commonHide => 'Ẩn';

  @override
  String get applicationInfo => 'THÔNG TIN ỨNG DỤNG';

  @override
  String get applicationVersion => 'Phiên bản ứng dụng';

  @override
  String get designSystem => 'Hệ thống thiết kế';

  @override
  String get minimalCharcoalIosStyle => 'Charcoal tối giản (kiểu iOS)';

  @override
  String get qrBarcodeEngine => 'Bộ quét QR & mã vạch';

  @override
  String get storageArchitecture => 'Cấu trúc lưu trữ';

  @override
  String get hierarchicalMultiLevelTree => 'Cây phân cấp nhiều tầng';

  @override
  String get logOutSwitchAccount => 'Đăng xuất / Đổi tài khoản';

  @override
  String get deleteAccount => 'Xóa tài khoản';

  @override
  String get switchAccountLogin => 'Đổi tài khoản / Đăng nhập';

  @override
  String get editProfile => 'Sửa hồ sơ';

  @override
  String get logOut => 'Đăng xuất?';

  @override
  String get areYouSureYouWant =>
      'Bạn có chắc muốn đăng xuất? Bạn có thể đăng nhập lại bất cứ lúc nào bằng Google hoặc email.';

  @override
  String get unsyncedChanges => 'Thay đổi chưa đồng bộ';

  @override
  String get discardLogOut => 'Bỏ & đăng xuất';

  @override
  String get logOut2 => 'Đăng xuất';

  @override
  String get deleteAccount2 => 'Xóa tài khoản?';

  @override
  String get thisPermanentlyDeletesYourAccount =>
      'Thao tác này xóa vĩnh viễn tài khoản cùng toàn bộ hộp, vật phẩm, khoản mượn và ảnh của bạn. Không thể hoàn tác.';

  @override
  String get confirmDeletion => 'Xác nhận xóa';

  @override
  String get typeDeleteToConfirm => 'Nhập DELETE để xác nhận';

  @override
  String get deleteForever => 'Xóa vĩnh viễn';

  @override
  String get inventoryQuickMetrics => 'Số liệu nhanh';

  @override
  String get commonContainers => 'Ngăn chứa';

  @override
  String get totalAssets => 'Tổng tài sản';

  @override
  String get onLoan => 'Đang cho mượn';

  @override
  String get estValue => 'Giá trị ước tính';

  @override
  String couldNotRestore(Object name) {
    return 'Không thể khôi phục \"$name\"';
  }

  @override
  String get deletePermanently => 'Xóa vĩnh viễn?';

  @override
  String couldNotDelete(Object name) {
    return 'Không thể xóa \"$name\"';
  }

  @override
  String get emptyTrash => 'Dọn thùng rác?';

  @override
  String get everythingInTheTrashWill =>
      'Mọi thứ trong thùng rác sẽ bị xóa vĩnh viễn.';

  @override
  String get commonEmpty => 'Dọn sạch';

  @override
  String get couldNotEmptyTheTrash => 'Không thể dọn thùng rác';

  @override
  String get couldNotLoadTheTrash => 'Không thể tải thùng rác';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get trashIsEmpty => 'Thùng rác trống';

  @override
  String commonLocation(Object name) {
    return 'Vị trí · $name';
  }

  @override
  String commonItem2(Object quantity, Object unit) {
    return 'Vật phẩm · $quantity $unit';
  }

  @override
  String get commonRestore => 'Khôi phục';

  @override
  String get deletePermanently2 => 'Xóa vĩnh viễn';

  @override
  String get commonConfirm => 'Xác nhận';

  @override
  String noStorageBoxFoundWith(Object code) {
    return 'Không tìm thấy hộp nào có mã \"$code\". Vui lòng quét nhãn QR hợp lệ của hộp.';
  }

  @override
  String get selectTestBoxQrCode => 'Chọn mã QR hộp để thử';

  @override
  String get simulateScanningAPhysicalBox =>
      'Giả lập quét tem QR của hộp thật:';

  @override
  String get enterBoxLabelQr => 'Nhập nhãn hộp / QR';

  @override
  String get eGLocElectronicsBox => 'VD: loc_electronics_box';

  @override
  String get commonSubmit => 'Gửi';

  @override
  String get scanBoxQrCode => 'Quét mã QR của hộp';

  @override
  String get pointCameraAtTargetBox => 'Hướng camera vào tem của hộp cần quét';

  @override
  String get toggleFlash => 'Bật/tắt đèn flash';

  @override
  String get scanAgain => 'Quét lại';

  @override
  String get moveToThisBox => 'Chuyển vào hộp này';

  @override
  String get testWithPresets => 'Thử với mẫu có sẵn';

  @override
  String get enterCode => 'Nhập mã';

  @override
  String get boxScanTitle => 'Quét hộp';

  @override
  String get boxScanHint => 'Đặt mã QR vào trong khung để tự động quét.';

  @override
  String get pickFromGallery => 'Chọn từ thư viện ảnh';

  @override
  String get noQrInImage => 'Không tìm thấy mã QR trong ảnh này.';

  @override
  String get cutGuide => 'ĐƯỜNG CẮT';

  @override
  String get barcodeImageReady => 'Ảnh mã vạch đã sẵn sàng';

  @override
  String get highResolutionPngImageOf =>
      'Ảnh PNG độ phân giải cao của các mã QR hộp.';

  @override
  String get barcodeImageCaptured => 'Đã lưu ảnh mã vạch';

  @override
  String get commonDone => 'Xong';

  @override
  String get failedToCaptureBarcodeGrid => 'Không thể chụp bảng mã vạch';

  @override
  String get failedToGenerateImage => 'Không thể tạo ảnh';

  @override
  String get couldnTExportTheLabels => 'Không thể xuất nhãn. Vui lòng thử lại.';

  @override
  String get pdfGeneratedChooseSaveTo =>
      'Đã tạo PDF. Chọn \"Lưu vào Tệp\" hoặc chia sẻ.';

  @override
  String get couldnTExportThePdf => 'Không thể xuất PDF. Vui lòng thử lại.';

  @override
  String get couldnTOpenThePrint =>
      'Không thể mở bản xem trước khi in. Vui lòng thử lại.';

  @override
  String get exportAllBoxBarcodes => 'Xuất mã vạch tất cả hộp';

  @override
  String get boxNotFound => 'Không tìm thấy hộp';

  @override
  String get exportBoxBarcodes => 'Xuất mã vạch hộp';

  @override
  String get captureAndSaveBarcodeSheet =>
      'Chụp và lưu bảng mã vạch dưới dạng ảnh';

  @override
  String get saveImage => 'Lưu ảnh';

  @override
  String get thisContainer => 'Ngăn chứa này';

  @override
  String allContainers(Object count) {
    return 'Tất cả ngăn chứa ($count)';
  }

  @override
  String get printSpecsFormat => 'THÔNG SỐ / KHỔ IN';

  @override
  String get a4TomyDecal => 'Decal A4 Tomy';

  @override
  String get standardGridSheet => 'Tờ lưới tiêu chuẩn';

  @override
  String get thermal50x30mm => 'Tem nhiệt 50x30mm';

  @override
  String get singleRollLabel => 'Nhãn cuộn đơn';

  @override
  String get printPreview => 'Xem trước khi in';

  @override
  String get generatingPdf => 'Đang tạo PDF...';

  @override
  String get exportPdfSaveShare => 'Xuất PDF (Lưu/Chia sẻ)';

  @override
  String get tapToKeepYourVersion => 'Chạm để giữ bản của bạn hoặc bỏ đi';

  @override
  String get unresolvedChanges => 'Thay đổi chưa xử lý';

  @override
  String get nothingLeftToResolve => 'Không còn gì cần xử lý.';

  @override
  String get commonDiscard => 'Bỏ';

  @override
  String get keepMine => 'Giữ bản của tôi';

  @override
  String get commonClose => 'Đóng';

  @override
  String get recentItems => 'Vật phẩm gần đây';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get noItemsInInventoryYet => 'Chưa có vật phẩm nào';

  @override
  String get tapToAddYourFirst => 'Nhấn + để thêm vật phẩm đầu tiên';

  @override
  String get storageBox => 'Hộp lưu trữ';

  @override
  String cannotConnectToBackend(Object serverUrl) {
    return 'Không thể kết nối backend ($serverUrl)';
  }

  @override
  String get actionRequired => 'Cần xử lý';

  @override
  String get commonReview => 'Xem lại';

  @override
  String get commonLending => 'Cho mượn';

  @override
  String get noLoans => 'Không có khoản mượn';

  @override
  String get commonAlerts => 'Cảnh báo';

  @override
  String get allClear => 'Mọi thứ ổn';

  @override
  String get storageSpaces => 'Nơi lưu trữ';

  @override
  String get noStorageSpacesYet => 'Chưa có nơi lưu trữ nào';

  @override
  String get subContainerInLocation => 'Ngăn chứa con trong vị trí';

  @override
  String get primaryStorageSpace => 'Nơi lưu trữ chính';

  @override
  String get specificationsAttributes => 'Thông số & thuộc tính';

  @override
  String get commonManage => 'Quản lý';

  @override
  String get commonAdd => 'Thêm';

  @override
  String get noSpecificationsAddedYet => 'Chưa có thông số nào';

  @override
  String get addCustomDetailsLikeColor =>
      'Thêm chi tiết như Màu sắc, Kích thước, Thương hiệu hoặc Thông số.';

  @override
  String get addSpecification => 'Thêm thông số';

  @override
  String get customizeAttributesAndMetadataFor =>
      'Tùy chỉnh thuộc tính và thông tin của vật phẩm này.';

  @override
  String get currentSpecifications => 'THÔNG SỐ HIỆN TẠI';

  @override
  String commonRemoved(Object key) {
    return 'Đã xóa \"$key\"';
  }

  @override
  String get suggestedAttributes => 'THUỘC TÍNH GỢI Ý';

  @override
  String get editAttribute => 'SỬA THUỘC TÍNH';

  @override
  String get addAttribute => 'THÊM THUỘC TÍNH';

  @override
  String get attributeName => 'Tên thuộc tính';

  @override
  String get eGColorRamSize => 'VD: Màu sắc, RAM, Kích thước, Chất liệu';

  @override
  String get attributeValue => 'Giá trị thuộc tính';

  @override
  String get eGSpaceBlack16gb => 'VD: Đen không gian, 16GB, XL';

  @override
  String get pleaseEnterAnAttributeName => 'Vui lòng nhập tên thuộc tính';

  @override
  String get pleaseEnterAnAttributeValue => 'Vui lòng nhập giá trị thuộc tính';

  @override
  String savedAttribute(Object k) {
    return 'Đã lưu thuộc tính \"$k\"';
  }

  @override
  String get saveAttribute => 'Lưu thuộc tính';

  @override
  String get newCategory => 'Danh mục mới';

  @override
  String get createACustomCategoryFor =>
      'Tạo danh mục riêng cho tài sản của bạn';

  @override
  String get categoryName => 'Tên danh mục';

  @override
  String get eGPhotographyWatchesBoard => 'VD: Nhiếp ảnh, Đồng hồ, Board game';

  @override
  String get pleaseEnterACategoryName => 'Vui lòng nhập tên danh mục';

  @override
  String get categoryAlreadyExists => 'Danh mục đã tồn tại';

  @override
  String get addSelect => 'Thêm & chọn';

  @override
  String get overdueLoan => 'Khoản mượn quá hạn';

  @override
  String get currentlyLentOut => 'Đang cho mượn';

  @override
  String commonBorrower2(Object borrowerName) {
    return 'Người mượn: $borrowerName';
  }

  @override
  String commonContact(Object borrowerContact) {
    return 'Liên hệ: $borrowerContact';
  }

  @override
  String get commonChange => 'Đổi';

  @override
  String get unknownLocation => 'Vị trí không xác định';

  @override
  String get productHasExpired => 'Sản phẩm đã hết hạn!';

  @override
  String expiresSoonInDays(Object daysLeft) {
    return 'Sắp hết hạn sau $daysLeft ngày';
  }

  @override
  String freshDaysRemaining(Object daysLeft) {
    return 'Còn tốt • còn $daysLeft ngày';
  }

  @override
  String get lowStockWarning => 'Cảnh báo sắp hết hàng';

  @override
  String currentThreshold(
    Object qty,
    Object unit,
    Object minQty,
    Object unit2,
  ) {
    return 'Hiện có: $qty $unit • Ngưỡng: ≤ $minQty $unit2';
  }

  @override
  String get assetPurchaseInformation => 'Thông tin tài sản & mua hàng';

  @override
  String get purchasePrice2 => 'Giá mua';

  @override
  String get notRecorded => 'Chưa ghi nhận';

  @override
  String get purchaseDate => 'Ngày mua';

  @override
  String get lowStockAlertThreshold => 'Ngưỡng cảnh báo sắp hết';

  @override
  String get notTracked => 'Không theo dõi';

  @override
  String get barcodeUpcEan => 'Mã vạch (UPC/EAN)';

  @override
  String get warrantyExpired => 'Hết bảo hành';

  @override
  String get warrantyActive => 'Còn bảo hành';

  @override
  String get commonCopy => 'Sao chép';

  @override
  String copiedToClipboard(Object label) {
    return 'Đã sao chép $label vào bộ nhớ tạm';
  }

  @override
  String get addAttribute2 => 'Thêm thuộc tính';

  @override
  String get addCustomAttributesLikeColor =>
      'Thêm thuộc tính như Màu sắc, Kích thước, RAM hoặc Thương hiệu';

  @override
  String get commonRemove => 'Xóa';

  @override
  String get editSpecification => 'Sửa thông số';

  @override
  String get eGColorRamSize2 =>
      'VD: Màu sắc, RAM, Kích thước, Chất liệu, Cân nặng';

  @override
  String get eGSpaceBlack16gb2 => 'VD: Đen không gian, 16GB, XL, Da';

  @override
  String get saveSpecification => 'Lưu thông số';

  @override
  String get paperReceipt => 'Hóa đơn giấy';

  @override
  String get storeInvoice => 'Hóa đơn cửa hàng';

  @override
  String get warrantyCard => 'Phiếu bảo hành';

  @override
  String get addReceiptPhoto => 'Thêm ảnh hóa đơn';

  @override
  String get addProductPhoto => 'Thêm ảnh sản phẩm';

  @override
  String get commonCamera => 'Camera';

  @override
  String get commonGallery => 'Thư viện';

  @override
  String get orViaUrl => 'HOẶC QUA URL';

  @override
  String get imageUrl => 'URL ảnh';

  @override
  String get photoAdded => 'Đã thêm ảnh';

  @override
  String get addViaUrl => 'Thêm qua URL';

  @override
  String get orChooseSamplePhoto => 'Hoặc chọn ảnh mẫu';

  @override
  String get samplePhotoSelected => 'Đã chọn ảnh mẫu';

  @override
  String commonConsume2(Object name) {
    return 'Sử dụng: $name';
  }

  @override
  String currentStock(Object formattedCurrent, Object unit) {
    return 'Tồn kho hiện tại: $formattedCurrent $unit';
  }

  @override
  String get quantityToUse => 'Số lượng dùng:';

  @override
  String use1(Object unit) {
    return 'Dùng 1 $unit';
  }

  @override
  String use2(Object unit) {
    return 'Dùng 2 $unit';
  }

  @override
  String use5(Object unit) {
    return 'Dùng 5 $unit';
  }

  @override
  String get useAll => 'Dùng hết';

  @override
  String get willBeOutOfStock => 'Sẽ hết hàng sau khi dùng';

  @override
  String remainingAfterUse(Object formattedRemain, Object unit) {
    return 'Còn lại sau khi dùng: $formattedRemain $unit';
  }

  @override
  String get commonRestock => 'Nhập thêm';

  @override
  String usedRemaining(
    Object formattedConsume,
    Object unit,
    Object formattedRemain,
    Object unit2,
  ) {
    return 'Đã dùng $formattedConsume $unit. Còn lại: $formattedRemain $unit2';
  }

  @override
  String warningQuantityHasDroppedTo(Object minQuantity, Object unit) {
    return 'Cảnh báo: số lượng đã xuống mức tối thiểu (≤ $minQuantity $unit)';
  }

  @override
  String get confirmUse => 'Xác nhận sử dụng';

  @override
  String commonRestock2(Object name) {
    return 'Nhập thêm: $name';
  }

  @override
  String quantityToAdd(Object unit) {
    return 'Số lượng thêm ($unit)';
  }

  @override
  String addedTotal(
    Object addAmount,
    Object unit,
    Object formattedNew,
    Object unit2,
  ) {
    return 'Đã thêm $addAmount $unit. Tổng: $formattedNew $unit2';
  }

  @override
  String get confirmRestock => 'Xác nhận nhập thêm';

  @override
  String get commonRoot => 'Gốc';

  @override
  String storeDirectlyIn(Object name) {
    return 'Cất trực tiếp vào \"$name\"';
  }

  @override
  String get commonCurrent => 'Hiện tại';

  @override
  String get placeItemAtThisLevel =>
      'Đặt vật phẩm ở cấp này, không cho vào hộp con nào';

  @override
  String get chooseARoomShelfOr => 'Chọn phòng, kệ hoặc ngăn chứa';

  @override
  String get selectLocation => 'Chọn vị trí';

  @override
  String get scanQr => 'Quét QR';

  @override
  String get currentLocation => 'Vị trí hiện tại';

  @override
  String subContainersInside(Object count) {
    return 'Ngăn chứa con bên trong ($count)';
  }

  @override
  String noSubContainersInside(Object name) {
    return 'Không có ngăn chứa con trong \"$name\"';
  }

  @override
  String get noLocationsAvailable => 'Không có vị trí nào';

  @override
  String youCanSelectDirectlyAbove(Object name) {
    return 'Bạn có thể chọn trực tiếp \"$name\" ở trên.';
  }

  @override
  String get currentlySelectedLocation => 'Vị trí đang chọn';

  @override
  String get selectedStorageDestination => 'Nơi lưu trữ đã chọn';

  @override
  String get moveItemLocation => 'Di chuyển vật phẩm';

  @override
  String selectNewStorageDestinationFor(Object name) {
    return 'Chọn nơi lưu trữ mới cho \"$name\"';
  }

  @override
  String get confirmMove => 'Xác nhận di chuyển';

  @override
  String movedTo(Object name, Object name2) {
    return 'Đã chuyển \"$name\" tới \"$name2\"';
  }

  @override
  String get selectNewStorageDestinationFor2 =>
      'Chọn nơi lưu trữ mới cho vật phẩm';

  @override
  String youCanStoreDirectlyIn(Object name) {
    return 'Bạn có thể cất \"$name\" trực tiếp vào ngăn chứa này.';
  }

  @override
  String get itemIsAlreadyInThis => 'Vật phẩm đã ở vị trí này';

  @override
  String get targetDestination => 'Nơi đến';

  @override
  String get bulkMoveLocation => 'Di chuyển hàng loạt';

  @override
  String moveAndContents(Object name) {
    return 'Di chuyển \"$name\" và nội dung';
  }

  @override
  String allItemsAndNestedContainers(Object totalItems, Object totalSubBoxes) {
    return 'Toàn bộ $totalItems vật phẩm và $totalSubBoxes ngăn chứa con bên trong sẽ di chuyển cùng ngăn chứa này.';
  }

  @override
  String get selectDestination => 'Chọn nơi đến';

  @override
  String get rootLevelNoParentContainer => 'Cấp gốc (không có ngăn chứa cha)';

  @override
  String get topOfHierarchy => 'Đầu cây phân cấp';

  @override
  String movedSuccessfully(Object name) {
    return 'Đã di chuyển \"$name\"';
  }

  @override
  String get cannotMoveContainerIntoIts =>
      'Không thể chuyển ngăn chứa vào chính ngăn con của nó';

  @override
  String get serverEndpoint => 'Máy chủ';

  @override
  String get apiAuthentication => 'Xác thực API';

  @override
  String authenticatedAs(Object userName) {
    return 'Đã xác thực là $userName';
  }

  @override
  String get loginSwitch => 'Đăng nhập / Đổi tài khoản';

  @override
  String get syncWithServer => 'Đồng bộ với máy chủ';

  @override
  String get synchronizingBoxesItemsAlerts =>
      'Đang đồng bộ hộp, vật phẩm & cảnh báo...';

  @override
  String get pullLatestInventoryLendingRecords =>
      'Tải dữ liệu kho đồ & cho mượn mới nhất';

  @override
  String get successfullySynchronizedWithBackendServer =>
      'Đã đồng bộ với máy chủ';

  @override
  String get syncFailed => 'Đồng bộ thất bại';

  @override
  String get backendApiUrl => 'URL API backend';

  @override
  String get enterTheBackendBaseUrl =>
      'Nhập URL gốc của backend (mặc định: http://localhost:8080):';

  @override
  String serverUrlUpdatedTo(Object newUrl) {
    return 'Đã cập nhật URL máy chủ thành $newUrl';
  }

  @override
  String get saveConnect => 'Lưu & kết nối';

  @override
  String get usDollar => 'Đô la Mỹ';

  @override
  String get vietnameseDong => 'Đồng Việt Nam';

  @override
  String get commonEuro => 'Euro';

  @override
  String get britishPound => 'Bảng Anh';

  @override
  String get japaneseYen => 'Yên Nhật';

  @override
  String get selectCurrency => 'Chọn tiền tệ';

  @override
  String get appliedToPriceCalculationsAsset =>
      'Áp dụng cho tính giá & định giá tài sản';

  @override
  String currencyChangedTo(Object sym) {
    return 'Đã đổi tiền tệ thành $sym';
  }

  @override
  String get defaultMeasuringUnitWhenCreating =>
      'Đơn vị đo mặc định khi tạo vật phẩm mới';

  @override
  String defaultUnitSetTo(Object unit) {
    return 'Đã đặt đơn vị mặc định là \"$unit\"';
  }

  @override
  String get howManyDaysBeforeExpiration =>
      'Cảnh báo bạn trước hạn sử dụng bao nhiêu ngày';

  @override
  String alertWindowSetToDays(Object days) {
    return 'Đã đặt cảnh báo trước $days ngày';
  }

  @override
  String get howManyDaysBeforeWarranty =>
      'Cảnh báo bạn trước khi hết bảo hành bao nhiêu ngày';

  @override
  String warrantyWindowSetToDays(Object days) {
    return 'Đã đặt cảnh báo bảo hành trước $days ngày';
  }

  @override
  String get alertsTreatTodayInThis =>
      'Cảnh báo tính \"hôm nay\" theo múi giờ này';

  @override
  String timeZoneSetTo(Object tz) {
    return 'Đã đặt múi giờ thành $tz';
  }

  @override
  String get updateYourDisplayNameAnd =>
      'Cập nhật tên hiển thị và vai trò của bạn';

  @override
  String get displayName => 'Tên hiển thị';

  @override
  String get eGSaraWilson => 'VD: Nguyễn Thị B';

  @override
  String get roleDepartment => 'Vai trò / Bộ phận';

  @override
  String get eGAssetManagerHome => 'VD: Quản lý tài sản, Chủ nhà';

  @override
  String get profileUpdatedSuccessfully => 'Đã cập nhật hồ sơ';

  @override
  String get commonNew => 'Mới';

  @override
  String get searchCategories => 'Tìm danh mục...';

  @override
  String noCategoriesMatch(Object searchQuery) {
    return 'Không có danh mục nào khớp \"$searchQuery\"';
  }

  @override
  String get deleteCategory => 'Xóa danh mục';

  @override
  String deleteCategoryAnyItemsIn(Object cat) {
    return 'Xóa danh mục \"$cat\"? Các vật phẩm trong danh mục này sẽ chuyển sang \"General\".';
  }

  @override
  String categoryRemoved(Object cat) {
    return 'Đã xóa danh mục \"$cat\"';
  }

  @override
  String get addNewCategory => 'Thêm danh mục mới';

  @override
  String get enterACategoryNameFor => 'Nhập tên danh mục cho kho đồ của bạn';

  @override
  String get eGPhotographyBoardGames => 'VD: Nhiếp ảnh, Board game, Đồ cơ khí';

  @override
  String categoryCreated2(Object name) {
    return 'Đã tạo danh mục \"$name\"';
  }

  @override
  String get addCategory => 'Thêm danh mục';

  @override
  String get inventoryReport => 'Báo cáo kho đồ';

  @override
  String get generatedPlainTextInventoryStatus =>
      'Đã tạo báo cáo tình trạng kho đồ dạng văn bản';

  @override
  String get reportCopiedToClipboard => 'Đã sao chép báo cáo!';

  @override
  String get copyReportToClipboard => 'Sao chép báo cáo';

  @override
  String realTimeConditionBreakdownOf(Object total) {
    return 'Phân tích tình trạng thời gian thực của $total vật phẩm đang theo dõi';
  }

  @override
  String get storedInContainers => 'Đang cất trong ngăn chứa';

  @override
  String get inUseActive => 'Đang dùng';

  @override
  String get lentToBorrowers => 'Đã cho mượn';

  @override
  String expiringSoonD(Object expiryWarningDays) {
    return 'Sắp hết hạn (≤ $expiryWarningDays ngày)';
  }

  @override
  String get expiredAssets => 'Tài sản hết hạn';

  @override
  String get initialStock => 'Tồn đầu';

  @override
  String get commonRestocked => 'Nhập thêm';

  @override
  String get commonUsed => 'Đã dùng';

  @override
  String get commonDamaged => 'Hư hỏng';

  @override
  String get commonLost => 'Mất';

  @override
  String get commonCorrection => 'Điều chỉnh';

  @override
  String get commonMoved => 'Đã di chuyển';

  @override
  String get commonAdjusted => 'Đã chỉnh';

  @override
  String get couldNotLoadStockHistory => 'Không thể tải lịch sử tồn kho';

  @override
  String get noConsumptionDataYet => 'Chưa có dữ liệu tiêu thụ';

  @override
  String avgDayAboutDaysLeft(Object count, Object count2) {
    return 'TB $count/ngày · còn khoảng $count2 ngày';
  }

  @override
  String get noMovementsRecorded => 'Chưa ghi nhận biến động nào';

  @override
  String get thermalLabelPrint => 'In tem nhiệt';

  @override
  String get standardPrintableAdhesiveLabel => 'Nhãn dán in tiêu chuẩn';

  @override
  String get thermalLabelCopiedToClipboard => 'Đã sao chép tem nhiệt';

  @override
  String get copyId => 'Sao chép ID';

  @override
  String thermalLabelSentToPrinter(Object value) {
    return 'Đã gửi tem nhiệt tới máy in (${value}mm)';
  }

  @override
  String get commonInitializing => 'Đang khởi tạo...';

  @override
  String get youWereSignedOutOn =>
      'Bạn đã đăng xuất ở thiết bị khác. Vui lòng đăng nhập lại.';

  @override
  String get yourSessionHasExpiredPlease =>
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';

  @override
  String get connectingToServer => 'Đang kết nối máy chủ...';

  @override
  String get commonAuthenticating => 'Đang xác thực...';

  @override
  String get syncingInventory => 'Đang đồng bộ kho đồ...';

  @override
  String get commonReady => 'Sẵn sàng';

  @override
  String get couldnTSignInPlease => 'Không thể đăng nhập. Vui lòng thử lại.';

  @override
  String get couldnTSignInWith =>
      'Không thể đăng nhập bằng Google. Vui lòng thử lại.';

  @override
  String get couldnTCreateYourAccount =>
      'Không thể tạo tài khoản. Vui lòng thử lại.';

  @override
  String get couldNotReachTheServer =>
      'Không thể kết nối máy chủ. Hãy kiểm tra kết nối và thử lại.';

  @override
  String get cannotReachTheServer => 'Không thể kết nối máy chủ';

  @override
  String get couldnTSyncYourData =>
      'Không thể đồng bộ dữ liệu. Kéo xuống để thử lại.';

  @override
  String get thisWasChangedElsewhereShowing =>
      'Dữ liệu này đã được thay đổi ở nơi khác. Đang hiển thị bản mới nhất.';

  @override
  String commonManager(Object userName, Object userRole) {
    return 'Người quản lý: $userName ($userRole)';
  }

  @override
  String serverBackend(Object baseUrl) {
    return 'Máy chủ backend: $baseUrl';
  }

  @override
  String get endOfReport => 'Hết báo cáo';

  @override
  String get somethingWentWrongPleaseTry => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get incorrectEmailOrPassword => 'Email hoặc mật khẩu không đúng.';

  @override
  String get thatItemNoLongerExists => 'Vật phẩm này không còn tồn tại.';

  @override
  String get thisWasChangedSomewhereElse =>
      'Dữ liệu này đã được thay đổi ở nơi khác. Hãy làm mới rồi thử lại.';

  @override
  String get tooManyAttemptsPleaseWait =>
      'Thử quá nhiều lần. Vui lòng đợi một lát rồi thử lại.';

  @override
  String get theServerIsBusyRight =>
      'Máy chủ đang bận. Vui lòng thử lại sau ít phút.';

  @override
  String get canTReachTheServer =>
      'Không thể kết nối máy chủ. Hãy kiểm tra kết nối và thử lại.';

  @override
  String get reportTitle => 'BÁO CÁO TÌNH TRẠNG KHO ĐỒ';

  @override
  String reportGenerated(Object date) {
    return 'Tạo lúc: $date';
  }

  @override
  String get reportOverview => '1. THỐNG KÊ TỔNG QUAN:';

  @override
  String reportTotalContainers(Object count) {
    return '- Tổng số ngăn chứa: $count';
  }

  @override
  String reportTotalItems(Object count) {
    return '- Tổng số vật phẩm: $count';
  }

  @override
  String reportTotalValue(Object value) {
    return '- Tổng giá trị ước tính: $value';
  }

  @override
  String reportActiveLent(Object count) {
    return '- Vật phẩm đang cho mượn: $count';
  }

  @override
  String reportOverdueLent(Object count) {
    return '- Vật phẩm cho mượn quá hạn: $count';
  }

  @override
  String reportExpired(Object count) {
    return '- Vật phẩm hết hạn: $count';
  }

  @override
  String reportExpiringSoon(Object days, Object count) {
    return '- Sắp hết hạn (trong $days ngày): $count';
  }

  @override
  String get reportCategories => '2. PHÂN BỔ THEO DANH MỤC:';

  @override
  String reportCategoryLine(Object category, Object count) {
    return '- $category: $count vật phẩm';
  }

  @override
  String get reportCurrentItems => '3. VẬT PHẨM HIỆN CÓ:';

  @override
  String reportPrice(Object price) {
    return ' | Giá: $price';
  }

  @override
  String get reportNoLocation => 'Chưa có vị trí';

  @override
  String qtyValue(Object qty) {
    return 'SL: $qty';
  }

  @override
  String get storageTypeRoom => 'Phòng';

  @override
  String get storageTypeCabinet => 'Tủ / Tủ quần áo';

  @override
  String get storageTypeShelf => 'Kệ / Giá';

  @override
  String get storageTypeBox => 'Hộp / Thùng';

  @override
  String get storageTypeDrawer => 'Ngăn kéo';

  @override
  String get storageTypeOther => 'Ngăn chứa';

  @override
  String get statusStored => 'Đang cất';

  @override
  String get statusInUse => 'Đang dùng';

  @override
  String get statusLent => 'Đã cho mượn';

  @override
  String get statusBroken => 'Hỏng';

  @override
  String get statusDisposed => 'Đã thanh lý';

  @override
  String get statusLost => 'Mất';

  @override
  String heyName(Object name) {
    return 'Xin chào $name!';
  }

  @override
  String get heyFallbackName => 'bạn';

  @override
  String markReturnedBy(Object item, Object borrower) {
    return 'Đánh dấu \"$item\" đã được $borrower trả?\nTrạng thái sẽ chuyển về Đang cất.';
  }

  @override
  String leaveEmptyToLendAll(Object qty) {
    return 'Để trống để cho mượn tất cả (còn $qty trong kho)';
  }

  @override
  String get itemFallbackName => 'vật phẩm';

  @override
  String get createFirstLocation => 'Tạo vị trí đầu tiên';

  @override
  String get addFirstItem => 'Thêm món đồ đầu tiên';

  @override
  String get firstRoomsTitle => 'Bạn cất đồ ở đâu?';

  @override
  String get firstRoomsSubtitle =>
      'Chọn các phòng bạn có. Sau đó bạn có thể thêm tủ, kệ, hộp bên trong.';

  @override
  String get roomLivingRoom => 'Phòng khách';

  @override
  String get roomKitchen => 'Bếp';

  @override
  String get roomBedroom => 'Phòng ngủ';

  @override
  String get roomBathroom => 'Phòng tắm';

  @override
  String get roomGarage => 'Gara';

  @override
  String get roomOffice => 'Phòng làm việc';

  @override
  String get roomStorage => 'Kho';

  @override
  String createSelectedRooms(Object count) {
    return 'Tạo các phòng đã chọn ($count)';
  }

  @override
  String get addMyOwnLocation => 'Tự thêm vị trí';

  @override
  String locationsCreatedCount(Object count) {
    return 'Đã tạo $count vị trí';
  }

  @override
  String get flashlight => 'Đèn pin';

  @override
  String get discardChangesTitle => 'Bỏ các thay đổi?';

  @override
  String get discardChangesMessage =>
      'Bạn có thay đổi chưa lưu. Nếu rời đi bây giờ, các thay đổi sẽ mất.';

  @override
  String get moreDetails => 'Chi tiết thêm';

  @override
  String get scanBarcode => 'Quét mã vạch';

  @override
  String get createLocationHere => 'Tạo vị trí mới tại đây';

  @override
  String get locationNameHint => 'Tên vị trí';

  @override
  String lentOnDate(String date) {
    return 'Cho mượn ngày: $date';
  }

  @override
  String expectedReturnOn(String date) {
    return 'Hẹn trả: $date';
  }

  @override
  String expiryDateOn(String date) {
    return 'Hạn sử dụng: $date';
  }

  @override
  String validUntilDate(String date) {
    return 'Bảo hành đến: $date';
  }

  @override
  String daysLeftCount(int days) {
    return 'còn $days ngày';
  }

  @override
  String expiredAgoOn(int days, String date) {
    return 'Đã hết hạn $days ngày trước ($date)';
  }

  @override
  String expiresInOn(int days, String date) {
    return 'Còn $days ngày sẽ hết hạn ($date)';
  }

  @override
  String get tagOverdue => 'QUÁ HẠN';

  @override
  String get tagLent => 'ĐANG MƯỢN';

  @override
  String get tagReturned => 'ĐÃ TRẢ';

  @override
  String get tagLowStock => 'SẮP HẾT';

  @override
  String get tagExpired => 'HẾT HẠN';

  @override
  String expiresInShort(int days) {
    return 'Còn $days ngày hết hạn';
  }

  @override
  String inPlacePath(String path) {
    return 'Tại: $path';
  }

  @override
  String assetsTracked(int count) {
    return '$count món đồ đang theo dõi';
  }

  @override
  String itemsCountLabel(int count) {
    return '$count món đồ';
  }

  @override
  String nestedCountLabel(int count) {
    return '$count bên trong';
  }

  @override
  String subContainersCountLabel(int count) {
    return '$count ngăn con';
  }

  @override
  String get statusOnlineTag => 'TRỰC TUYẾN';

  @override
  String get statusOfflineTag => 'NGOẠI TUYẾN';

  @override
  String itemNowInUse(String name) {
    return '\"$name\" đang được sử dụng';
  }

  @override
  String get developerBadge => 'NHÀ PHÁT TRIỂN';

  @override
  String get splashTagline => 'Quản lý đồ đạc và tài sản thông minh';

  @override
  String get continueToApp => 'Vào ứng dụng →';

  @override
  String changesNeedAttention(int count) {
    return '$count thay đổi ngoại tuyến cần bạn xem lại';
  }

  @override
  String changesRejectedByServer(int count) {
    return 'Máy chủ đã từ chối $count thay đổi ngoại tuyến';
  }

  @override
  String opRejectedBecause(String operation, String reason) {
    return '$operation bị từ chối: $reason';
  }

  @override
  String get discardChangeTitle => 'Bỏ thay đổi này?';

  @override
  String get discardChangeMessage =>
      'Thay đổi của bạn sẽ bị bỏ và giữ nguyên bản trên máy chủ.';

  @override
  String get opCreateItem => 'Thêm vật phẩm';

  @override
  String get opUpdateItem => 'Sửa vật phẩm';

  @override
  String get opDeleteItem => 'Xóa vật phẩm';

  @override
  String get opMoveItem => 'Di chuyển vật phẩm';

  @override
  String get opChangeQuantity => 'Đổi số lượng';

  @override
  String get opCreateBox => 'Thêm vị trí';

  @override
  String get opUpdateBox => 'Sửa vị trí';

  @override
  String get opMoveBox => 'Di chuyển vị trí';

  @override
  String get opDeleteBox => 'Xóa vị trí';

  @override
  String get opLend => 'Cho mượn';

  @override
  String get opReturnLoan => 'Nhận trả';

  @override
  String get opCreateCategory => 'Thêm danh mục';

  @override
  String get opDeleteCategory => 'Xóa danh mục';

  @override
  String get opUpdateSettings => 'Đổi cài đặt';
}
