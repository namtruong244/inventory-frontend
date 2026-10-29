// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get scanTitle => 'Scan QR & Barcode';

  @override
  String scanFoundContainer(String name) {
    return 'Container found: \"$name\"';
  }

  @override
  String scanFoundItem(String name) {
    return 'Item found: \"$name\"';
  }

  @override
  String get scanOpenDetailsPrompt => 'Open its details now?';

  @override
  String get scanOpen => 'Open';

  @override
  String get scanKeepScanning => 'Keep Scanning';

  @override
  String scanUnknownTitle(String code) {
    return 'Scanned Code: $code';
  }

  @override
  String get scanUnknownMessage =>
      'No storage box or item currently matches this code. Would you like to create a new item with this barcode?';

  @override
  String get scanAddNewItem => 'Add New Item';

  @override
  String get scanPickLocationTitle => 'Where is it stored?';

  @override
  String get scanPickLocationSubtitle => 'Pick the location for the new item';

  @override
  String get scanPickLocationConfirm => 'Use This Location';

  @override
  String get scanModeLocation => 'Location QR';

  @override
  String get scanModeProduct => 'Product Barcode';

  @override
  String get scanHintProduct =>
      'Scan product barcode (UPC/EAN) to auto-fill or search in inventory';

  @override
  String get scanHintLocation =>
      'Point camera at container QR code to open details and view all contents';

  @override
  String get scanManualTitle => 'Enter Code Manually';

  @override
  String get scanManualLabel => 'Label ID or Barcode';

  @override
  String get settingsAppearanceHeader => 'APPEARANCE & LANGUAGE';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSubtitle => 'Light or dark appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle =>
      'Screens already translated switch language immediately';

  @override
  String get languageSystem => 'System';

  @override
  String get settingsScannerHeader => 'SCANNER & RECOGNITION';

  @override
  String get settingsAlertsHeader => 'ALERTS';

  @override
  String get settingsVibrate => 'Vibration on Scan';

  @override
  String get settingsVibrateSubtitle =>
      'Haptic feedback when QR/Barcode detected';

  @override
  String get settingsSound => 'Sound Feedback';

  @override
  String get settingsSoundSubtitle =>
      'Play a click sound when a scan succeeds (this device only)';

  @override
  String get settingsAutoOpen => 'Auto-Open Details';

  @override
  String get settingsAutoOpenSubtitle =>
      'Off: ask before opening the matched container/item';

  @override
  String get settingsExpiring => 'Expiring Items';

  @override
  String get settingsExpiringSubtitle =>
      'Count expired and expiring items in the in-app alert badge (no push notifications yet)';

  @override
  String get settingsOverdue => 'Overdue Loans';

  @override
  String get settingsOverdueSubtitle =>
      'Count overdue loans in the in-app alert badge (no push notifications yet)';

  @override
  String get settingsLowStock => 'Low Stock';

  @override
  String get settingsLowStockSubtitle =>
      'Count items below their minimum quantity in the in-app alert badge';

  @override
  String get trashConfirmItemTitle => 'Move to Trash?';

  @override
  String get trashConfirmBoxTitle => 'Move location to Trash?';

  @override
  String trashConfirmMessage(String name, int days) {
    return '\"$name\" will be moved to Trash. You can restore it within $days days.';
  }

  @override
  String trashConfirmBoxMessage(String name, int days) {
    return '\"$name\" and everything inside it will be moved to Trash. You can restore them within $days days.';
  }

  @override
  String get trashMoveAction => 'Move to Trash';

  @override
  String trashMovedToast(String name) {
    return '\"$name\" moved to Trash';
  }

  @override
  String get trashUndo => 'Undo';

  @override
  String trashRestoredToast(String name) {
    return '\"$name\" restored';
  }

  @override
  String trashRestoreFailed(String name) {
    return 'Could not restore \"$name\". Try from Trash in Settings.';
  }

  @override
  String get syncOffline => 'Offline: showing saved data';

  @override
  String get syncUnsynced => 'Changes not synced yet';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting to sync',
      one: '1 change waiting to sync',
      zero: 'No changes waiting',
    );
    return '$_temp0';
  }

  @override
  String syncNeedsAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count need your attention',
      one: '1 needs your attention',
    );
    return '$_temp0';
  }

  @override
  String get syncSheetTitle => 'Sync status';

  @override
  String get syncOfflineBody =>
      'You are offline. Your changes are saved on this device and will upload automatically when the server is reachable.';

  @override
  String get syncOnlineBody => 'Some changes have not reached the server yet.';

  @override
  String get syncRejectedTitle => 'Rejected by the server';

  @override
  String get syncDismiss => 'Dismiss';

  @override
  String get syncNow => 'Sync now';

  @override
  String get lifecycleAlerts => 'Lifecycle & Alerts';

  @override
  String get allGood => 'All Good!';

  @override
  String get noItemsAreExpiredExpiring =>
      'No items are expired, expiring soon, or overdue.';

  @override
  String get expiredItems => 'Expired Items';

  @override
  String get expiringSoonPerishables => 'Expiring Soon (Perishables)';

  @override
  String get warrantiesEndingSoon => 'Warranties Ending Soon';

  @override
  String get overdueBorrowedItems => 'Overdue Borrowed Items';

  @override
  String get lowStockWarnings => 'Low Stock Warnings';

  @override
  String get commonStorage => 'Storage';

  @override
  String onlyRemainingThreshold(
    Object qty,
    Object unit,
    Object minQty,
    Object unit2,
  ) {
    return 'Only $qty $unit remaining (Threshold: ≤ $minQty $unit2)';
  }

  @override
  String get viewDetails => 'View details';

  @override
  String warrantyEndsInDays(Object daysLeft) {
    return 'Warranty ends in $daysLeft days';
  }

  @override
  String get borrowedItem => 'Borrowed Item';

  @override
  String commonBorrower(Object borrowerName, Object borrowerContact) {
    return 'Borrower: $borrowerName • $borrowerContact';
  }

  @override
  String locationUpdatedSuccessfully(Object boxName) {
    return 'Location \"$boxName\" updated successfully';
  }

  @override
  String locationCreatedSuccessfully(Object boxName) {
    return 'Location \"$boxName\" created successfully';
  }

  @override
  String get pleaseEnterAValidLocation => 'Please enter a valid location name';

  @override
  String get editLocation => 'Edit Location';

  @override
  String get createRootLocation => 'Create Root Location';

  @override
  String get createNestedContainer => 'Create Nested Container';

  @override
  String get commonDelete => 'Delete';

  @override
  String couldNotDeletePleaseTry(Object boxName) {
    return 'Could not delete \"$boxName\". Please try again.';
  }

  @override
  String get storageType => 'Storage Type';

  @override
  String get commonName => 'Name';

  @override
  String get eGLivingRoomOak =>
      'e.g. Living Room, Oak Bookshelf, Electronics Box';

  @override
  String get pleaseEnterAName => 'Please enter a name';

  @override
  String get commonDescription => 'Description';

  @override
  String get eGUpperShelfLeft =>
      'e.g. Upper shelf, left side near window (Optional)';

  @override
  String get parentContainer => 'Parent Container';

  @override
  String get qrLabelId => 'QR Label ID';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get saveLocation => 'Save Location';

  @override
  String get locationNotFound => 'Location not found';

  @override
  String get exportBarcodes => 'Export Barcodes';

  @override
  String get moreOptions => 'More Options';

  @override
  String get showQrCode => 'Show QR code';

  @override
  String get commonOverview => 'Overview';

  @override
  String boxSummary(int items, int nested) {
    String _temp0 = intl.Intl.pluralLogic(
      items,
      locale: localeName,
      other: '$items total items',
      one: '1 total item',
    );
    return '$_temp0 • $nested nested';
  }

  @override
  String nestedContainers(Object count) {
    return 'Nested Containers ($count)';
  }

  @override
  String get addContainer => 'Add Container';

  @override
  String get addContainerInside => 'Add Container Inside';

  @override
  String couldNotDeletePleaseTry2(Object name) {
    return 'Could not delete \"$name\". Please try again.';
  }

  @override
  String itemsInThisContainer(Object count) {
    return 'Items in this container ($count)';
  }

  @override
  String get addItem => 'Add Item';

  @override
  String get noDirectItemsStoredHere => 'No direct items stored here';

  @override
  String get moveLocation => 'Move Location';

  @override
  String get printThermalLabel => 'Print Thermal Label';

  @override
  String get viewFullQrCode => 'View Full QR Code';

  @override
  String get deleteLocation => 'Delete Location';

  @override
  String get storageHierarchy => 'Storage Hierarchy';

  @override
  String get exportAllQrCodes => 'Export all QR codes';

  @override
  String get newLocation => 'New Location';

  @override
  String get searchLocationsRoomsContainers =>
      'Search locations, rooms, containers...';

  @override
  String commonAll(Object count) {
    return 'All ($count)';
  }

  @override
  String commonRooms(Object count) {
    return 'Rooms ($count)';
  }

  @override
  String cabinetsShelves(Object count) {
    return 'Cabinets & Shelves ($count)';
  }

  @override
  String boxesDrawers(Object count) {
    return 'Boxes & Drawers ($count)';
  }

  @override
  String get switchToFlatList => 'Switch to Flat List';

  @override
  String get switchToTreeView => 'Switch to Tree View';

  @override
  String get expandAll => 'Expand all';

  @override
  String get collapseAll => 'Collapse all';

  @override
  String get noLocationsYet => 'No locations yet';

  @override
  String get tapNewLocationAboveTo =>
      'Tap \"New Location\" above to create your first room or box';

  @override
  String get noMatchingLocationsFound => 'No matching locations found';

  @override
  String get trySearchingWithADifferent =>
      'Try searching with a different name or label';

  @override
  String get commonMove => 'Move';

  @override
  String get commonEdit => 'Edit';

  @override
  String get addSubContainer => 'Add sub-container';

  @override
  String get commonPath => 'Path: ';

  @override
  String get trackManageYourInventory => 'Track & manage\nyour inventory!';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonHome => 'Home';

  @override
  String get commonBox => 'Box';

  @override
  String get commonItem => 'Item';

  @override
  String get commonSetting => 'Setting';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String categoryCreated(Object created) {
    return 'Category \"$created\" created';
  }

  @override
  String itemUpdatedSuccessfully(Object itemName) {
    return 'Item \"$itemName\" updated successfully';
  }

  @override
  String itemAddedSuccessfully(Object itemName) {
    return 'Item \"$itemName\" added successfully';
  }

  @override
  String get pleaseEnterAValidQuantity => 'Enter a valid quantity (0 or more)';

  @override
  String get pleaseFixTheHighlightedFields =>
      'Please fix the highlighted fields';

  @override
  String get couldnTUploadThePhoto =>
      'Couldn\'t upload the photo. Check your connection and try again.';

  @override
  String get editItem => 'Edit Item';

  @override
  String get newItem => 'New Item';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCreate => 'Create';

  @override
  String get productPhotos => 'Product Photos';

  @override
  String get receiptsWarrantyProof => 'Receipts & Warranty Proof';

  @override
  String get saveItem => 'Save Item';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get itemName => 'Item Name';

  @override
  String get eGMacbookProFirst => 'e.g. MacBook Pro, First Aid Kit, USB Cable';

  @override
  String get pleaseEnterItemName => 'Please enter item name';

  @override
  String get commonCategory => 'Category';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get tapToChangeCategory => 'Tap to change category';

  @override
  String get commonQuantity => 'Quantity';

  @override
  String get commonUnit => 'Unit';

  @override
  String get selectUnit => 'Select Unit';

  @override
  String get lowStockAlertThresholdOptional =>
      'Low Stock Alert Threshold (Optional)';

  @override
  String get eG2AlertWhen => 'e.g. 2 (Alert when quantity ≤ this number)';

  @override
  String get storageLocation => 'Storage Location';

  @override
  String get selectStorageContainer => 'Select Storage Container';

  @override
  String get commonUnassigned => 'Unassigned';

  @override
  String get colorConditionAccessoriesOptional =>
      'Color, condition, accessories (Optional)';

  @override
  String get consumableItem => 'Consumable Item';

  @override
  String get consumableItemsBatteriesMasksFood =>
      'Consumable items (batteries, masks, food, medicine...)';

  @override
  String get assetStatus => 'Asset Status';

  @override
  String get assetWarrantyDetails => 'Asset & Warranty Details';

  @override
  String purchasePrice(Object currency) {
    return 'Purchase Price ($currency)';
  }

  @override
  String get serialNumber => 'Serial Number';

  @override
  String get productBarcodeUpcEan => 'Product Barcode (UPC / EAN)';

  @override
  String get scanOrEnterProductBarcode => 'Scan or enter product barcode';

  @override
  String get warrantyExpiry => 'Warranty Expiry';

  @override
  String get perishableExpiry => 'Perishable Expiry';

  @override
  String get receiptCaptured => 'Receipt captured';

  @override
  String get photoCaptured => 'Photo captured';

  @override
  String get cameraIsnTAvailableCheck =>
      'Camera isn\'t available. Check the app\'s camera permission.';

  @override
  String get receiptSelected => 'Receipt selected';

  @override
  String get photoSelected => 'Photo selected';

  @override
  String get couldnTOpenYourPhotos =>
      'Couldn\'t open your photos. Check the app\'s photo permission.';

  @override
  String get commonCover => 'Cover';

  @override
  String get notSet => 'Not set';

  @override
  String get selectStorageLocation => 'Select Storage Location';

  @override
  String get chooseContainerOrScanQr => 'Choose container or scan QR to assign';

  @override
  String get setLocation => 'Set Location';

  @override
  String returnedToStorage(Object name) {
    return 'Returned \"$name\" to storage';
  }

  @override
  String returnedToStorage2(Object name, Object boxName) {
    return 'Returned \"$name\" to storage$boxName';
  }

  @override
  String movedBackToStorage(Object name) {
    return 'Moved \"$name\" back to storage';
  }

  @override
  String get itemNotFoundOrHas => 'Item not found or has been deleted';

  @override
  String get goBack => 'Go Back';

  @override
  String get editItemDetails => 'Edit Item Details';

  @override
  String get lendItem => 'Lend Item';

  @override
  String get deleteItem => 'Delete Item';

  @override
  String get commonConsumable => 'Consumable';

  @override
  String get stockHistory => 'Stock history';

  @override
  String get outOfStockRestock => 'Out of Stock (Restock)';

  @override
  String commonConsume(Object unit) {
    return 'Consume ($unit)';
  }

  @override
  String get returnToStorage => 'Return to Storage';

  @override
  String get takeOutToUse => 'Take Out to Use';

  @override
  String get itemCatalog => 'Item Catalog';

  @override
  String get searchItemsBarcodesSerials => 'Search items, barcodes, serials...';

  @override
  String commonStored(Object count) {
    return 'Stored ($count)';
  }

  @override
  String inUse(Object count) {
    return 'In Use ($count)';
  }

  @override
  String commonLent(Object count) {
    return 'Lent ($count)';
  }

  @override
  String alertsExpiring(Object count) {
    return 'Alerts / Expiring ($count)';
  }

  @override
  String lowStock(Object count) {
    return 'Low Stock ($count)';
  }

  @override
  String get allStorageLocations => 'All Storage Locations';

  @override
  String get noMatchingItemsFound => 'No matching items found';

  @override
  String get noItemsFound => 'No items found';

  @override
  String get trySearchingWithAnotherName =>
      'Try searching with another name or clearing filters';

  @override
  String get tapAddItemAboveTo =>
      'Tap \"Add Item\" above to catalogue your first asset';

  @override
  String get itemMarkedAsReturned => 'Item marked as returned';

  @override
  String get commonReturn => 'Return';

  @override
  String get commonLend => 'Lend';

  @override
  String get selectDestinationContainer => 'Select Destination Container';

  @override
  String get chooseContainerOrScanIts =>
      'Choose container or scan its QR to add item';

  @override
  String get addItemHere => 'Add Item Here';

  @override
  String get lendingTracker => 'Lending Tracker';

  @override
  String get commonLoans => 'Loans';

  @override
  String get itemsHavePassedTheirExpected =>
      'Items have passed their expected return date.';

  @override
  String commonActive(Object count) {
    return 'Active ($count)';
  }

  @override
  String commonHistory(Object count) {
    return 'History ($count)';
  }

  @override
  String get noActiveLoans => 'No active loans';

  @override
  String get allYourItemsAreSafely => 'All your items are safely in storage.';

  @override
  String get noLendingHistory => 'No lending history';

  @override
  String get returnedItemsWillAppearHere => 'Returned items will appear here.';

  @override
  String get unknownItem => 'Unknown Item';

  @override
  String lentTo(Object borrowerName) {
    return 'Lent to $borrowerName';
  }

  @override
  String commonLent2(Object count) {
    return 'Lent: $count';
  }

  @override
  String commonDue(Object count) {
    return 'Due: $count';
  }

  @override
  String get markAsReturned => 'Mark as Returned';

  @override
  String get confirmItemReturn => 'Confirm Item Return';

  @override
  String get confirmReturn => 'Confirm Return';

  @override
  String get itemMarkedAsReturnedSuccessfully =>
      'Item marked as returned successfully';

  @override
  String get lendAnItem => 'Lend an Item';

  @override
  String get selectItemToLend => 'Select Item to Lend';

  @override
  String get chooseAnAvailableItem => 'Choose an available item...';

  @override
  String get quantityToLend => 'Quantity to lend';

  @override
  String get enterAQuantityGreaterThan => 'Enter a quantity greater than 0';

  @override
  String onlyInStock(Object quantity) {
    return 'Only $quantity in stock';
  }

  @override
  String get borrowerName => 'Borrower Name';

  @override
  String get eGJohnDoe => 'e.g. John Doe';

  @override
  String get pleaseEnterBorrowerName => 'Please enter borrower name';

  @override
  String get borrowerContact => 'Borrower Contact';

  @override
  String get phoneNumberOrEmailOptional => 'Phone number or email (Optional)';

  @override
  String get expectedReturnDate => 'Expected Return Date';

  @override
  String get selectDueDateOptional => 'Select due date (Optional)';

  @override
  String get commonNotes => 'Notes';

  @override
  String get eGBorrowedForPhotography =>
      'e.g. Borrowed for photography project';

  @override
  String get pleaseSelectAnItem => 'Please select an item';

  @override
  String get itemMarkedAsLentSuccessfully => 'Item marked as lent successfully';

  @override
  String get saveLoan => 'Save Loan';

  @override
  String signedInAs(Object email) {
    return 'Signed in as $email';
  }

  @override
  String get googleAuthenticationFailed => 'Google authentication failed';

  @override
  String welcomeBack(Object userName) {
    return 'Welcome back, $userName!';
  }

  @override
  String welcomeUser(Object userName) {
    return 'Welcome, $userName!';
  }

  @override
  String get authenticationFailed => 'Authentication failed';

  @override
  String get signInToSyncYour =>
      'Sign in to sync your inventory & assets across devices';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get fullName => 'Full Name';

  @override
  String get pleaseEnterYourName => 'Please enter your name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get pleaseEnterYourEmail => 'Please enter your email';

  @override
  String get pleaseEnterAValidEmail => 'Please enter a valid email';

  @override
  String get commonPassword => 'Password';

  @override
  String get showOrHidePassword => 'Show or hide password';

  @override
  String get passwordIsRequired => 'Password is required';

  @override
  String get passwordMustBeAtLeast => 'Password must be at least 8 characters';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signIn => 'Sign In';

  @override
  String get alreadyHaveAnAccountSign => 'Already have an account? Sign in';

  @override
  String get donTHaveAnAccount => 'Don\'t have an account? Sign up';

  @override
  String get byContinuingYouAgreeTo =>
      'By continuing, you agree to our Terms of Service & Privacy Policy';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonContinue => 'Continue';

  @override
  String get boxQrCode => 'Box QR Code';

  @override
  String commonLabel(Object label) {
    return 'Label: $label';
  }

  @override
  String get printLabel => 'Print Label';

  @override
  String get commonAll2 => 'All';

  @override
  String get commonStored2 => 'Stored';

  @override
  String get inUse2 => 'In Use';

  @override
  String get commonLent3 => 'Lent';

  @override
  String get commonPerishable => 'Perishable';

  @override
  String get searchItemsSerialBarcodeBoxes =>
      'Search items, serial, barcode, boxes...';

  @override
  String get searchYourEntireInventory => 'Search your entire inventory';

  @override
  String get findItemsByNameBarcode =>
      'Find items by name, barcode, serial number, or storage location';

  @override
  String noResultsFor(Object query) {
    return 'No results for \"$query\"';
  }

  @override
  String get tryADifferentNameSerial =>
      'Try a different name, serial number, or barcode';

  @override
  String storageLocations(Object count) {
    return 'Storage Locations ($count)';
  }

  @override
  String commonItems(Object count) {
    return 'Items ($count)';
  }

  @override
  String get developerOptionsActivated => 'Developer options activated!';

  @override
  String tapMoreTimesToUnlock(Object remaining) {
    return 'Tap $remaining more times to unlock developer tools';
  }

  @override
  String get commonSettings => 'Settings';

  @override
  String get preferencesTaxonomyInventoryTools =>
      'Preferences, taxonomy & inventory tools';

  @override
  String get taxonomyCategories => 'TAXONOMY & CATEGORIES';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get inventoryPreferences => 'INVENTORY PREFERENCES';

  @override
  String get currencySymbol => 'Currency Symbol';

  @override
  String get usedForPurchasePricesValuation =>
      'Used for purchase prices & valuation';

  @override
  String get defaultItemUnit => 'Default Item Unit';

  @override
  String get preFilledUnitForNewly => 'Pre-filled unit for newly created items';

  @override
  String get expiryWarningWindow => 'Expiry Warning Window';

  @override
  String get daysBeforeExpirationToTrigger =>
      'Days before expiration to trigger alert';

  @override
  String get warrantyWarningWindow => 'Warranty Warning Window';

  @override
  String get daysBeforeWarrantyEndsTo =>
      'Days before warranty ends to trigger alert';

  @override
  String get timeZone => 'Time Zone';

  @override
  String get usedToDecideWhatToday =>
      'Used to decide what \"today\" means for alerts';

  @override
  String get reportsInventoryAudit => 'REPORTS & INVENTORY AUDIT';

  @override
  String get exportAllBoxBarcodesPdf => 'Export All Box Barcodes (PDF)';

  @override
  String get generatePrintablePdfStickerSheet =>
      'Generate printable PDF sticker sheet with box QR codes & names';

  @override
  String get exportInventoryReport => 'Export Inventory Report';

  @override
  String get generateCopyFormattedSummaryOf =>
      'Generate & copy formatted summary of all assets';

  @override
  String get commonTrash => 'Trash';

  @override
  String get restoreOrPermanentlyDeleteRemoved =>
      'Restore or permanently delete removed items & locations';

  @override
  String get inventoryHealthBreakdown => 'Inventory Health Breakdown';

  @override
  String get statusDistributionInStockLent =>
      'Status distribution: In Stock, Lent, Low Stock, Expired';

  @override
  String get developerOptionsBackendApi => 'DEVELOPER OPTIONS & BACKEND API';

  @override
  String get developerModeDeactivated => 'Developer mode deactivated';

  @override
  String get commonHide => 'Hide';

  @override
  String get applicationInfo => 'APPLICATION INFO';

  @override
  String get applicationVersion => 'Application Version';

  @override
  String get designSystem => 'Design System';

  @override
  String get minimalCharcoalIosStyle => 'Minimal Charcoal (iOS Style)';

  @override
  String get qrBarcodeEngine => 'QR & Barcode Engine';

  @override
  String get storageArchitecture => 'Storage Architecture';

  @override
  String get hierarchicalMultiLevelTree => 'Hierarchical Multi-Level Tree';

  @override
  String get logOutSwitchAccount => 'Log Out / Switch Account';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get switchAccountLogin => 'Switch Account / Login';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get logOut => 'Log Out?';

  @override
  String get areYouSureYouWant =>
      'Are you sure you want to log out? You can sign back in anytime using Google or your email.';

  @override
  String get unsyncedChanges => 'Unsynced changes';

  @override
  String get discardLogOut => 'Discard & Log Out';

  @override
  String get logOut2 => 'Log Out';

  @override
  String get deleteAccount2 => 'Delete Account?';

  @override
  String get thisPermanentlyDeletesYourAccount =>
      'This permanently deletes your account and all your boxes, items, loans and photos. This cannot be undone.';

  @override
  String get confirmDeletion => 'Confirm deletion';

  @override
  String get typeDeleteToConfirm => 'Type DELETE to confirm';

  @override
  String get deleteForever => 'Delete Forever';

  @override
  String get inventoryQuickMetrics => 'Inventory Quick Metrics';

  @override
  String get commonContainers => 'Containers';

  @override
  String get totalAssets => 'Total Assets';

  @override
  String get onLoan => 'On Loan';

  @override
  String get estValue => 'Est. Value';

  @override
  String couldNotRestore(Object name) {
    return 'Could not restore \"$name\"';
  }

  @override
  String get deletePermanently => 'Delete permanently?';

  @override
  String couldNotDelete(Object name) {
    return 'Could not delete \"$name\"';
  }

  @override
  String get emptyTrash => 'Empty trash?';

  @override
  String get everythingInTheTrashWill =>
      'Everything in the trash will be removed for good.';

  @override
  String get commonEmpty => 'Empty';

  @override
  String get couldNotEmptyTheTrash => 'Could not empty the trash';

  @override
  String get couldNotLoadTheTrash => 'Could not load the trash';

  @override
  String get commonRetry => 'Retry';

  @override
  String get trashIsEmpty => 'Trash is empty';

  @override
  String commonLocation(Object name) {
    return 'Location · $name';
  }

  @override
  String commonItem2(Object quantity, Object unit) {
    return 'Item · $quantity $unit';
  }

  @override
  String get commonRestore => 'Restore';

  @override
  String get deletePermanently2 => 'Delete permanently';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String noStorageBoxFoundWith(Object code) {
    return 'No storage box found with code \"$code\". Please scan a valid box QR label.';
  }

  @override
  String get selectTestBoxQrCode => 'Select Test Box QR Code';

  @override
  String get simulateScanningAPhysicalBox =>
      'Simulate scanning a physical box QR sticker:';

  @override
  String get enterBoxLabelQr => 'Enter Box Label / QR';

  @override
  String get eGLocElectronicsBox => 'e.g. loc_electronics_box';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get scanBoxQrCode => 'Scan Box QR Code';

  @override
  String get pointCameraAtTargetBox => 'Point camera at target box sticker';

  @override
  String get toggleFlash => 'Toggle flash';

  @override
  String get scanAgain => 'Scan Again';

  @override
  String get moveToThisBox => 'Move to this Box';

  @override
  String get testWithPresets => 'Test with Presets';

  @override
  String get enterCode => 'Enter Code';

  @override
  String get switchCamera => 'Switch camera';

  @override
  String get boxScanTitle => 'Box Scan';

  @override
  String get boxScanHint =>
      'Place the QR code inside the frame to scan automatically.';

  @override
  String get pickFromGallery => 'Pick from gallery';

  @override
  String get noQrInImage => 'No QR code found in this image.';

  @override
  String get cutGuide => 'CUT GUIDE';

  @override
  String get barcodeImageReady => 'Barcode Image Ready';

  @override
  String get highResolutionPngImageOf =>
      'High-resolution PNG image of the box QR codes.';

  @override
  String get barcodeImageCaptured => 'Barcode image captured';

  @override
  String get commonDone => 'Done';

  @override
  String get failedToCaptureBarcodeGrid => 'Failed to capture barcode grid';

  @override
  String get failedToGenerateImage => 'Failed to generate image';

  @override
  String get couldnTExportTheLabels =>
      'Couldn\'t export the labels. Please try again.';

  @override
  String get pdfGeneratedChooseSaveTo =>
      'PDF generated. Choose \"Save to Files\" or share.';

  @override
  String get couldnTExportThePdf =>
      'Couldn\'t export the PDF. Please try again.';

  @override
  String get couldnTOpenThePrint =>
      'Couldn\'t open the print preview. Please try again.';

  @override
  String get exportAllBoxBarcodes => 'Export All Box Barcodes';

  @override
  String get boxNotFound => 'Box not found';

  @override
  String get exportBoxBarcodes => 'Export Box Barcodes';

  @override
  String get captureAndSaveBarcodeSheet =>
      'Capture and save barcode sheet as image';

  @override
  String get saveImage => 'Save Image';

  @override
  String get thisContainer => 'This Container';

  @override
  String allContainers(Object count) {
    return 'All Containers ($count)';
  }

  @override
  String get printSpecsFormat => 'PRINT SPECS / FORMAT';

  @override
  String get a4TomyDecal => 'A4 Tomy Decal';

  @override
  String get standardGridSheet => 'Standard grid sheet';

  @override
  String get thermal50x30mm => 'Thermal 50x30mm';

  @override
  String get singleRollLabel => 'Single roll label';

  @override
  String get printPreview => 'Print Preview';

  @override
  String get generatingPdf => 'Generating PDF...';

  @override
  String get exportPdfSaveShare => 'Export PDF (Save/Share)';

  @override
  String get tapToKeepYourVersion => 'Tap to keep your version or discard it';

  @override
  String get unresolvedChanges => 'Unresolved changes';

  @override
  String get nothingLeftToResolve => 'Nothing left to resolve.';

  @override
  String get commonDiscard => 'Discard';

  @override
  String get keepMine => 'Keep mine';

  @override
  String get commonClose => 'Close';

  @override
  String get recentItems => 'Recent Items';

  @override
  String get viewAll => 'View all';

  @override
  String get noItemsInInventoryYet => 'No items in inventory yet';

  @override
  String get tapToAddYourFirst => 'Tap + to add your first item';

  @override
  String get storageBox => 'Storage Box';

  @override
  String cannotConnectToBackend(Object serverUrl) {
    return 'Cannot connect to backend ($serverUrl)';
  }

  @override
  String get actionRequired => 'Action Required';

  @override
  String get commonReview => 'Review';

  @override
  String get commonLending => 'Lending';

  @override
  String get noLoans => 'No Loans';

  @override
  String get commonAlerts => 'Alerts';

  @override
  String get allClear => 'All Clear';

  @override
  String get storageSpaces => 'Storage Spaces';

  @override
  String get noStorageSpacesYet => 'No storage spaces yet';

  @override
  String get subContainerInLocation => 'Sub-container in location';

  @override
  String get primaryStorageSpace => 'Primary storage space';

  @override
  String get specificationsAttributes => 'Specifications & Attributes';

  @override
  String get commonManage => 'Manage';

  @override
  String get commonAdd => 'Add';

  @override
  String get noSpecificationsAddedYet => 'No specifications added yet';

  @override
  String get addCustomDetailsLikeColor =>
      'Add custom details like Color, Size, Brand, or Specs.';

  @override
  String get addSpecification => 'Add Specification';

  @override
  String get customizeAttributesAndMetadataFor =>
      'Customize attributes and metadata for this item.';

  @override
  String get currentSpecifications => 'CURRENT SPECIFICATIONS';

  @override
  String commonRemoved(Object key) {
    return 'Removed \"$key\"';
  }

  @override
  String get suggestedAttributes => 'SUGGESTED ATTRIBUTES';

  @override
  String get editAttribute => 'EDIT ATTRIBUTE';

  @override
  String get addAttribute => 'ADD ATTRIBUTE';

  @override
  String get attributeName => 'Attribute Name';

  @override
  String get eGColorRamSize => 'e.g. Color, RAM, Size, Material';

  @override
  String get attributeValue => 'Attribute Value';

  @override
  String get eGSpaceBlack16gb => 'e.g. Space Black, 16GB, XL';

  @override
  String get pleaseEnterAnAttributeName => 'Please enter an attribute name';

  @override
  String get pleaseEnterAnAttributeValue => 'Please enter an attribute value';

  @override
  String savedAttribute(Object k) {
    return 'Saved attribute \"$k\"';
  }

  @override
  String get saveAttribute => 'Save Attribute';

  @override
  String get newCategory => 'New Category';

  @override
  String get createACustomCategoryFor =>
      'Create a custom category for your assets';

  @override
  String get categoryName => 'Category Name';

  @override
  String get eGPhotographyWatchesBoard =>
      'e.g. Photography, Watches, Board Games';

  @override
  String get pleaseEnterACategoryName => 'Please enter a category name';

  @override
  String get categoryAlreadyExists => 'Category already exists';

  @override
  String get addSelect => 'Add & Select';

  @override
  String get overdueLoan => 'Overdue Loan';

  @override
  String get currentlyLentOut => 'Currently Lent Out';

  @override
  String commonBorrower2(Object borrowerName) {
    return 'Borrower: $borrowerName';
  }

  @override
  String commonContact(Object borrowerContact) {
    return 'Contact: $borrowerContact';
  }

  @override
  String get commonChange => 'Change';

  @override
  String get unknownLocation => 'Unknown Location';

  @override
  String get productHasExpired => 'Product has Expired!';

  @override
  String expiresSoonInDays(Object daysLeft) {
    return 'Expires soon in $daysLeft days';
  }

  @override
  String freshDaysRemaining(Object daysLeft) {
    return 'Fresh • $daysLeft days remaining';
  }

  @override
  String get lowStockWarning => 'Low Stock Warning';

  @override
  String currentThreshold(
    Object qty,
    Object unit,
    Object minQty,
    Object unit2,
  ) {
    return 'Current: $qty $unit • Threshold: ≤ $minQty $unit2';
  }

  @override
  String get assetPurchaseInformation => 'Asset & Purchase Information';

  @override
  String get purchasePrice2 => 'Purchase Price';

  @override
  String get notRecorded => 'Not recorded';

  @override
  String get purchaseDate => 'Purchase Date';

  @override
  String get lowStockAlertThreshold => 'Low Stock Alert Threshold';

  @override
  String get notTracked => 'Not tracked';

  @override
  String get barcodeUpcEan => 'Barcode (UPC/EAN)';

  @override
  String get warrantyExpired => 'Warranty Expired';

  @override
  String get warrantyActive => 'Warranty Active';

  @override
  String get commonCopy => 'Copy';

  @override
  String copiedToClipboard(Object label) {
    return 'Copied $label to clipboard';
  }

  @override
  String get addAttribute2 => 'Add Attribute';

  @override
  String get addCustomAttributesLikeColor =>
      'Add custom attributes like Color, Size, RAM, or Brand';

  @override
  String get commonRemove => 'Remove';

  @override
  String get editSpecification => 'Edit Specification';

  @override
  String get eGColorRamSize2 => 'e.g. Color, RAM, Size, Material, Weight';

  @override
  String get eGSpaceBlack16gb2 => 'e.g. Space Black, 16GB, XL, Leather';

  @override
  String get saveSpecification => 'Save Specification';

  @override
  String get paperReceipt => 'Paper Receipt';

  @override
  String get storeInvoice => 'Store Invoice';

  @override
  String get warrantyCard => 'Warranty Card';

  @override
  String get addReceiptPhoto => 'Add Receipt Photo';

  @override
  String get addProductPhoto => 'Add Product Photo';

  @override
  String get commonCamera => 'Camera';

  @override
  String get commonGallery => 'Gallery';

  @override
  String get orViaUrl => 'OR VIA URL';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get photoAdded => 'Photo added';

  @override
  String get addViaUrl => 'Add via URL';

  @override
  String get orChooseSamplePhoto => 'Or choose sample photo';

  @override
  String get samplePhotoSelected => 'Sample photo selected';

  @override
  String commonConsume2(Object name) {
    return 'Consume: $name';
  }

  @override
  String currentStock(Object formattedCurrent, Object unit) {
    return 'Current stock: $formattedCurrent $unit';
  }

  @override
  String get quantityToUse => 'Quantity to use:';

  @override
  String use1(Object unit) {
    return 'Use 1 $unit';
  }

  @override
  String use2(Object unit) {
    return 'Use 2 $unit';
  }

  @override
  String use5(Object unit) {
    return 'Use 5 $unit';
  }

  @override
  String get useAll => 'Use All';

  @override
  String get willBeOutOfStock => 'Will be out of stock after use';

  @override
  String remainingAfterUse(Object formattedRemain, Object unit) {
    return 'Remaining after use: $formattedRemain $unit';
  }

  @override
  String get commonRestock => 'Restock';

  @override
  String usedRemaining(
    Object formattedConsume,
    Object unit,
    Object formattedRemain,
    Object unit2,
  ) {
    return 'Used $formattedConsume $unit. Remaining: $formattedRemain $unit2';
  }

  @override
  String warningQuantityHasDroppedTo(Object minQuantity, Object unit) {
    return 'Warning: Quantity has dropped to minimum level (≤ $minQuantity $unit)';
  }

  @override
  String get confirmUse => 'Confirm Use';

  @override
  String commonRestock2(Object name) {
    return 'Restock: $name';
  }

  @override
  String quantityToAdd(Object unit) {
    return 'Quantity to add ($unit)';
  }

  @override
  String addedTotal(
    Object addAmount,
    Object unit,
    Object formattedNew,
    Object unit2,
  ) {
    return 'Added $addAmount $unit. Total: $formattedNew $unit2';
  }

  @override
  String get confirmRestock => 'Confirm Restock';

  @override
  String get commonRoot => 'Root';

  @override
  String storeDirectlyIn(Object name) {
    return 'Store directly in \"$name\"';
  }

  @override
  String get commonCurrent => 'Current';

  @override
  String get placeItemAtThisLevel =>
      'Place item at this level without placing it into any sub-box';

  @override
  String get chooseARoomShelfOr => 'Choose a room, shelf, or container';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get scanQr => 'Scan QR';

  @override
  String get currentLocation => 'Current Location';

  @override
  String subContainersInside(Object count) {
    return 'Sub-containers inside ($count)';
  }

  @override
  String noSubContainersInside(Object name) {
    return 'No sub-containers inside \"$name\"';
  }

  @override
  String get noLocationsAvailable => 'No locations available';

  @override
  String youCanSelectDirectlyAbove(Object name) {
    return 'You can select \"$name\" directly above.';
  }

  @override
  String get currentlySelectedLocation => 'Currently selected location';

  @override
  String get selectedStorageDestination => 'Selected Storage Destination';

  @override
  String get moveItemLocation => 'Move Item Location';

  @override
  String selectNewStorageDestinationFor(Object name) {
    return 'Select new storage destination for \"$name\"';
  }

  @override
  String get confirmMove => 'Confirm Move';

  @override
  String movedTo(Object name, Object name2) {
    return 'Moved \"$name\" to \"$name2\"';
  }

  @override
  String get selectNewStorageDestinationFor2 =>
      'Select new storage destination for item';

  @override
  String youCanStoreDirectlyIn(Object name) {
    return 'You can store \"$name\" directly in this container.';
  }

  @override
  String get itemIsAlreadyInThis => 'Item is already in this location';

  @override
  String get targetDestination => 'Target Destination';

  @override
  String get bulkMoveLocation => 'Bulk Move Location';

  @override
  String moveAndContents(Object name) {
    return 'Move \"$name\" and contents';
  }

  @override
  String allItemsAndNestedContainers(Object totalItems, Object totalSubBoxes) {
    return 'All $totalItems items and $totalSubBoxes nested containers inside will move along with this container.';
  }

  @override
  String get selectDestination => 'Select Destination';

  @override
  String get rootLevelNoParentContainer => 'Root Level (No Parent Container)';

  @override
  String get topOfHierarchy => 'Top of hierarchy';

  @override
  String movedSuccessfully(Object name) {
    return 'Moved \"$name\" successfully';
  }

  @override
  String get cannotMoveContainerIntoIts =>
      'Cannot move container into its own descendant';

  @override
  String get serverEndpoint => 'Server Endpoint';

  @override
  String get apiAuthentication => 'API Authentication';

  @override
  String authenticatedAs(Object userName) {
    return 'Authenticated as $userName';
  }

  @override
  String get loginSwitch => 'Login / Switch';

  @override
  String get syncWithServer => 'Sync With Server';

  @override
  String get synchronizingBoxesItemsAlerts =>
      'Synchronizing boxes, items & alerts...';

  @override
  String get pullLatestInventoryLendingRecords =>
      'Pull latest inventory & lending records';

  @override
  String get successfullySynchronizedWithBackendServer =>
      'Successfully synchronized with backend server';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get backendApiUrl => 'Backend API URL';

  @override
  String get enterTheBackendBaseUrl =>
      'Enter the backend base URL (default: http://localhost:8080):';

  @override
  String serverUrlUpdatedTo(Object newUrl) {
    return 'Server URL updated to $newUrl';
  }

  @override
  String get saveConnect => 'Save & Connect';

  @override
  String get usDollar => 'US Dollar';

  @override
  String get vietnameseDong => 'Vietnamese Dong';

  @override
  String get commonEuro => 'Euro';

  @override
  String get britishPound => 'British Pound';

  @override
  String get japaneseYen => 'Japanese Yen';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get appliedToPriceCalculationsAsset =>
      'Applied to price calculations & asset valuation';

  @override
  String currencyChangedTo(Object sym) {
    return 'Currency changed to $sym';
  }

  @override
  String get defaultMeasuringUnitWhenCreating =>
      'Default measuring unit when creating new items';

  @override
  String defaultUnitSetTo(Object unit) {
    return 'Default unit set to \"$unit\"';
  }

  @override
  String get howManyDaysBeforeExpiration =>
      'How many days before expiration to alert you';

  @override
  String alertWindowSetToDays(Object days) {
    return 'Alert window set to $days days';
  }

  @override
  String get howManyDaysBeforeWarranty =>
      'How many days before warranty ends to alert you';

  @override
  String warrantyWindowSetToDays(Object days) {
    return 'Warranty window set to $days days';
  }

  @override
  String get alertsTreatTodayInThis =>
      'Alerts treat \"today\" in this time zone';

  @override
  String timeZoneSetTo(Object tz) {
    return 'Time zone set to $tz';
  }

  @override
  String get updateYourDisplayNameAnd =>
      'Update your display name and inventory role';

  @override
  String get displayName => 'Display Name';

  @override
  String get eGSaraWilson => 'e.g. Sara Wilson';

  @override
  String get roleDepartment => 'Role / Department';

  @override
  String get eGAssetManagerHome => 'e.g. Asset Manager, Home Owner';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get commonNew => 'New';

  @override
  String get searchCategories => 'Search categories...';

  @override
  String noCategoriesMatch(Object searchQuery) {
    return 'No categories match \"$searchQuery\"';
  }

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String deleteCategoryAnyItemsIn(Object cat) {
    return 'Delete category \"$cat\"? Any items in this category will be reassigned to \"General\".';
  }

  @override
  String categoryRemoved(Object cat) {
    return 'Category \"$cat\" removed';
  }

  @override
  String get addNewCategory => 'Add New Category';

  @override
  String get enterACategoryNameFor => 'Enter a category name for your catalog';

  @override
  String get eGPhotographyBoardGames =>
      'e.g. Photography, Board Games, Hardware';

  @override
  String categoryCreated2(Object name) {
    return 'Category \"$name\" created';
  }

  @override
  String get addCategory => 'Add Category';

  @override
  String get inventoryReport => 'Inventory Report';

  @override
  String get generatedPlainTextInventoryStatus =>
      'Generated plain-text inventory status report';

  @override
  String get reportCopiedToClipboard => 'Report copied to clipboard!';

  @override
  String get copyReportToClipboard => 'Copy Report to Clipboard';

  @override
  String realTimeConditionBreakdownOf(Object total) {
    return 'Real-time condition breakdown of $total tracked items';
  }

  @override
  String get storedInContainers => 'Stored in Containers';

  @override
  String get inUseActive => 'In Use / Active';

  @override
  String get lentToBorrowers => 'Lent to Borrowers';

  @override
  String expiringSoonD(Object expiryWarningDays) {
    return 'Expiring Soon (≤ ${expiryWarningDays}d)';
  }

  @override
  String get expiredAssets => 'Expired Assets';

  @override
  String get initialStock => 'Initial stock';

  @override
  String get commonRestocked => 'Restocked';

  @override
  String get commonUsed => 'Used';

  @override
  String get commonDamaged => 'Damaged';

  @override
  String get commonLost => 'Lost';

  @override
  String get commonCorrection => 'Correction';

  @override
  String get commonMoved => 'Moved';

  @override
  String get commonAdjusted => 'Adjusted';

  @override
  String get couldNotLoadStockHistory => 'Could not load stock history';

  @override
  String get noConsumptionDataYet => 'No consumption data yet';

  @override
  String avgDayAboutDaysLeft(Object count, Object count2) {
    return 'Avg $count/day · about $count2 days left';
  }

  @override
  String get noMovementsRecorded => 'No movements recorded';

  @override
  String get thermalLabelPrint => 'Thermal Label Print';

  @override
  String get standardPrintableAdhesiveLabel =>
      'Standard printable adhesive label';

  @override
  String get thermalLabelCopiedToClipboard =>
      'Thermal label copied to clipboard';

  @override
  String get copyId => 'Copy ID';

  @override
  String thermalLabelSentToPrinter(Object value) {
    return 'Thermal label sent to printer (${value}mm)';
  }

  @override
  String get commonInitializing => 'Initializing...';

  @override
  String get youWereSignedOutOn =>
      'You were signed out on another device. Please sign in again.';

  @override
  String get yourSessionHasExpiredPlease =>
      'Your session has expired. Please sign in again.';

  @override
  String get connectingToServer => 'Connecting to server...';

  @override
  String get commonAuthenticating => 'Authenticating...';

  @override
  String get syncingInventory => 'Syncing inventory...';

  @override
  String get commonReady => 'Ready';

  @override
  String get couldnTSignInPlease => 'Couldn\'t sign in. Please try again.';

  @override
  String get couldnTSignInWith =>
      'Couldn\'t sign in with Google. Please try again.';

  @override
  String get couldnTCreateYourAccount =>
      'Couldn\'t create your account. Please try again.';

  @override
  String get couldNotReachTheServer =>
      'Could not reach the server. Check your connection and try again.';

  @override
  String get cannotReachTheServer => 'Cannot reach the server';

  @override
  String get couldnTSyncYourData =>
      'Couldn\'t sync your data. Pull down to retry.';

  @override
  String get thisWasChangedElsewhereShowing =>
      'This was changed elsewhere. Showing the latest version.';

  @override
  String commonManager(Object userName, Object userRole) {
    return 'Manager: $userName ($userRole)';
  }

  @override
  String serverBackend(Object baseUrl) {
    return 'Server Backend: $baseUrl';
  }

  @override
  String get endOfReport => 'End of report';

  @override
  String get somethingWentWrongPleaseTry =>
      'Something went wrong. Please try again.';

  @override
  String get incorrectEmailOrPassword => 'Incorrect email or password.';

  @override
  String get thatItemNoLongerExists => 'That item no longer exists.';

  @override
  String get thisWasChangedSomewhereElse =>
      'This was changed somewhere else. Refresh and try again.';

  @override
  String get tooManyAttemptsPleaseWait =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get theServerIsBusyRight =>
      'The server is busy right now. Please try again shortly.';

  @override
  String get canTReachTheServer =>
      'Can\'t reach the server. Check your connection and try again.';

  @override
  String get reportTitle => 'INVENTORY STATUS REPORT';

  @override
  String reportGenerated(Object date) {
    return 'Generated: $date';
  }

  @override
  String get reportOverview => '1. OVERVIEW STATISTICS:';

  @override
  String reportTotalContainers(Object count) {
    return '- Total Storage Containers: $count';
  }

  @override
  String reportTotalItems(Object count) {
    return '- Total Inventory Items: $count';
  }

  @override
  String reportTotalValue(Object value) {
    return '- Total Estimated Value: $value';
  }

  @override
  String reportActiveLent(Object count) {
    return '- Active Lent Items: $count';
  }

  @override
  String reportOverdueLent(Object count) {
    return '- Overdue Lent Items: $count';
  }

  @override
  String reportExpired(Object count) {
    return '- Expired Items: $count';
  }

  @override
  String reportExpiringSoon(Object days, Object count) {
    return '- Expiring Soon (within $days days): $count';
  }

  @override
  String get reportCategories => '2. CATEGORIES BREAKDOWN:';

  @override
  String reportCategoryLine(Object category, Object count) {
    return '- $category: $count items';
  }

  @override
  String get reportCurrentItems => '3. CURRENT INVENTORY ITEMS:';

  @override
  String reportPrice(Object price) {
    return ' | Price: $price';
  }

  @override
  String get reportNoLocation => 'No Location';

  @override
  String qtyValue(Object qty) {
    return 'Qty: $qty';
  }

  @override
  String get storageTypeRoom => 'Room';

  @override
  String get storageTypeCabinet => 'Cabinet / Wardrobe';

  @override
  String get storageTypeShelf => 'Shelf / Rack';

  @override
  String get storageTypeBox => 'Box / Bin';

  @override
  String get storageTypeDrawer => 'Drawer';

  @override
  String get storageTypeOther => 'Container';

  @override
  String get statusStored => 'Stored';

  @override
  String get statusInUse => 'In Use';

  @override
  String get statusLent => 'Lent';

  @override
  String get statusBroken => 'Broken';

  @override
  String get statusDisposed => 'Disposed';

  @override
  String get statusLost => 'Lost';

  @override
  String heyName(Object name) {
    return 'Hey $name!';
  }

  @override
  String get heyFallbackName => 'there';

  @override
  String markReturnedBy(Object item, Object borrower) {
    return 'Mark \"$item\" as returned by $borrower?\nStatus will change back to Stored.';
  }

  @override
  String leaveEmptyToLendAll(Object qty) {
    return 'Leave empty to lend all ($qty in stock)';
  }

  @override
  String get itemFallbackName => 'item';

  @override
  String get createFirstLocation => 'Create your first location';

  @override
  String get addFirstItem => 'Add your first item';

  @override
  String get firstRoomsTitle => 'Where do you keep your things?';

  @override
  String get firstRoomsSubtitle =>
      'Pick the rooms you have. You can add cabinets, shelves and boxes inside them later.';

  @override
  String get roomLivingRoom => 'Living room';

  @override
  String get roomKitchen => 'Kitchen';

  @override
  String get roomBedroom => 'Bedroom';

  @override
  String get roomBathroom => 'Bathroom';

  @override
  String get roomGarage => 'Garage';

  @override
  String get roomOffice => 'Office';

  @override
  String get roomStorage => 'Storage room';

  @override
  String createSelectedRooms(Object count) {
    return 'Create selected ($count)';
  }

  @override
  String get addMyOwnLocation => 'Add my own';

  @override
  String locationsCreatedCount(Object count) {
    return '$count locations created';
  }

  @override
  String get flashlight => 'Flashlight';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesMessage =>
      'You have unsaved changes. If you leave now they will be lost.';

  @override
  String get moreDetails => 'More details';

  @override
  String get scanBarcode => 'Scan barcode';

  @override
  String get createLocationHere => 'Create new location here';

  @override
  String get locationNameHint => 'Location name';

  @override
  String lentOnDate(String date) {
    return 'Lent on: $date';
  }

  @override
  String expectedReturnOn(String date) {
    return 'Expected return: $date';
  }

  @override
  String expiryDateOn(String date) {
    return 'Expiry date: $date';
  }

  @override
  String validUntilDate(String date) {
    return 'Valid until: $date';
  }

  @override
  String daysLeftCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String expiredAgoOn(int days, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Expired $_temp0 ago ($date)';
  }

  @override
  String expiresInOn(int days, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Expires in $_temp0 ($date)';
  }

  @override
  String get tagOverdue => 'OVERDUE';

  @override
  String get tagLent => 'LENT';

  @override
  String get tagReturned => 'RETURNED';

  @override
  String get tagLowStock => 'LOW STOCK';

  @override
  String get tagExpired => 'EXPIRED';

  @override
  String expiresInShort(int days) {
    return 'Expires in ${days}d';
  }

  @override
  String inPlacePath(String path) {
    return 'In: $path';
  }

  @override
  String assetsTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assets tracked',
      one: '1 asset tracked',
    );
    return '$_temp0';
  }

  @override
  String itemsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String nestedCountLabel(int count) {
    return '$count nested';
  }

  @override
  String subContainersCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sub-containers',
      one: '1 sub-container',
    );
    return '$_temp0';
  }

  @override
  String get statusOnlineTag => 'ONLINE';

  @override
  String get statusOfflineTag => 'OFFLINE';

  @override
  String itemNowInUse(String name) {
    return '\"$name\" is now in use';
  }

  @override
  String get developerBadge => 'DEVELOPER';

  @override
  String get splashTagline => 'Smart inventory & asset tracker';

  @override
  String get continueToApp => 'Continue to app →';

  @override
  String changesNeedAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offline changes need your attention',
      one: '1 offline change needs your attention',
    );
    return '$_temp0';
  }

  @override
  String changesRejectedByServer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offline changes were rejected by the server',
      one: '1 offline change was rejected by the server',
    );
    return '$_temp0';
  }

  @override
  String opRejectedBecause(String operation, String reason) {
    return '$operation was rejected: $reason';
  }

  @override
  String get discardChangeTitle => 'Discard this change?';

  @override
  String get discardChangeMessage =>
      'Your change will be dropped and the version on the server stays.';

  @override
  String get opCreateItem => 'Add item';

  @override
  String get opUpdateItem => 'Edit item';

  @override
  String get opDeleteItem => 'Delete item';

  @override
  String get opMoveItem => 'Move item';

  @override
  String get opChangeQuantity => 'Change quantity';

  @override
  String get opCreateBox => 'Add location';

  @override
  String get opUpdateBox => 'Edit location';

  @override
  String get opMoveBox => 'Move location';

  @override
  String get opDeleteBox => 'Delete location';

  @override
  String get opLend => 'Lend item';

  @override
  String get opReturnLoan => 'Return item';

  @override
  String get opCreateCategory => 'Add category';

  @override
  String get opDeleteCategory => 'Delete category';

  @override
  String get opUpdateSettings => 'Change settings';

  @override
  String daysOverdueCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0 overdue';
  }
}
