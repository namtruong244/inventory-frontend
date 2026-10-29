import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR & Barcode'**
  String get scanTitle;

  /// No description provided for @scanFoundContainer.
  ///
  /// In en, this message translates to:
  /// **'Container found: \"{name}\"'**
  String scanFoundContainer(String name);

  /// No description provided for @scanFoundItem.
  ///
  /// In en, this message translates to:
  /// **'Item found: \"{name}\"'**
  String scanFoundItem(String name);

  /// No description provided for @scanOpenDetailsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Open its details now?'**
  String get scanOpenDetailsPrompt;

  /// No description provided for @scanOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get scanOpen;

  /// No description provided for @scanKeepScanning.
  ///
  /// In en, this message translates to:
  /// **'Keep Scanning'**
  String get scanKeepScanning;

  /// No description provided for @scanUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Scanned Code: {code}'**
  String scanUnknownTitle(String code);

  /// No description provided for @scanUnknownMessage.
  ///
  /// In en, this message translates to:
  /// **'No storage box or item currently matches this code. Would you like to create a new item with this barcode?'**
  String get scanUnknownMessage;

  /// No description provided for @scanAddNewItem.
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get scanAddNewItem;

  /// No description provided for @scanPickLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where is it stored?'**
  String get scanPickLocationTitle;

  /// No description provided for @scanPickLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the location for the new item'**
  String get scanPickLocationSubtitle;

  /// No description provided for @scanPickLocationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Use This Location'**
  String get scanPickLocationConfirm;

  /// No description provided for @scanModeLocation.
  ///
  /// In en, this message translates to:
  /// **'Location QR'**
  String get scanModeLocation;

  /// No description provided for @scanModeProduct.
  ///
  /// In en, this message translates to:
  /// **'Product Barcode'**
  String get scanModeProduct;

  /// No description provided for @scanHintProduct.
  ///
  /// In en, this message translates to:
  /// **'Scan product barcode (UPC/EAN) to auto-fill or search in inventory'**
  String get scanHintProduct;

  /// No description provided for @scanHintLocation.
  ///
  /// In en, this message translates to:
  /// **'Point camera at container QR code to open details and view all contents'**
  String get scanHintLocation;

  /// No description provided for @scanManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Code Manually'**
  String get scanManualTitle;

  /// No description provided for @scanManualLabel.
  ///
  /// In en, this message translates to:
  /// **'Label ID or Barcode'**
  String get scanManualLabel;

  /// No description provided for @settingsAppearanceHeader.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE & LANGUAGE'**
  String get settingsAppearanceHeader;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light or dark appearance'**
  String get settingsThemeSubtitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Screens already translated switch language immediately'**
  String get settingsLanguageSubtitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @settingsScannerHeader.
  ///
  /// In en, this message translates to:
  /// **'SCANNER & RECOGNITION'**
  String get settingsScannerHeader;

  /// No description provided for @settingsAlertsHeader.
  ///
  /// In en, this message translates to:
  /// **'ALERTS'**
  String get settingsAlertsHeader;

  /// No description provided for @settingsVibrate.
  ///
  /// In en, this message translates to:
  /// **'Vibration on Scan'**
  String get settingsVibrate;

  /// No description provided for @settingsVibrateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback when QR/Barcode detected'**
  String get settingsVibrateSubtitle;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound Feedback'**
  String get settingsSound;

  /// No description provided for @settingsSoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play a click sound when a scan succeeds (this device only)'**
  String get settingsSoundSubtitle;

  /// No description provided for @settingsAutoOpen.
  ///
  /// In en, this message translates to:
  /// **'Auto-Open Details'**
  String get settingsAutoOpen;

  /// No description provided for @settingsAutoOpenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Off: ask before opening the matched container/item'**
  String get settingsAutoOpenSubtitle;

  /// No description provided for @settingsExpiring.
  ///
  /// In en, this message translates to:
  /// **'Expiring Items'**
  String get settingsExpiring;

  /// No description provided for @settingsExpiringSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Count expired and expiring items in the in-app alert badge (no push notifications yet)'**
  String get settingsExpiringSubtitle;

  /// No description provided for @settingsOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue Loans'**
  String get settingsOverdue;

  /// No description provided for @settingsOverdueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Count overdue loans in the in-app alert badge (no push notifications yet)'**
  String get settingsOverdueSubtitle;

  /// No description provided for @settingsLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get settingsLowStock;

  /// No description provided for @settingsLowStockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Count items below their minimum quantity in the in-app alert badge'**
  String get settingsLowStockSubtitle;

  /// No description provided for @trashConfirmItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Move to Trash?'**
  String get trashConfirmItemTitle;

  /// No description provided for @trashConfirmBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Move location to Trash?'**
  String get trashConfirmBoxTitle;

  /// No description provided for @trashConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be moved to Trash. You can restore it within {days} days.'**
  String trashConfirmMessage(String name, int days);

  /// No description provided for @trashConfirmBoxMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" and everything inside it will be moved to Trash. You can restore them within {days} days.'**
  String trashConfirmBoxMessage(String name, int days);

  /// No description provided for @trashMoveAction.
  ///
  /// In en, this message translates to:
  /// **'Move to Trash'**
  String get trashMoveAction;

  /// No description provided for @trashMovedToast.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" moved to Trash'**
  String trashMovedToast(String name);

  /// No description provided for @trashUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get trashUndo;

  /// No description provided for @trashRestoredToast.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" restored'**
  String trashRestoredToast(String name);

  /// No description provided for @trashRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore \"{name}\". Try from Trash in Settings.'**
  String trashRestoreFailed(String name);

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline: showing saved data'**
  String get syncOffline;

  /// No description provided for @syncUnsynced.
  ///
  /// In en, this message translates to:
  /// **'Changes not synced yet'**
  String get syncUnsynced;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No changes waiting} =1{1 change waiting to sync} other{{count} changes waiting to sync}}'**
  String syncPending(int count);

  /// No description provided for @syncNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 needs your attention} other{{count} need your attention}}'**
  String syncNeedsAttention(int count);

  /// No description provided for @syncSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync status'**
  String get syncSheetTitle;

  /// No description provided for @syncOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Your changes are saved on this device and will upload automatically when the server is reachable.'**
  String get syncOfflineBody;

  /// No description provided for @syncOnlineBody.
  ///
  /// In en, this message translates to:
  /// **'Some changes have not reached the server yet.'**
  String get syncOnlineBody;

  /// No description provided for @syncRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Rejected by the server'**
  String get syncRejectedTitle;

  /// No description provided for @syncDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get syncDismiss;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @lifecycleAlerts.
  ///
  /// In en, this message translates to:
  /// **'Lifecycle & Alerts'**
  String get lifecycleAlerts;

  /// No description provided for @allGood.
  ///
  /// In en, this message translates to:
  /// **'All Good!'**
  String get allGood;

  /// No description provided for @noItemsAreExpiredExpiring.
  ///
  /// In en, this message translates to:
  /// **'No items are expired, expiring soon, or overdue.'**
  String get noItemsAreExpiredExpiring;

  /// No description provided for @expiredItems.
  ///
  /// In en, this message translates to:
  /// **'Expired Items'**
  String get expiredItems;

  /// No description provided for @expiringSoonPerishables.
  ///
  /// In en, this message translates to:
  /// **'Expiring Soon (Perishables)'**
  String get expiringSoonPerishables;

  /// No description provided for @warrantiesEndingSoon.
  ///
  /// In en, this message translates to:
  /// **'Warranties Ending Soon'**
  String get warrantiesEndingSoon;

  /// No description provided for @overdueBorrowedItems.
  ///
  /// In en, this message translates to:
  /// **'Overdue Borrowed Items'**
  String get overdueBorrowedItems;

  /// No description provided for @lowStockWarnings.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Warnings'**
  String get lowStockWarnings;

  /// No description provided for @commonStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get commonStorage;

  /// No description provided for @onlyRemainingThreshold.
  ///
  /// In en, this message translates to:
  /// **'Only {qty} {unit} remaining (Threshold: ≤ {minQty} {unit2})'**
  String onlyRemainingThreshold(
    Object qty,
    Object unit,
    Object minQty,
    Object unit2,
  );

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @warrantyEndsInDays.
  ///
  /// In en, this message translates to:
  /// **'Warranty ends in {daysLeft} days'**
  String warrantyEndsInDays(Object daysLeft);

  /// No description provided for @borrowedItem.
  ///
  /// In en, this message translates to:
  /// **'Borrowed Item'**
  String get borrowedItem;

  /// No description provided for @commonBorrower.
  ///
  /// In en, this message translates to:
  /// **'Borrower: {borrowerName} • {borrowerContact}'**
  String commonBorrower(Object borrowerName, Object borrowerContact);

  /// No description provided for @locationUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Location \"{boxName}\" updated successfully'**
  String locationUpdatedSuccessfully(Object boxName);

  /// No description provided for @locationCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Location \"{boxName}\" created successfully'**
  String locationCreatedSuccessfully(Object boxName);

  /// No description provided for @pleaseEnterAValidLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid location name'**
  String get pleaseEnterAValidLocation;

  /// No description provided for @editLocation.
  ///
  /// In en, this message translates to:
  /// **'Edit Location'**
  String get editLocation;

  /// No description provided for @createRootLocation.
  ///
  /// In en, this message translates to:
  /// **'Create Root Location'**
  String get createRootLocation;

  /// No description provided for @createNestedContainer.
  ///
  /// In en, this message translates to:
  /// **'Create Nested Container'**
  String get createNestedContainer;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @couldNotDeletePleaseTry.
  ///
  /// In en, this message translates to:
  /// **'Could not delete \"{boxName}\". Please try again.'**
  String couldNotDeletePleaseTry(Object boxName);

  /// No description provided for @storageType.
  ///
  /// In en, this message translates to:
  /// **'Storage Type'**
  String get storageType;

  /// No description provided for @commonName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get commonName;

  /// No description provided for @eGLivingRoomOak.
  ///
  /// In en, this message translates to:
  /// **'e.g. Living Room, Oak Bookshelf, Electronics Box'**
  String get eGLivingRoomOak;

  /// No description provided for @pleaseEnterAName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterAName;

  /// No description provided for @commonDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get commonDescription;

  /// No description provided for @eGUpperShelfLeft.
  ///
  /// In en, this message translates to:
  /// **'e.g. Upper shelf, left side near window (Optional)'**
  String get eGUpperShelfLeft;

  /// No description provided for @parentContainer.
  ///
  /// In en, this message translates to:
  /// **'Parent Container'**
  String get parentContainer;

  /// No description provided for @qrLabelId.
  ///
  /// In en, this message translates to:
  /// **'QR Label ID'**
  String get qrLabelId;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save Location'**
  String get saveLocation;

  /// No description provided for @locationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Location not found'**
  String get locationNotFound;

  /// No description provided for @exportBarcodes.
  ///
  /// In en, this message translates to:
  /// **'Export Barcodes'**
  String get exportBarcodes;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get moreOptions;

  /// No description provided for @showQrCode.
  ///
  /// In en, this message translates to:
  /// **'Show QR code'**
  String get showQrCode;

  /// No description provided for @commonOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get commonOverview;

  /// No description provided for @boxSummary.
  ///
  /// In en, this message translates to:
  /// **'{items, plural, =1{1 total item} other{{items} total items}} • {nested} nested'**
  String boxSummary(int items, int nested);

  /// No description provided for @nestedContainers.
  ///
  /// In en, this message translates to:
  /// **'Nested Containers ({count})'**
  String nestedContainers(Object count);

  /// No description provided for @addContainer.
  ///
  /// In en, this message translates to:
  /// **'Add Container'**
  String get addContainer;

  /// No description provided for @addContainerInside.
  ///
  /// In en, this message translates to:
  /// **'Add Container Inside'**
  String get addContainerInside;

  /// No description provided for @couldNotDeletePleaseTry2.
  ///
  /// In en, this message translates to:
  /// **'Could not delete \"{name}\". Please try again.'**
  String couldNotDeletePleaseTry2(Object name);

  /// No description provided for @itemsInThisContainer.
  ///
  /// In en, this message translates to:
  /// **'Items in this container ({count})'**
  String itemsInThisContainer(Object count);

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @noDirectItemsStoredHere.
  ///
  /// In en, this message translates to:
  /// **'No direct items stored here'**
  String get noDirectItemsStoredHere;

  /// No description provided for @moveLocation.
  ///
  /// In en, this message translates to:
  /// **'Move Location'**
  String get moveLocation;

  /// No description provided for @printThermalLabel.
  ///
  /// In en, this message translates to:
  /// **'Print Thermal Label'**
  String get printThermalLabel;

  /// No description provided for @viewFullQrCode.
  ///
  /// In en, this message translates to:
  /// **'View Full QR Code'**
  String get viewFullQrCode;

  /// No description provided for @deleteLocation.
  ///
  /// In en, this message translates to:
  /// **'Delete Location'**
  String get deleteLocation;

  /// No description provided for @storageHierarchy.
  ///
  /// In en, this message translates to:
  /// **'Storage Hierarchy'**
  String get storageHierarchy;

  /// No description provided for @exportAllQrCodes.
  ///
  /// In en, this message translates to:
  /// **'Export all QR codes'**
  String get exportAllQrCodes;

  /// No description provided for @newLocation.
  ///
  /// In en, this message translates to:
  /// **'New Location'**
  String get newLocation;

  /// No description provided for @searchLocationsRoomsContainers.
  ///
  /// In en, this message translates to:
  /// **'Search locations, rooms, containers...'**
  String get searchLocationsRoomsContainers;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String commonAll(Object count);

  /// No description provided for @commonRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms ({count})'**
  String commonRooms(Object count);

  /// No description provided for @cabinetsShelves.
  ///
  /// In en, this message translates to:
  /// **'Cabinets & Shelves ({count})'**
  String cabinetsShelves(Object count);

  /// No description provided for @boxesDrawers.
  ///
  /// In en, this message translates to:
  /// **'Boxes & Drawers ({count})'**
  String boxesDrawers(Object count);

  /// No description provided for @switchToFlatList.
  ///
  /// In en, this message translates to:
  /// **'Switch to Flat List'**
  String get switchToFlatList;

  /// No description provided for @switchToTreeView.
  ///
  /// In en, this message translates to:
  /// **'Switch to Tree View'**
  String get switchToTreeView;

  /// No description provided for @expandAll.
  ///
  /// In en, this message translates to:
  /// **'Expand all'**
  String get expandAll;

  /// No description provided for @collapseAll.
  ///
  /// In en, this message translates to:
  /// **'Collapse all'**
  String get collapseAll;

  /// No description provided for @noLocationsYet.
  ///
  /// In en, this message translates to:
  /// **'No locations yet'**
  String get noLocationsYet;

  /// No description provided for @tapNewLocationAboveTo.
  ///
  /// In en, this message translates to:
  /// **'Tap \"New Location\" above to create your first room or box'**
  String get tapNewLocationAboveTo;

  /// No description provided for @noMatchingLocationsFound.
  ///
  /// In en, this message translates to:
  /// **'No matching locations found'**
  String get noMatchingLocationsFound;

  /// No description provided for @trySearchingWithADifferent.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different name or label'**
  String get trySearchingWithADifferent;

  /// No description provided for @commonMove.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get commonMove;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @addSubContainer.
  ///
  /// In en, this message translates to:
  /// **'Add sub-container'**
  String get addSubContainer;

  /// No description provided for @commonPath.
  ///
  /// In en, this message translates to:
  /// **'Path: '**
  String get commonPath;

  /// No description provided for @trackManageYourInventory.
  ///
  /// In en, this message translates to:
  /// **'Track & manage\nyour inventory!'**
  String get trackManageYourInventory;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get commonHome;

  /// No description provided for @commonBox.
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get commonBox;

  /// No description provided for @commonItem.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get commonItem;

  /// No description provided for @commonSetting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get commonSetting;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// No description provided for @categoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category \"{created}\" created'**
  String categoryCreated(Object created);

  /// No description provided for @itemUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Item \"{itemName}\" updated successfully'**
  String itemUpdatedSuccessfully(Object itemName);

  /// No description provided for @itemAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Item \"{itemName}\" added successfully'**
  String itemAddedSuccessfully(Object itemName);

  /// No description provided for @pleaseEnterAValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity (0 or more)'**
  String get pleaseEnterAValidQuantity;

  /// No description provided for @pleaseFixTheHighlightedFields.
  ///
  /// In en, this message translates to:
  /// **'Please fix the highlighted fields'**
  String get pleaseFixTheHighlightedFields;

  /// No description provided for @couldnTUploadThePhoto.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t upload the photo. Check your connection and try again.'**
  String get couldnTUploadThePhoto;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New Item'**
  String get newItem;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @productPhotos.
  ///
  /// In en, this message translates to:
  /// **'Product Photos'**
  String get productPhotos;

  /// No description provided for @receiptsWarrantyProof.
  ///
  /// In en, this message translates to:
  /// **'Receipts & Warranty Proof'**
  String get receiptsWarrantyProof;

  /// No description provided for @saveItem.
  ///
  /// In en, this message translates to:
  /// **'Save Item'**
  String get saveItem;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @eGMacbookProFirst.
  ///
  /// In en, this message translates to:
  /// **'e.g. MacBook Pro, First Aid Kit, USB Cable'**
  String get eGMacbookProFirst;

  /// No description provided for @pleaseEnterItemName.
  ///
  /// In en, this message translates to:
  /// **'Please enter item name'**
  String get pleaseEnterItemName;

  /// No description provided for @commonCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get commonCategory;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @tapToChangeCategory.
  ///
  /// In en, this message translates to:
  /// **'Tap to change category'**
  String get tapToChangeCategory;

  /// No description provided for @commonQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get commonQuantity;

  /// No description provided for @commonUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get commonUnit;

  /// No description provided for @selectUnit.
  ///
  /// In en, this message translates to:
  /// **'Select Unit'**
  String get selectUnit;

  /// No description provided for @lowStockAlertThresholdOptional.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert Threshold (Optional)'**
  String get lowStockAlertThresholdOptional;

  /// No description provided for @eG2AlertWhen.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2 (Alert when quantity ≤ this number)'**
  String get eG2AlertWhen;

  /// No description provided for @storageLocation.
  ///
  /// In en, this message translates to:
  /// **'Storage Location'**
  String get storageLocation;

  /// No description provided for @selectStorageContainer.
  ///
  /// In en, this message translates to:
  /// **'Select Storage Container'**
  String get selectStorageContainer;

  /// No description provided for @commonUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get commonUnassigned;

  /// No description provided for @colorConditionAccessoriesOptional.
  ///
  /// In en, this message translates to:
  /// **'Color, condition, accessories (Optional)'**
  String get colorConditionAccessoriesOptional;

  /// No description provided for @consumableItem.
  ///
  /// In en, this message translates to:
  /// **'Consumable Item'**
  String get consumableItem;

  /// No description provided for @consumableItemsBatteriesMasksFood.
  ///
  /// In en, this message translates to:
  /// **'Consumable items (batteries, masks, food, medicine...)'**
  String get consumableItemsBatteriesMasksFood;

  /// No description provided for @assetStatus.
  ///
  /// In en, this message translates to:
  /// **'Asset Status'**
  String get assetStatus;

  /// No description provided for @assetWarrantyDetails.
  ///
  /// In en, this message translates to:
  /// **'Asset & Warranty Details'**
  String get assetWarrantyDetails;

  /// No description provided for @purchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price ({currency})'**
  String purchasePrice(Object currency);

  /// No description provided for @serialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial Number'**
  String get serialNumber;

  /// No description provided for @productBarcodeUpcEan.
  ///
  /// In en, this message translates to:
  /// **'Product Barcode (UPC / EAN)'**
  String get productBarcodeUpcEan;

  /// No description provided for @scanOrEnterProductBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan or enter product barcode'**
  String get scanOrEnterProductBarcode;

  /// No description provided for @warrantyExpiry.
  ///
  /// In en, this message translates to:
  /// **'Warranty Expiry'**
  String get warrantyExpiry;

  /// No description provided for @perishableExpiry.
  ///
  /// In en, this message translates to:
  /// **'Perishable Expiry'**
  String get perishableExpiry;

  /// No description provided for @receiptCaptured.
  ///
  /// In en, this message translates to:
  /// **'Receipt captured'**
  String get receiptCaptured;

  /// No description provided for @photoCaptured.
  ///
  /// In en, this message translates to:
  /// **'Photo captured'**
  String get photoCaptured;

  /// No description provided for @cameraIsnTAvailableCheck.
  ///
  /// In en, this message translates to:
  /// **'Camera isn\'t available. Check the app\'s camera permission.'**
  String get cameraIsnTAvailableCheck;

  /// No description provided for @receiptSelected.
  ///
  /// In en, this message translates to:
  /// **'Receipt selected'**
  String get receiptSelected;

  /// No description provided for @photoSelected.
  ///
  /// In en, this message translates to:
  /// **'Photo selected'**
  String get photoSelected;

  /// No description provided for @couldnTOpenYourPhotos.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open your photos. Check the app\'s photo permission.'**
  String get couldnTOpenYourPhotos;

  /// No description provided for @commonCover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get commonCover;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @selectStorageLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Storage Location'**
  String get selectStorageLocation;

  /// No description provided for @chooseContainerOrScanQr.
  ///
  /// In en, this message translates to:
  /// **'Choose container or scan QR to assign'**
  String get chooseContainerOrScanQr;

  /// No description provided for @setLocation.
  ///
  /// In en, this message translates to:
  /// **'Set Location'**
  String get setLocation;

  /// No description provided for @returnedToStorage.
  ///
  /// In en, this message translates to:
  /// **'Returned \"{name}\" to storage'**
  String returnedToStorage(Object name);

  /// No description provided for @returnedToStorage2.
  ///
  /// In en, this message translates to:
  /// **'Returned \"{name}\" to storage{boxName}'**
  String returnedToStorage2(Object name, Object boxName);

  /// No description provided for @movedBackToStorage.
  ///
  /// In en, this message translates to:
  /// **'Moved \"{name}\" back to storage'**
  String movedBackToStorage(Object name);

  /// No description provided for @itemNotFoundOrHas.
  ///
  /// In en, this message translates to:
  /// **'Item not found or has been deleted'**
  String get itemNotFoundOrHas;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @editItemDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Item Details'**
  String get editItemDetails;

  /// No description provided for @lendItem.
  ///
  /// In en, this message translates to:
  /// **'Lend Item'**
  String get lendItem;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @commonConsumable.
  ///
  /// In en, this message translates to:
  /// **'Consumable'**
  String get commonConsumable;

  /// No description provided for @stockHistory.
  ///
  /// In en, this message translates to:
  /// **'Stock history'**
  String get stockHistory;

  /// No description provided for @outOfStockRestock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock (Restock)'**
  String get outOfStockRestock;

  /// No description provided for @commonConsume.
  ///
  /// In en, this message translates to:
  /// **'Consume ({unit})'**
  String commonConsume(Object unit);

  /// No description provided for @returnToStorage.
  ///
  /// In en, this message translates to:
  /// **'Return to Storage'**
  String get returnToStorage;

  /// No description provided for @takeOutToUse.
  ///
  /// In en, this message translates to:
  /// **'Take Out to Use'**
  String get takeOutToUse;

  /// No description provided for @itemCatalog.
  ///
  /// In en, this message translates to:
  /// **'Item Catalog'**
  String get itemCatalog;

  /// No description provided for @searchItemsBarcodesSerials.
  ///
  /// In en, this message translates to:
  /// **'Search items, barcodes, serials...'**
  String get searchItemsBarcodesSerials;

  /// No description provided for @commonStored.
  ///
  /// In en, this message translates to:
  /// **'Stored ({count})'**
  String commonStored(Object count);

  /// No description provided for @inUse.
  ///
  /// In en, this message translates to:
  /// **'In Use ({count})'**
  String inUse(Object count);

  /// No description provided for @commonLent.
  ///
  /// In en, this message translates to:
  /// **'Lent ({count})'**
  String commonLent(Object count);

  /// No description provided for @alertsExpiring.
  ///
  /// In en, this message translates to:
  /// **'Alerts / Expiring ({count})'**
  String alertsExpiring(Object count);

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock ({count})'**
  String lowStock(Object count);

  /// No description provided for @allStorageLocations.
  ///
  /// In en, this message translates to:
  /// **'All Storage Locations'**
  String get allStorageLocations;

  /// No description provided for @noMatchingItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No matching items found'**
  String get noMatchingItemsFound;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @trySearchingWithAnotherName.
  ///
  /// In en, this message translates to:
  /// **'Try searching with another name or clearing filters'**
  String get trySearchingWithAnotherName;

  /// No description provided for @tapAddItemAboveTo.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Item\" above to catalogue your first asset'**
  String get tapAddItemAboveTo;

  /// No description provided for @itemMarkedAsReturned.
  ///
  /// In en, this message translates to:
  /// **'Item marked as returned'**
  String get itemMarkedAsReturned;

  /// No description provided for @commonReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get commonReturn;

  /// No description provided for @commonLend.
  ///
  /// In en, this message translates to:
  /// **'Lend'**
  String get commonLend;

  /// No description provided for @selectDestinationContainer.
  ///
  /// In en, this message translates to:
  /// **'Select Destination Container'**
  String get selectDestinationContainer;

  /// No description provided for @chooseContainerOrScanIts.
  ///
  /// In en, this message translates to:
  /// **'Choose container or scan its QR to add item'**
  String get chooseContainerOrScanIts;

  /// No description provided for @addItemHere.
  ///
  /// In en, this message translates to:
  /// **'Add Item Here'**
  String get addItemHere;

  /// No description provided for @lendingTracker.
  ///
  /// In en, this message translates to:
  /// **'Lending Tracker'**
  String get lendingTracker;

  /// No description provided for @commonLoans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get commonLoans;

  /// No description provided for @itemsHavePassedTheirExpected.
  ///
  /// In en, this message translates to:
  /// **'Items have passed their expected return date.'**
  String get itemsHavePassedTheirExpected;

  /// No description provided for @commonActive.
  ///
  /// In en, this message translates to:
  /// **'Active ({count})'**
  String commonActive(Object count);

  /// No description provided for @commonHistory.
  ///
  /// In en, this message translates to:
  /// **'History ({count})'**
  String commonHistory(Object count);

  /// No description provided for @noActiveLoans.
  ///
  /// In en, this message translates to:
  /// **'No active loans'**
  String get noActiveLoans;

  /// No description provided for @allYourItemsAreSafely.
  ///
  /// In en, this message translates to:
  /// **'All your items are safely in storage.'**
  String get allYourItemsAreSafely;

  /// No description provided for @noLendingHistory.
  ///
  /// In en, this message translates to:
  /// **'No lending history'**
  String get noLendingHistory;

  /// No description provided for @returnedItemsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Returned items will appear here.'**
  String get returnedItemsWillAppearHere;

  /// No description provided for @unknownItem.
  ///
  /// In en, this message translates to:
  /// **'Unknown Item'**
  String get unknownItem;

  /// No description provided for @lentTo.
  ///
  /// In en, this message translates to:
  /// **'Lent to {borrowerName}'**
  String lentTo(Object borrowerName);

  /// No description provided for @commonLent2.
  ///
  /// In en, this message translates to:
  /// **'Lent: {count}'**
  String commonLent2(Object count);

  /// No description provided for @commonDue.
  ///
  /// In en, this message translates to:
  /// **'Due: {count}'**
  String commonDue(Object count);

  /// No description provided for @markAsReturned.
  ///
  /// In en, this message translates to:
  /// **'Mark as Returned'**
  String get markAsReturned;

  /// No description provided for @confirmItemReturn.
  ///
  /// In en, this message translates to:
  /// **'Confirm Item Return'**
  String get confirmItemReturn;

  /// No description provided for @confirmReturn.
  ///
  /// In en, this message translates to:
  /// **'Confirm Return'**
  String get confirmReturn;

  /// No description provided for @itemMarkedAsReturnedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Item marked as returned successfully'**
  String get itemMarkedAsReturnedSuccessfully;

  /// No description provided for @lendAnItem.
  ///
  /// In en, this message translates to:
  /// **'Lend an Item'**
  String get lendAnItem;

  /// No description provided for @selectItemToLend.
  ///
  /// In en, this message translates to:
  /// **'Select Item to Lend'**
  String get selectItemToLend;

  /// No description provided for @chooseAnAvailableItem.
  ///
  /// In en, this message translates to:
  /// **'Choose an available item...'**
  String get chooseAnAvailableItem;

  /// No description provided for @quantityToLend.
  ///
  /// In en, this message translates to:
  /// **'Quantity to lend'**
  String get quantityToLend;

  /// No description provided for @enterAQuantityGreaterThan.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity greater than 0'**
  String get enterAQuantityGreaterThan;

  /// No description provided for @onlyInStock.
  ///
  /// In en, this message translates to:
  /// **'Only {quantity} in stock'**
  String onlyInStock(Object quantity);

  /// No description provided for @borrowerName.
  ///
  /// In en, this message translates to:
  /// **'Borrower Name'**
  String get borrowerName;

  /// No description provided for @eGJohnDoe.
  ///
  /// In en, this message translates to:
  /// **'e.g. John Doe'**
  String get eGJohnDoe;

  /// No description provided for @pleaseEnterBorrowerName.
  ///
  /// In en, this message translates to:
  /// **'Please enter borrower name'**
  String get pleaseEnterBorrowerName;

  /// No description provided for @borrowerContact.
  ///
  /// In en, this message translates to:
  /// **'Borrower Contact'**
  String get borrowerContact;

  /// No description provided for @phoneNumberOrEmailOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone number or email (Optional)'**
  String get phoneNumberOrEmailOptional;

  /// No description provided for @expectedReturnDate.
  ///
  /// In en, this message translates to:
  /// **'Expected Return Date'**
  String get expectedReturnDate;

  /// No description provided for @selectDueDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Select due date (Optional)'**
  String get selectDueDateOptional;

  /// No description provided for @commonNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get commonNotes;

  /// No description provided for @eGBorrowedForPhotography.
  ///
  /// In en, this message translates to:
  /// **'e.g. Borrowed for photography project'**
  String get eGBorrowedForPhotography;

  /// No description provided for @pleaseSelectAnItem.
  ///
  /// In en, this message translates to:
  /// **'Please select an item'**
  String get pleaseSelectAnItem;

  /// No description provided for @itemMarkedAsLentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Item marked as lent successfully'**
  String get itemMarkedAsLentSuccessfully;

  /// No description provided for @saveLoan.
  ///
  /// In en, this message translates to:
  /// **'Save Loan'**
  String get saveLoan;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAs(Object email);

  /// No description provided for @googleAuthenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Google authentication failed'**
  String get googleAuthenticationFailed;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {userName}!'**
  String welcomeBack(Object userName);

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {userName}!'**
  String welcomeUser(Object userName);

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authenticationFailed;

  /// No description provided for @signInToSyncYour.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your inventory & assets across devices'**
  String get signInToSyncYour;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @pleaseEnterAValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterAValidEmail;

  /// No description provided for @commonPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPassword;

  /// No description provided for @showOrHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Show or hide password'**
  String get showOrHidePassword;

  /// No description provided for @passwordIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordIsRequired;

  /// No description provided for @passwordMustBeAtLeast.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMustBeAtLeast;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @alreadyHaveAnAccountSign.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAnAccountSign;

  /// No description provided for @donTHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get donTHaveAnAccount;

  /// No description provided for @byContinuingYouAgreeTo.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service & Privacy Policy'**
  String get byContinuingYouAgreeTo;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @boxQrCode.
  ///
  /// In en, this message translates to:
  /// **'Box QR Code'**
  String get boxQrCode;

  /// No description provided for @commonLabel.
  ///
  /// In en, this message translates to:
  /// **'Label: {label}'**
  String commonLabel(Object label);

  /// No description provided for @printLabel.
  ///
  /// In en, this message translates to:
  /// **'Print Label'**
  String get printLabel;

  /// No description provided for @commonAll2.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll2;

  /// No description provided for @commonStored2.
  ///
  /// In en, this message translates to:
  /// **'Stored'**
  String get commonStored2;

  /// No description provided for @inUse2.
  ///
  /// In en, this message translates to:
  /// **'In Use'**
  String get inUse2;

  /// No description provided for @commonLent3.
  ///
  /// In en, this message translates to:
  /// **'Lent'**
  String get commonLent3;

  /// No description provided for @commonPerishable.
  ///
  /// In en, this message translates to:
  /// **'Perishable'**
  String get commonPerishable;

  /// No description provided for @searchItemsSerialBarcodeBoxes.
  ///
  /// In en, this message translates to:
  /// **'Search items, serial, barcode, boxes...'**
  String get searchItemsSerialBarcodeBoxes;

  /// No description provided for @searchYourEntireInventory.
  ///
  /// In en, this message translates to:
  /// **'Search your entire inventory'**
  String get searchYourEntireInventory;

  /// No description provided for @findItemsByNameBarcode.
  ///
  /// In en, this message translates to:
  /// **'Find items by name, barcode, serial number, or storage location'**
  String get findItemsByNameBarcode;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(Object query);

  /// No description provided for @tryADifferentNameSerial.
  ///
  /// In en, this message translates to:
  /// **'Try a different name, serial number, or barcode'**
  String get tryADifferentNameSerial;

  /// No description provided for @storageLocations.
  ///
  /// In en, this message translates to:
  /// **'Storage Locations ({count})'**
  String storageLocations(Object count);

  /// No description provided for @commonItems.
  ///
  /// In en, this message translates to:
  /// **'Items ({count})'**
  String commonItems(Object count);

  /// No description provided for @developerOptionsActivated.
  ///
  /// In en, this message translates to:
  /// **'Developer options activated!'**
  String get developerOptionsActivated;

  /// No description provided for @tapMoreTimesToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Tap {remaining} more times to unlock developer tools'**
  String tapMoreTimesToUnlock(Object remaining);

  /// No description provided for @commonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// No description provided for @preferencesTaxonomyInventoryTools.
  ///
  /// In en, this message translates to:
  /// **'Preferences, taxonomy & inventory tools'**
  String get preferencesTaxonomyInventoryTools;

  /// No description provided for @taxonomyCategories.
  ///
  /// In en, this message translates to:
  /// **'TAXONOMY & CATEGORIES'**
  String get taxonomyCategories;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @inventoryPreferences.
  ///
  /// In en, this message translates to:
  /// **'INVENTORY PREFERENCES'**
  String get inventoryPreferences;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'Currency Symbol'**
  String get currencySymbol;

  /// No description provided for @usedForPurchasePricesValuation.
  ///
  /// In en, this message translates to:
  /// **'Used for purchase prices & valuation'**
  String get usedForPurchasePricesValuation;

  /// No description provided for @defaultItemUnit.
  ///
  /// In en, this message translates to:
  /// **'Default Item Unit'**
  String get defaultItemUnit;

  /// No description provided for @preFilledUnitForNewly.
  ///
  /// In en, this message translates to:
  /// **'Pre-filled unit for newly created items'**
  String get preFilledUnitForNewly;

  /// No description provided for @expiryWarningWindow.
  ///
  /// In en, this message translates to:
  /// **'Expiry Warning Window'**
  String get expiryWarningWindow;

  /// No description provided for @daysBeforeExpirationToTrigger.
  ///
  /// In en, this message translates to:
  /// **'Days before expiration to trigger alert'**
  String get daysBeforeExpirationToTrigger;

  /// No description provided for @warrantyWarningWindow.
  ///
  /// In en, this message translates to:
  /// **'Warranty Warning Window'**
  String get warrantyWarningWindow;

  /// No description provided for @daysBeforeWarrantyEndsTo.
  ///
  /// In en, this message translates to:
  /// **'Days before warranty ends to trigger alert'**
  String get daysBeforeWarrantyEndsTo;

  /// No description provided for @timeZone.
  ///
  /// In en, this message translates to:
  /// **'Time Zone'**
  String get timeZone;

  /// No description provided for @usedToDecideWhatToday.
  ///
  /// In en, this message translates to:
  /// **'Used to decide what \"today\" means for alerts'**
  String get usedToDecideWhatToday;

  /// No description provided for @reportsInventoryAudit.
  ///
  /// In en, this message translates to:
  /// **'REPORTS & INVENTORY AUDIT'**
  String get reportsInventoryAudit;

  /// No description provided for @exportAllBoxBarcodesPdf.
  ///
  /// In en, this message translates to:
  /// **'Export All Box Barcodes (PDF)'**
  String get exportAllBoxBarcodesPdf;

  /// No description provided for @generatePrintablePdfStickerSheet.
  ///
  /// In en, this message translates to:
  /// **'Generate printable PDF sticker sheet with box QR codes & names'**
  String get generatePrintablePdfStickerSheet;

  /// No description provided for @exportInventoryReport.
  ///
  /// In en, this message translates to:
  /// **'Export Inventory Report'**
  String get exportInventoryReport;

  /// No description provided for @generateCopyFormattedSummaryOf.
  ///
  /// In en, this message translates to:
  /// **'Generate & copy formatted summary of all assets'**
  String get generateCopyFormattedSummaryOf;

  /// No description provided for @commonTrash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get commonTrash;

  /// No description provided for @restoreOrPermanentlyDeleteRemoved.
  ///
  /// In en, this message translates to:
  /// **'Restore or permanently delete removed items & locations'**
  String get restoreOrPermanentlyDeleteRemoved;

  /// No description provided for @inventoryHealthBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Inventory Health Breakdown'**
  String get inventoryHealthBreakdown;

  /// No description provided for @statusDistributionInStockLent.
  ///
  /// In en, this message translates to:
  /// **'Status distribution: In Stock, Lent, Low Stock, Expired'**
  String get statusDistributionInStockLent;

  /// No description provided for @developerOptionsBackendApi.
  ///
  /// In en, this message translates to:
  /// **'DEVELOPER OPTIONS & BACKEND API'**
  String get developerOptionsBackendApi;

  /// No description provided for @developerModeDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Developer mode deactivated'**
  String get developerModeDeactivated;

  /// No description provided for @commonHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get commonHide;

  /// No description provided for @applicationInfo.
  ///
  /// In en, this message translates to:
  /// **'APPLICATION INFO'**
  String get applicationInfo;

  /// No description provided for @applicationVersion.
  ///
  /// In en, this message translates to:
  /// **'Application Version'**
  String get applicationVersion;

  /// No description provided for @designSystem.
  ///
  /// In en, this message translates to:
  /// **'Design System'**
  String get designSystem;

  /// No description provided for @minimalCharcoalIosStyle.
  ///
  /// In en, this message translates to:
  /// **'Minimal Charcoal (iOS Style)'**
  String get minimalCharcoalIosStyle;

  /// No description provided for @qrBarcodeEngine.
  ///
  /// In en, this message translates to:
  /// **'QR & Barcode Engine'**
  String get qrBarcodeEngine;

  /// No description provided for @storageArchitecture.
  ///
  /// In en, this message translates to:
  /// **'Storage Architecture'**
  String get storageArchitecture;

  /// No description provided for @hierarchicalMultiLevelTree.
  ///
  /// In en, this message translates to:
  /// **'Hierarchical Multi-Level Tree'**
  String get hierarchicalMultiLevelTree;

  /// No description provided for @logOutSwitchAccount.
  ///
  /// In en, this message translates to:
  /// **'Log Out / Switch Account'**
  String get logOutSwitchAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @switchAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Switch Account / Login'**
  String get switchAccountLogin;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out?'**
  String get logOut;

  /// No description provided for @areYouSureYouWant.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out? You can sign back in anytime using Google or your email.'**
  String get areYouSureYouWant;

  /// No description provided for @unsyncedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsynced changes'**
  String get unsyncedChanges;

  /// No description provided for @discardLogOut.
  ///
  /// In en, this message translates to:
  /// **'Discard & Log Out'**
  String get discardLogOut;

  /// No description provided for @logOut2.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut2;

  /// No description provided for @deleteAccount2.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccount2;

  /// No description provided for @thisPermanentlyDeletesYourAccount.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and all your boxes, items, loans and photos. This cannot be undone.'**
  String get thisPermanentlyDeletesYourAccount;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeletion;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get typeDeleteToConfirm;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get deleteForever;

  /// No description provided for @inventoryQuickMetrics.
  ///
  /// In en, this message translates to:
  /// **'Inventory Quick Metrics'**
  String get inventoryQuickMetrics;

  /// No description provided for @commonContainers.
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get commonContainers;

  /// No description provided for @totalAssets.
  ///
  /// In en, this message translates to:
  /// **'Total Assets'**
  String get totalAssets;

  /// No description provided for @onLoan.
  ///
  /// In en, this message translates to:
  /// **'On Loan'**
  String get onLoan;

  /// No description provided for @estValue.
  ///
  /// In en, this message translates to:
  /// **'Est. Value'**
  String get estValue;

  /// No description provided for @couldNotRestore.
  ///
  /// In en, this message translates to:
  /// **'Could not restore \"{name}\"'**
  String couldNotRestore(Object name);

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently?'**
  String get deletePermanently;

  /// No description provided for @couldNotDelete.
  ///
  /// In en, this message translates to:
  /// **'Could not delete \"{name}\"'**
  String couldNotDelete(Object name);

  /// No description provided for @emptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty trash?'**
  String get emptyTrash;

  /// No description provided for @everythingInTheTrashWill.
  ///
  /// In en, this message translates to:
  /// **'Everything in the trash will be removed for good.'**
  String get everythingInTheTrashWill;

  /// No description provided for @commonEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get commonEmpty;

  /// No description provided for @couldNotEmptyTheTrash.
  ///
  /// In en, this message translates to:
  /// **'Could not empty the trash'**
  String get couldNotEmptyTheTrash;

  /// No description provided for @couldNotLoadTheTrash.
  ///
  /// In en, this message translates to:
  /// **'Could not load the trash'**
  String get couldNotLoadTheTrash;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @trashIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get trashIsEmpty;

  /// No description provided for @commonLocation.
  ///
  /// In en, this message translates to:
  /// **'Location · {name}'**
  String commonLocation(Object name);

  /// No description provided for @commonItem2.
  ///
  /// In en, this message translates to:
  /// **'Item · {quantity} {unit}'**
  String commonItem2(Object quantity, Object unit);

  /// No description provided for @commonRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get commonRestore;

  /// No description provided for @deletePermanently2.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently2;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @noStorageBoxFoundWith.
  ///
  /// In en, this message translates to:
  /// **'No storage box found with code \"{code}\". Please scan a valid box QR label.'**
  String noStorageBoxFoundWith(Object code);

  /// No description provided for @selectTestBoxQrCode.
  ///
  /// In en, this message translates to:
  /// **'Select Test Box QR Code'**
  String get selectTestBoxQrCode;

  /// No description provided for @simulateScanningAPhysicalBox.
  ///
  /// In en, this message translates to:
  /// **'Simulate scanning a physical box QR sticker:'**
  String get simulateScanningAPhysicalBox;

  /// No description provided for @enterBoxLabelQr.
  ///
  /// In en, this message translates to:
  /// **'Enter Box Label / QR'**
  String get enterBoxLabelQr;

  /// No description provided for @eGLocElectronicsBox.
  ///
  /// In en, this message translates to:
  /// **'e.g. loc_electronics_box'**
  String get eGLocElectronicsBox;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @scanBoxQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan Box QR Code'**
  String get scanBoxQrCode;

  /// No description provided for @pointCameraAtTargetBox.
  ///
  /// In en, this message translates to:
  /// **'Point camera at target box sticker'**
  String get pointCameraAtTargetBox;

  /// No description provided for @toggleFlash.
  ///
  /// In en, this message translates to:
  /// **'Toggle flash'**
  String get toggleFlash;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanAgain;

  /// No description provided for @moveToThisBox.
  ///
  /// In en, this message translates to:
  /// **'Move to this Box'**
  String get moveToThisBox;

  /// No description provided for @testWithPresets.
  ///
  /// In en, this message translates to:
  /// **'Test with Presets'**
  String get testWithPresets;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get enterCode;

  /// No description provided for @switchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get switchCamera;

  /// No description provided for @boxScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Box Scan'**
  String get boxScanTitle;

  /// No description provided for @boxScanHint.
  ///
  /// In en, this message translates to:
  /// **'Place the QR code inside the frame to scan automatically.'**
  String get boxScanHint;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get pickFromGallery;

  /// No description provided for @noQrInImage.
  ///
  /// In en, this message translates to:
  /// **'No QR code found in this image.'**
  String get noQrInImage;

  /// No description provided for @cutGuide.
  ///
  /// In en, this message translates to:
  /// **'CUT GUIDE'**
  String get cutGuide;

  /// No description provided for @barcodeImageReady.
  ///
  /// In en, this message translates to:
  /// **'Barcode Image Ready'**
  String get barcodeImageReady;

  /// No description provided for @highResolutionPngImageOf.
  ///
  /// In en, this message translates to:
  /// **'High-resolution PNG image of the box QR codes.'**
  String get highResolutionPngImageOf;

  /// No description provided for @barcodeImageCaptured.
  ///
  /// In en, this message translates to:
  /// **'Barcode image captured'**
  String get barcodeImageCaptured;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @failedToCaptureBarcodeGrid.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture barcode grid'**
  String get failedToCaptureBarcodeGrid;

  /// No description provided for @failedToGenerateImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate image'**
  String get failedToGenerateImage;

  /// No description provided for @couldnTExportTheLabels.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export the labels. Please try again.'**
  String get couldnTExportTheLabels;

  /// No description provided for @pdfGeneratedChooseSaveTo.
  ///
  /// In en, this message translates to:
  /// **'PDF generated. Choose \"Save to Files\" or share.'**
  String get pdfGeneratedChooseSaveTo;

  /// No description provided for @couldnTExportThePdf.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export the PDF. Please try again.'**
  String get couldnTExportThePdf;

  /// No description provided for @couldnTOpenThePrint.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the print preview. Please try again.'**
  String get couldnTOpenThePrint;

  /// No description provided for @exportAllBoxBarcodes.
  ///
  /// In en, this message translates to:
  /// **'Export All Box Barcodes'**
  String get exportAllBoxBarcodes;

  /// No description provided for @boxNotFound.
  ///
  /// In en, this message translates to:
  /// **'Box not found'**
  String get boxNotFound;

  /// No description provided for @exportBoxBarcodes.
  ///
  /// In en, this message translates to:
  /// **'Export Box Barcodes'**
  String get exportBoxBarcodes;

  /// No description provided for @captureAndSaveBarcodeSheet.
  ///
  /// In en, this message translates to:
  /// **'Capture and save barcode sheet as image'**
  String get captureAndSaveBarcodeSheet;

  /// No description provided for @saveImage.
  ///
  /// In en, this message translates to:
  /// **'Save Image'**
  String get saveImage;

  /// No description provided for @thisContainer.
  ///
  /// In en, this message translates to:
  /// **'This Container'**
  String get thisContainer;

  /// No description provided for @allContainers.
  ///
  /// In en, this message translates to:
  /// **'All Containers ({count})'**
  String allContainers(Object count);

  /// No description provided for @printSpecsFormat.
  ///
  /// In en, this message translates to:
  /// **'PRINT SPECS / FORMAT'**
  String get printSpecsFormat;

  /// No description provided for @a4TomyDecal.
  ///
  /// In en, this message translates to:
  /// **'A4 Tomy Decal'**
  String get a4TomyDecal;

  /// No description provided for @standardGridSheet.
  ///
  /// In en, this message translates to:
  /// **'Standard grid sheet'**
  String get standardGridSheet;

  /// No description provided for @thermal50x30mm.
  ///
  /// In en, this message translates to:
  /// **'Thermal 50x30mm'**
  String get thermal50x30mm;

  /// No description provided for @singleRollLabel.
  ///
  /// In en, this message translates to:
  /// **'Single roll label'**
  String get singleRollLabel;

  /// No description provided for @printPreview.
  ///
  /// In en, this message translates to:
  /// **'Print Preview'**
  String get printPreview;

  /// No description provided for @generatingPdf.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF...'**
  String get generatingPdf;

  /// No description provided for @exportPdfSaveShare.
  ///
  /// In en, this message translates to:
  /// **'Export PDF (Save/Share)'**
  String get exportPdfSaveShare;

  /// No description provided for @tapToKeepYourVersion.
  ///
  /// In en, this message translates to:
  /// **'Tap to keep your version or discard it'**
  String get tapToKeepYourVersion;

  /// No description provided for @unresolvedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unresolved changes'**
  String get unresolvedChanges;

  /// No description provided for @nothingLeftToResolve.
  ///
  /// In en, this message translates to:
  /// **'Nothing left to resolve.'**
  String get nothingLeftToResolve;

  /// No description provided for @commonDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get commonDiscard;

  /// No description provided for @keepMine.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get keepMine;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @recentItems.
  ///
  /// In en, this message translates to:
  /// **'Recent Items'**
  String get recentItems;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noItemsInInventoryYet.
  ///
  /// In en, this message translates to:
  /// **'No items in inventory yet'**
  String get noItemsInInventoryYet;

  /// No description provided for @tapToAddYourFirst.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first item'**
  String get tapToAddYourFirst;

  /// No description provided for @storageBox.
  ///
  /// In en, this message translates to:
  /// **'Storage Box'**
  String get storageBox;

  /// No description provided for @cannotConnectToBackend.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to backend ({serverUrl})'**
  String cannotConnectToBackend(Object serverUrl);

  /// No description provided for @actionRequired.
  ///
  /// In en, this message translates to:
  /// **'Action Required'**
  String get actionRequired;

  /// No description provided for @commonReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get commonReview;

  /// No description provided for @commonLending.
  ///
  /// In en, this message translates to:
  /// **'Lending'**
  String get commonLending;

  /// No description provided for @noLoans.
  ///
  /// In en, this message translates to:
  /// **'No Loans'**
  String get noLoans;

  /// No description provided for @commonAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get commonAlerts;

  /// No description provided for @allClear.
  ///
  /// In en, this message translates to:
  /// **'All Clear'**
  String get allClear;

  /// No description provided for @storageSpaces.
  ///
  /// In en, this message translates to:
  /// **'Storage Spaces'**
  String get storageSpaces;

  /// No description provided for @noStorageSpacesYet.
  ///
  /// In en, this message translates to:
  /// **'No storage spaces yet'**
  String get noStorageSpacesYet;

  /// No description provided for @subContainerInLocation.
  ///
  /// In en, this message translates to:
  /// **'Sub-container in location'**
  String get subContainerInLocation;

  /// No description provided for @primaryStorageSpace.
  ///
  /// In en, this message translates to:
  /// **'Primary storage space'**
  String get primaryStorageSpace;

  /// No description provided for @specificationsAttributes.
  ///
  /// In en, this message translates to:
  /// **'Specifications & Attributes'**
  String get specificationsAttributes;

  /// No description provided for @commonManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get commonManage;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @noSpecificationsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No specifications added yet'**
  String get noSpecificationsAddedYet;

  /// No description provided for @addCustomDetailsLikeColor.
  ///
  /// In en, this message translates to:
  /// **'Add custom details like Color, Size, Brand, or Specs.'**
  String get addCustomDetailsLikeColor;

  /// No description provided for @addSpecification.
  ///
  /// In en, this message translates to:
  /// **'Add Specification'**
  String get addSpecification;

  /// No description provided for @customizeAttributesAndMetadataFor.
  ///
  /// In en, this message translates to:
  /// **'Customize attributes and metadata for this item.'**
  String get customizeAttributesAndMetadataFor;

  /// No description provided for @currentSpecifications.
  ///
  /// In en, this message translates to:
  /// **'CURRENT SPECIFICATIONS'**
  String get currentSpecifications;

  /// No description provided for @commonRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed \"{key}\"'**
  String commonRemoved(Object key);

  /// No description provided for @suggestedAttributes.
  ///
  /// In en, this message translates to:
  /// **'SUGGESTED ATTRIBUTES'**
  String get suggestedAttributes;

  /// No description provided for @editAttribute.
  ///
  /// In en, this message translates to:
  /// **'EDIT ATTRIBUTE'**
  String get editAttribute;

  /// No description provided for @addAttribute.
  ///
  /// In en, this message translates to:
  /// **'ADD ATTRIBUTE'**
  String get addAttribute;

  /// No description provided for @attributeName.
  ///
  /// In en, this message translates to:
  /// **'Attribute Name'**
  String get attributeName;

  /// No description provided for @eGColorRamSize.
  ///
  /// In en, this message translates to:
  /// **'e.g. Color, RAM, Size, Material'**
  String get eGColorRamSize;

  /// No description provided for @attributeValue.
  ///
  /// In en, this message translates to:
  /// **'Attribute Value'**
  String get attributeValue;

  /// No description provided for @eGSpaceBlack16gb.
  ///
  /// In en, this message translates to:
  /// **'e.g. Space Black, 16GB, XL'**
  String get eGSpaceBlack16gb;

  /// No description provided for @pleaseEnterAnAttributeName.
  ///
  /// In en, this message translates to:
  /// **'Please enter an attribute name'**
  String get pleaseEnterAnAttributeName;

  /// No description provided for @pleaseEnterAnAttributeValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter an attribute value'**
  String get pleaseEnterAnAttributeValue;

  /// No description provided for @savedAttribute.
  ///
  /// In en, this message translates to:
  /// **'Saved attribute \"{k}\"'**
  String savedAttribute(Object k);

  /// No description provided for @saveAttribute.
  ///
  /// In en, this message translates to:
  /// **'Save Attribute'**
  String get saveAttribute;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategory;

  /// No description provided for @createACustomCategoryFor.
  ///
  /// In en, this message translates to:
  /// **'Create a custom category for your assets'**
  String get createACustomCategoryFor;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @eGPhotographyWatchesBoard.
  ///
  /// In en, this message translates to:
  /// **'e.g. Photography, Watches, Board Games'**
  String get eGPhotographyWatchesBoard;

  /// No description provided for @pleaseEnterACategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get pleaseEnterACategoryName;

  /// No description provided for @categoryAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Category already exists'**
  String get categoryAlreadyExists;

  /// No description provided for @addSelect.
  ///
  /// In en, this message translates to:
  /// **'Add & Select'**
  String get addSelect;

  /// No description provided for @overdueLoan.
  ///
  /// In en, this message translates to:
  /// **'Overdue Loan'**
  String get overdueLoan;

  /// No description provided for @currentlyLentOut.
  ///
  /// In en, this message translates to:
  /// **'Currently Lent Out'**
  String get currentlyLentOut;

  /// No description provided for @commonBorrower2.
  ///
  /// In en, this message translates to:
  /// **'Borrower: {borrowerName}'**
  String commonBorrower2(Object borrowerName);

  /// No description provided for @commonContact.
  ///
  /// In en, this message translates to:
  /// **'Contact: {borrowerContact}'**
  String commonContact(Object borrowerContact);

  /// No description provided for @commonChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get commonChange;

  /// No description provided for @unknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown Location'**
  String get unknownLocation;

  /// No description provided for @productHasExpired.
  ///
  /// In en, this message translates to:
  /// **'Product has Expired!'**
  String get productHasExpired;

  /// No description provided for @expiresSoonInDays.
  ///
  /// In en, this message translates to:
  /// **'Expires soon in {daysLeft} days'**
  String expiresSoonInDays(Object daysLeft);

  /// No description provided for @freshDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'Fresh • {daysLeft} days remaining'**
  String freshDaysRemaining(Object daysLeft);

  /// No description provided for @lowStockWarning.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Warning'**
  String get lowStockWarning;

  /// No description provided for @currentThreshold.
  ///
  /// In en, this message translates to:
  /// **'Current: {qty} {unit} • Threshold: ≤ {minQty} {unit2}'**
  String currentThreshold(Object qty, Object unit, Object minQty, Object unit2);

  /// No description provided for @assetPurchaseInformation.
  ///
  /// In en, this message translates to:
  /// **'Asset & Purchase Information'**
  String get assetPurchaseInformation;

  /// No description provided for @purchasePrice2.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price'**
  String get purchasePrice2;

  /// No description provided for @notRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get notRecorded;

  /// No description provided for @purchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date'**
  String get purchaseDate;

  /// No description provided for @lowStockAlertThreshold.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert Threshold'**
  String get lowStockAlertThreshold;

  /// No description provided for @notTracked.
  ///
  /// In en, this message translates to:
  /// **'Not tracked'**
  String get notTracked;

  /// No description provided for @barcodeUpcEan.
  ///
  /// In en, this message translates to:
  /// **'Barcode (UPC/EAN)'**
  String get barcodeUpcEan;

  /// No description provided for @warrantyExpired.
  ///
  /// In en, this message translates to:
  /// **'Warranty Expired'**
  String get warrantyExpired;

  /// No description provided for @warrantyActive.
  ///
  /// In en, this message translates to:
  /// **'Warranty Active'**
  String get warrantyActive;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied {label} to clipboard'**
  String copiedToClipboard(Object label);

  /// No description provided for @addAttribute2.
  ///
  /// In en, this message translates to:
  /// **'Add Attribute'**
  String get addAttribute2;

  /// No description provided for @addCustomAttributesLikeColor.
  ///
  /// In en, this message translates to:
  /// **'Add custom attributes like Color, Size, RAM, or Brand'**
  String get addCustomAttributesLikeColor;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @editSpecification.
  ///
  /// In en, this message translates to:
  /// **'Edit Specification'**
  String get editSpecification;

  /// No description provided for @eGColorRamSize2.
  ///
  /// In en, this message translates to:
  /// **'e.g. Color, RAM, Size, Material, Weight'**
  String get eGColorRamSize2;

  /// No description provided for @eGSpaceBlack16gb2.
  ///
  /// In en, this message translates to:
  /// **'e.g. Space Black, 16GB, XL, Leather'**
  String get eGSpaceBlack16gb2;

  /// No description provided for @saveSpecification.
  ///
  /// In en, this message translates to:
  /// **'Save Specification'**
  String get saveSpecification;

  /// No description provided for @paperReceipt.
  ///
  /// In en, this message translates to:
  /// **'Paper Receipt'**
  String get paperReceipt;

  /// No description provided for @storeInvoice.
  ///
  /// In en, this message translates to:
  /// **'Store Invoice'**
  String get storeInvoice;

  /// No description provided for @warrantyCard.
  ///
  /// In en, this message translates to:
  /// **'Warranty Card'**
  String get warrantyCard;

  /// No description provided for @addReceiptPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Receipt Photo'**
  String get addReceiptPhoto;

  /// No description provided for @addProductPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Product Photo'**
  String get addProductPhoto;

  /// No description provided for @commonCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get commonCamera;

  /// No description provided for @commonGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get commonGallery;

  /// No description provided for @orViaUrl.
  ///
  /// In en, this message translates to:
  /// **'OR VIA URL'**
  String get orViaUrl;

  /// No description provided for @imageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrl;

  /// No description provided for @photoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added'**
  String get photoAdded;

  /// No description provided for @addViaUrl.
  ///
  /// In en, this message translates to:
  /// **'Add via URL'**
  String get addViaUrl;

  /// No description provided for @orChooseSamplePhoto.
  ///
  /// In en, this message translates to:
  /// **'Or choose sample photo'**
  String get orChooseSamplePhoto;

  /// No description provided for @samplePhotoSelected.
  ///
  /// In en, this message translates to:
  /// **'Sample photo selected'**
  String get samplePhotoSelected;

  /// No description provided for @commonConsume2.
  ///
  /// In en, this message translates to:
  /// **'Consume: {name}'**
  String commonConsume2(Object name);

  /// No description provided for @currentStock.
  ///
  /// In en, this message translates to:
  /// **'Current stock: {formattedCurrent} {unit}'**
  String currentStock(Object formattedCurrent, Object unit);

  /// No description provided for @quantityToUse.
  ///
  /// In en, this message translates to:
  /// **'Quantity to use:'**
  String get quantityToUse;

  /// No description provided for @use1.
  ///
  /// In en, this message translates to:
  /// **'Use 1 {unit}'**
  String use1(Object unit);

  /// No description provided for @use2.
  ///
  /// In en, this message translates to:
  /// **'Use 2 {unit}'**
  String use2(Object unit);

  /// No description provided for @use5.
  ///
  /// In en, this message translates to:
  /// **'Use 5 {unit}'**
  String use5(Object unit);

  /// No description provided for @useAll.
  ///
  /// In en, this message translates to:
  /// **'Use All'**
  String get useAll;

  /// No description provided for @willBeOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Will be out of stock after use'**
  String get willBeOutOfStock;

  /// No description provided for @remainingAfterUse.
  ///
  /// In en, this message translates to:
  /// **'Remaining after use: {formattedRemain} {unit}'**
  String remainingAfterUse(Object formattedRemain, Object unit);

  /// No description provided for @commonRestock.
  ///
  /// In en, this message translates to:
  /// **'Restock'**
  String get commonRestock;

  /// No description provided for @usedRemaining.
  ///
  /// In en, this message translates to:
  /// **'Used {formattedConsume} {unit}. Remaining: {formattedRemain} {unit2}'**
  String usedRemaining(
    Object formattedConsume,
    Object unit,
    Object formattedRemain,
    Object unit2,
  );

  /// No description provided for @warningQuantityHasDroppedTo.
  ///
  /// In en, this message translates to:
  /// **'Warning: Quantity has dropped to minimum level (≤ {minQuantity} {unit})'**
  String warningQuantityHasDroppedTo(Object minQuantity, Object unit);

  /// No description provided for @confirmUse.
  ///
  /// In en, this message translates to:
  /// **'Confirm Use'**
  String get confirmUse;

  /// No description provided for @commonRestock2.
  ///
  /// In en, this message translates to:
  /// **'Restock: {name}'**
  String commonRestock2(Object name);

  /// No description provided for @quantityToAdd.
  ///
  /// In en, this message translates to:
  /// **'Quantity to add ({unit})'**
  String quantityToAdd(Object unit);

  /// No description provided for @addedTotal.
  ///
  /// In en, this message translates to:
  /// **'Added {addAmount} {unit}. Total: {formattedNew} {unit2}'**
  String addedTotal(
    Object addAmount,
    Object unit,
    Object formattedNew,
    Object unit2,
  );

  /// No description provided for @confirmRestock.
  ///
  /// In en, this message translates to:
  /// **'Confirm Restock'**
  String get confirmRestock;

  /// No description provided for @commonRoot.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get commonRoot;

  /// No description provided for @storeDirectlyIn.
  ///
  /// In en, this message translates to:
  /// **'Store directly in \"{name}\"'**
  String storeDirectlyIn(Object name);

  /// No description provided for @commonCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get commonCurrent;

  /// No description provided for @placeItemAtThisLevel.
  ///
  /// In en, this message translates to:
  /// **'Place item at this level without placing it into any sub-box'**
  String get placeItemAtThisLevel;

  /// No description provided for @chooseARoomShelfOr.
  ///
  /// In en, this message translates to:
  /// **'Choose a room, shelf, or container'**
  String get chooseARoomShelfOr;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get scanQr;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @subContainersInside.
  ///
  /// In en, this message translates to:
  /// **'Sub-containers inside ({count})'**
  String subContainersInside(Object count);

  /// No description provided for @noSubContainersInside.
  ///
  /// In en, this message translates to:
  /// **'No sub-containers inside \"{name}\"'**
  String noSubContainersInside(Object name);

  /// No description provided for @noLocationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No locations available'**
  String get noLocationsAvailable;

  /// No description provided for @youCanSelectDirectlyAbove.
  ///
  /// In en, this message translates to:
  /// **'You can select \"{name}\" directly above.'**
  String youCanSelectDirectlyAbove(Object name);

  /// No description provided for @currentlySelectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Currently selected location'**
  String get currentlySelectedLocation;

  /// No description provided for @selectedStorageDestination.
  ///
  /// In en, this message translates to:
  /// **'Selected Storage Destination'**
  String get selectedStorageDestination;

  /// No description provided for @moveItemLocation.
  ///
  /// In en, this message translates to:
  /// **'Move Item Location'**
  String get moveItemLocation;

  /// No description provided for @selectNewStorageDestinationFor.
  ///
  /// In en, this message translates to:
  /// **'Select new storage destination for \"{name}\"'**
  String selectNewStorageDestinationFor(Object name);

  /// No description provided for @confirmMove.
  ///
  /// In en, this message translates to:
  /// **'Confirm Move'**
  String get confirmMove;

  /// No description provided for @movedTo.
  ///
  /// In en, this message translates to:
  /// **'Moved \"{name}\" to \"{name2}\"'**
  String movedTo(Object name, Object name2);

  /// No description provided for @selectNewStorageDestinationFor2.
  ///
  /// In en, this message translates to:
  /// **'Select new storage destination for item'**
  String get selectNewStorageDestinationFor2;

  /// No description provided for @youCanStoreDirectlyIn.
  ///
  /// In en, this message translates to:
  /// **'You can store \"{name}\" directly in this container.'**
  String youCanStoreDirectlyIn(Object name);

  /// No description provided for @itemIsAlreadyInThis.
  ///
  /// In en, this message translates to:
  /// **'Item is already in this location'**
  String get itemIsAlreadyInThis;

  /// No description provided for @targetDestination.
  ///
  /// In en, this message translates to:
  /// **'Target Destination'**
  String get targetDestination;

  /// No description provided for @bulkMoveLocation.
  ///
  /// In en, this message translates to:
  /// **'Bulk Move Location'**
  String get bulkMoveLocation;

  /// No description provided for @moveAndContents.
  ///
  /// In en, this message translates to:
  /// **'Move \"{name}\" and contents'**
  String moveAndContents(Object name);

  /// No description provided for @allItemsAndNestedContainers.
  ///
  /// In en, this message translates to:
  /// **'All {totalItems} items and {totalSubBoxes} nested containers inside will move along with this container.'**
  String allItemsAndNestedContainers(Object totalItems, Object totalSubBoxes);

  /// No description provided for @selectDestination.
  ///
  /// In en, this message translates to:
  /// **'Select Destination'**
  String get selectDestination;

  /// No description provided for @rootLevelNoParentContainer.
  ///
  /// In en, this message translates to:
  /// **'Root Level (No Parent Container)'**
  String get rootLevelNoParentContainer;

  /// No description provided for @topOfHierarchy.
  ///
  /// In en, this message translates to:
  /// **'Top of hierarchy'**
  String get topOfHierarchy;

  /// No description provided for @movedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Moved \"{name}\" successfully'**
  String movedSuccessfully(Object name);

  /// No description provided for @cannotMoveContainerIntoIts.
  ///
  /// In en, this message translates to:
  /// **'Cannot move container into its own descendant'**
  String get cannotMoveContainerIntoIts;

  /// No description provided for @serverEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Server Endpoint'**
  String get serverEndpoint;

  /// No description provided for @apiAuthentication.
  ///
  /// In en, this message translates to:
  /// **'API Authentication'**
  String get apiAuthentication;

  /// No description provided for @authenticatedAs.
  ///
  /// In en, this message translates to:
  /// **'Authenticated as {userName}'**
  String authenticatedAs(Object userName);

  /// No description provided for @loginSwitch.
  ///
  /// In en, this message translates to:
  /// **'Login / Switch'**
  String get loginSwitch;

  /// No description provided for @syncWithServer.
  ///
  /// In en, this message translates to:
  /// **'Sync With Server'**
  String get syncWithServer;

  /// No description provided for @synchronizingBoxesItemsAlerts.
  ///
  /// In en, this message translates to:
  /// **'Synchronizing boxes, items & alerts...'**
  String get synchronizingBoxesItemsAlerts;

  /// No description provided for @pullLatestInventoryLendingRecords.
  ///
  /// In en, this message translates to:
  /// **'Pull latest inventory & lending records'**
  String get pullLatestInventoryLendingRecords;

  /// No description provided for @successfullySynchronizedWithBackendServer.
  ///
  /// In en, this message translates to:
  /// **'Successfully synchronized with backend server'**
  String get successfullySynchronizedWithBackendServer;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @backendApiUrl.
  ///
  /// In en, this message translates to:
  /// **'Backend API URL'**
  String get backendApiUrl;

  /// No description provided for @enterTheBackendBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter the backend base URL (default: http://localhost:8080):'**
  String get enterTheBackendBaseUrl;

  /// No description provided for @serverUrlUpdatedTo.
  ///
  /// In en, this message translates to:
  /// **'Server URL updated to {newUrl}'**
  String serverUrlUpdatedTo(Object newUrl);

  /// No description provided for @saveConnect.
  ///
  /// In en, this message translates to:
  /// **'Save & Connect'**
  String get saveConnect;

  /// No description provided for @usDollar.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get usDollar;

  /// No description provided for @vietnameseDong.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese Dong'**
  String get vietnameseDong;

  /// No description provided for @commonEuro.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get commonEuro;

  /// No description provided for @britishPound.
  ///
  /// In en, this message translates to:
  /// **'British Pound'**
  String get britishPound;

  /// No description provided for @japaneseYen.
  ///
  /// In en, this message translates to:
  /// **'Japanese Yen'**
  String get japaneseYen;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @appliedToPriceCalculationsAsset.
  ///
  /// In en, this message translates to:
  /// **'Applied to price calculations & asset valuation'**
  String get appliedToPriceCalculationsAsset;

  /// No description provided for @currencyChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Currency changed to {sym}'**
  String currencyChangedTo(Object sym);

  /// No description provided for @defaultMeasuringUnitWhenCreating.
  ///
  /// In en, this message translates to:
  /// **'Default measuring unit when creating new items'**
  String get defaultMeasuringUnitWhenCreating;

  /// No description provided for @defaultUnitSetTo.
  ///
  /// In en, this message translates to:
  /// **'Default unit set to \"{unit}\"'**
  String defaultUnitSetTo(Object unit);

  /// No description provided for @howManyDaysBeforeExpiration.
  ///
  /// In en, this message translates to:
  /// **'How many days before expiration to alert you'**
  String get howManyDaysBeforeExpiration;

  /// No description provided for @alertWindowSetToDays.
  ///
  /// In en, this message translates to:
  /// **'Alert window set to {days} days'**
  String alertWindowSetToDays(Object days);

  /// No description provided for @howManyDaysBeforeWarranty.
  ///
  /// In en, this message translates to:
  /// **'How many days before warranty ends to alert you'**
  String get howManyDaysBeforeWarranty;

  /// No description provided for @warrantyWindowSetToDays.
  ///
  /// In en, this message translates to:
  /// **'Warranty window set to {days} days'**
  String warrantyWindowSetToDays(Object days);

  /// No description provided for @alertsTreatTodayInThis.
  ///
  /// In en, this message translates to:
  /// **'Alerts treat \"today\" in this time zone'**
  String get alertsTreatTodayInThis;

  /// No description provided for @timeZoneSetTo.
  ///
  /// In en, this message translates to:
  /// **'Time zone set to {tz}'**
  String timeZoneSetTo(Object tz);

  /// No description provided for @updateYourDisplayNameAnd.
  ///
  /// In en, this message translates to:
  /// **'Update your display name and inventory role'**
  String get updateYourDisplayNameAnd;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @eGSaraWilson.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sara Wilson'**
  String get eGSaraWilson;

  /// No description provided for @roleDepartment.
  ///
  /// In en, this message translates to:
  /// **'Role / Department'**
  String get roleDepartment;

  /// No description provided for @eGAssetManagerHome.
  ///
  /// In en, this message translates to:
  /// **'e.g. Asset Manager, Home Owner'**
  String get eGAssetManagerHome;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @commonNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get commonNew;

  /// No description provided for @searchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get searchCategories;

  /// No description provided for @noCategoriesMatch.
  ///
  /// In en, this message translates to:
  /// **'No categories match \"{searchQuery}\"'**
  String noCategoriesMatch(Object searchQuery);

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @deleteCategoryAnyItemsIn.
  ///
  /// In en, this message translates to:
  /// **'Delete category \"{cat}\"? Any items in this category will be reassigned to \"General\".'**
  String deleteCategoryAnyItemsIn(Object cat);

  /// No description provided for @categoryRemoved.
  ///
  /// In en, this message translates to:
  /// **'Category \"{cat}\" removed'**
  String categoryRemoved(Object cat);

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get addNewCategory;

  /// No description provided for @enterACategoryNameFor.
  ///
  /// In en, this message translates to:
  /// **'Enter a category name for your catalog'**
  String get enterACategoryNameFor;

  /// No description provided for @eGPhotographyBoardGames.
  ///
  /// In en, this message translates to:
  /// **'e.g. Photography, Board Games, Hardware'**
  String get eGPhotographyBoardGames;

  /// No description provided for @categoryCreated2.
  ///
  /// In en, this message translates to:
  /// **'Category \"{name}\" created'**
  String categoryCreated2(Object name);

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @inventoryReport.
  ///
  /// In en, this message translates to:
  /// **'Inventory Report'**
  String get inventoryReport;

  /// No description provided for @generatedPlainTextInventoryStatus.
  ///
  /// In en, this message translates to:
  /// **'Generated plain-text inventory status report'**
  String get generatedPlainTextInventoryStatus;

  /// No description provided for @reportCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Report copied to clipboard!'**
  String get reportCopiedToClipboard;

  /// No description provided for @copyReportToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy Report to Clipboard'**
  String get copyReportToClipboard;

  /// No description provided for @realTimeConditionBreakdownOf.
  ///
  /// In en, this message translates to:
  /// **'Real-time condition breakdown of {total} tracked items'**
  String realTimeConditionBreakdownOf(Object total);

  /// No description provided for @storedInContainers.
  ///
  /// In en, this message translates to:
  /// **'Stored in Containers'**
  String get storedInContainers;

  /// No description provided for @inUseActive.
  ///
  /// In en, this message translates to:
  /// **'In Use / Active'**
  String get inUseActive;

  /// No description provided for @lentToBorrowers.
  ///
  /// In en, this message translates to:
  /// **'Lent to Borrowers'**
  String get lentToBorrowers;

  /// No description provided for @expiringSoonD.
  ///
  /// In en, this message translates to:
  /// **'Expiring Soon (≤ {expiryWarningDays}d)'**
  String expiringSoonD(Object expiryWarningDays);

  /// No description provided for @expiredAssets.
  ///
  /// In en, this message translates to:
  /// **'Expired Assets'**
  String get expiredAssets;

  /// No description provided for @initialStock.
  ///
  /// In en, this message translates to:
  /// **'Initial stock'**
  String get initialStock;

  /// No description provided for @commonRestocked.
  ///
  /// In en, this message translates to:
  /// **'Restocked'**
  String get commonRestocked;

  /// No description provided for @commonUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get commonUsed;

  /// No description provided for @commonDamaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged'**
  String get commonDamaged;

  /// No description provided for @commonLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get commonLost;

  /// No description provided for @commonCorrection.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get commonCorrection;

  /// No description provided for @commonMoved.
  ///
  /// In en, this message translates to:
  /// **'Moved'**
  String get commonMoved;

  /// No description provided for @commonAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Adjusted'**
  String get commonAdjusted;

  /// No description provided for @couldNotLoadStockHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load stock history'**
  String get couldNotLoadStockHistory;

  /// No description provided for @noConsumptionDataYet.
  ///
  /// In en, this message translates to:
  /// **'No consumption data yet'**
  String get noConsumptionDataYet;

  /// No description provided for @avgDayAboutDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'Avg {count}/day · about {count2} days left'**
  String avgDayAboutDaysLeft(Object count, Object count2);

  /// No description provided for @noMovementsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No movements recorded'**
  String get noMovementsRecorded;

  /// No description provided for @thermalLabelPrint.
  ///
  /// In en, this message translates to:
  /// **'Thermal Label Print'**
  String get thermalLabelPrint;

  /// No description provided for @standardPrintableAdhesiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Standard printable adhesive label'**
  String get standardPrintableAdhesiveLabel;

  /// No description provided for @thermalLabelCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Thermal label copied to clipboard'**
  String get thermalLabelCopiedToClipboard;

  /// No description provided for @copyId.
  ///
  /// In en, this message translates to:
  /// **'Copy ID'**
  String get copyId;

  /// No description provided for @thermalLabelSentToPrinter.
  ///
  /// In en, this message translates to:
  /// **'Thermal label sent to printer ({value}mm)'**
  String thermalLabelSentToPrinter(Object value);

  /// No description provided for @commonInitializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get commonInitializing;

  /// No description provided for @youWereSignedOutOn.
  ///
  /// In en, this message translates to:
  /// **'You were signed out on another device. Please sign in again.'**
  String get youWereSignedOutOn;

  /// No description provided for @yourSessionHasExpiredPlease.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get yourSessionHasExpiredPlease;

  /// No description provided for @connectingToServer.
  ///
  /// In en, this message translates to:
  /// **'Connecting to server...'**
  String get connectingToServer;

  /// No description provided for @commonAuthenticating.
  ///
  /// In en, this message translates to:
  /// **'Authenticating...'**
  String get commonAuthenticating;

  /// No description provided for @syncingInventory.
  ///
  /// In en, this message translates to:
  /// **'Syncing inventory...'**
  String get syncingInventory;

  /// No description provided for @commonReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get commonReady;

  /// No description provided for @couldnTSignInPlease.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in. Please try again.'**
  String get couldnTSignInPlease;

  /// No description provided for @couldnTSignInWith.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in with Google. Please try again.'**
  String get couldnTSignInWith;

  /// No description provided for @couldnTCreateYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create your account. Please try again.'**
  String get couldnTCreateYourAccount;

  /// No description provided for @couldNotReachTheServer.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check your connection and try again.'**
  String get couldNotReachTheServer;

  /// No description provided for @cannotReachTheServer.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server'**
  String get cannotReachTheServer;

  /// No description provided for @couldnTSyncYourData.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sync your data. Pull down to retry.'**
  String get couldnTSyncYourData;

  /// No description provided for @thisWasChangedElsewhereShowing.
  ///
  /// In en, this message translates to:
  /// **'This was changed elsewhere. Showing the latest version.'**
  String get thisWasChangedElsewhereShowing;

  /// No description provided for @commonManager.
  ///
  /// In en, this message translates to:
  /// **'Manager: {userName} ({userRole})'**
  String commonManager(Object userName, Object userRole);

  /// No description provided for @serverBackend.
  ///
  /// In en, this message translates to:
  /// **'Server Backend: {baseUrl}'**
  String serverBackend(Object baseUrl);

  /// No description provided for @endOfReport.
  ///
  /// In en, this message translates to:
  /// **'End of report'**
  String get endOfReport;

  /// No description provided for @somethingWentWrongPleaseTry.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrongPleaseTry;

  /// No description provided for @incorrectEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get incorrectEmailOrPassword;

  /// No description provided for @thatItemNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'That item no longer exists.'**
  String get thatItemNoLongerExists;

  /// No description provided for @thisWasChangedSomewhereElse.
  ///
  /// In en, this message translates to:
  /// **'This was changed somewhere else. Refresh and try again.'**
  String get thisWasChangedSomewhereElse;

  /// No description provided for @tooManyAttemptsPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get tooManyAttemptsPleaseWait;

  /// No description provided for @theServerIsBusyRight.
  ///
  /// In en, this message translates to:
  /// **'The server is busy right now. Please try again shortly.'**
  String get theServerIsBusyRight;

  /// No description provided for @canTReachTheServer.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection and try again.'**
  String get canTReachTheServer;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'INVENTORY STATUS REPORT'**
  String get reportTitle;

  /// No description provided for @reportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated: {date}'**
  String reportGenerated(Object date);

  /// No description provided for @reportOverview.
  ///
  /// In en, this message translates to:
  /// **'1. OVERVIEW STATISTICS:'**
  String get reportOverview;

  /// No description provided for @reportTotalContainers.
  ///
  /// In en, this message translates to:
  /// **'- Total Storage Containers: {count}'**
  String reportTotalContainers(Object count);

  /// No description provided for @reportTotalItems.
  ///
  /// In en, this message translates to:
  /// **'- Total Inventory Items: {count}'**
  String reportTotalItems(Object count);

  /// No description provided for @reportTotalValue.
  ///
  /// In en, this message translates to:
  /// **'- Total Estimated Value: {value}'**
  String reportTotalValue(Object value);

  /// No description provided for @reportActiveLent.
  ///
  /// In en, this message translates to:
  /// **'- Active Lent Items: {count}'**
  String reportActiveLent(Object count);

  /// No description provided for @reportOverdueLent.
  ///
  /// In en, this message translates to:
  /// **'- Overdue Lent Items: {count}'**
  String reportOverdueLent(Object count);

  /// No description provided for @reportExpired.
  ///
  /// In en, this message translates to:
  /// **'- Expired Items: {count}'**
  String reportExpired(Object count);

  /// No description provided for @reportExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'- Expiring Soon (within {days} days): {count}'**
  String reportExpiringSoon(Object days, Object count);

  /// No description provided for @reportCategories.
  ///
  /// In en, this message translates to:
  /// **'2. CATEGORIES BREAKDOWN:'**
  String get reportCategories;

  /// No description provided for @reportCategoryLine.
  ///
  /// In en, this message translates to:
  /// **'- {category}: {count} items'**
  String reportCategoryLine(Object category, Object count);

  /// No description provided for @reportCurrentItems.
  ///
  /// In en, this message translates to:
  /// **'3. CURRENT INVENTORY ITEMS:'**
  String get reportCurrentItems;

  /// No description provided for @reportPrice.
  ///
  /// In en, this message translates to:
  /// **' | Price: {price}'**
  String reportPrice(Object price);

  /// No description provided for @reportNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No Location'**
  String get reportNoLocation;

  /// No description provided for @qtyValue.
  ///
  /// In en, this message translates to:
  /// **'Qty: {qty}'**
  String qtyValue(Object qty);

  /// No description provided for @storageTypeRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get storageTypeRoom;

  /// No description provided for @storageTypeCabinet.
  ///
  /// In en, this message translates to:
  /// **'Cabinet / Wardrobe'**
  String get storageTypeCabinet;

  /// No description provided for @storageTypeShelf.
  ///
  /// In en, this message translates to:
  /// **'Shelf / Rack'**
  String get storageTypeShelf;

  /// No description provided for @storageTypeBox.
  ///
  /// In en, this message translates to:
  /// **'Box / Bin'**
  String get storageTypeBox;

  /// No description provided for @storageTypeDrawer.
  ///
  /// In en, this message translates to:
  /// **'Drawer'**
  String get storageTypeDrawer;

  /// No description provided for @storageTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get storageTypeOther;

  /// No description provided for @statusStored.
  ///
  /// In en, this message translates to:
  /// **'Stored'**
  String get statusStored;

  /// No description provided for @statusInUse.
  ///
  /// In en, this message translates to:
  /// **'In Use'**
  String get statusInUse;

  /// No description provided for @statusLent.
  ///
  /// In en, this message translates to:
  /// **'Lent'**
  String get statusLent;

  /// No description provided for @statusBroken.
  ///
  /// In en, this message translates to:
  /// **'Broken'**
  String get statusBroken;

  /// No description provided for @statusDisposed.
  ///
  /// In en, this message translates to:
  /// **'Disposed'**
  String get statusDisposed;

  /// No description provided for @statusLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get statusLost;

  /// No description provided for @heyName.
  ///
  /// In en, this message translates to:
  /// **'Hey {name}!'**
  String heyName(Object name);

  /// No description provided for @heyFallbackName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get heyFallbackName;

  /// No description provided for @markReturnedBy.
  ///
  /// In en, this message translates to:
  /// **'Mark \"{item}\" as returned by {borrower}?\nStatus will change back to Stored.'**
  String markReturnedBy(Object item, Object borrower);

  /// No description provided for @leaveEmptyToLendAll.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to lend all ({qty} in stock)'**
  String leaveEmptyToLendAll(Object qty);

  /// No description provided for @itemFallbackName.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get itemFallbackName;

  /// No description provided for @createFirstLocation.
  ///
  /// In en, this message translates to:
  /// **'Create your first location'**
  String get createFirstLocation;

  /// No description provided for @addFirstItem.
  ///
  /// In en, this message translates to:
  /// **'Add your first item'**
  String get addFirstItem;

  /// No description provided for @firstRoomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do you keep your things?'**
  String get firstRoomsTitle;

  /// No description provided for @firstRoomsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the rooms you have. You can add cabinets, shelves and boxes inside them later.'**
  String get firstRoomsSubtitle;

  /// No description provided for @roomLivingRoom.
  ///
  /// In en, this message translates to:
  /// **'Living room'**
  String get roomLivingRoom;

  /// No description provided for @roomKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get roomKitchen;

  /// No description provided for @roomBedroom.
  ///
  /// In en, this message translates to:
  /// **'Bedroom'**
  String get roomBedroom;

  /// No description provided for @roomBathroom.
  ///
  /// In en, this message translates to:
  /// **'Bathroom'**
  String get roomBathroom;

  /// No description provided for @roomGarage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get roomGarage;

  /// No description provided for @roomOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get roomOffice;

  /// No description provided for @roomStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage room'**
  String get roomStorage;

  /// No description provided for @createSelectedRooms.
  ///
  /// In en, this message translates to:
  /// **'Create selected ({count})'**
  String createSelectedRooms(Object count);

  /// No description provided for @addMyOwnLocation.
  ///
  /// In en, this message translates to:
  /// **'Add my own'**
  String get addMyOwnLocation;

  /// No description provided for @locationsCreatedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} locations created'**
  String locationsCreatedCount(Object count);

  /// No description provided for @flashlight.
  ///
  /// In en, this message translates to:
  /// **'Flashlight'**
  String get flashlight;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. If you leave now they will be lost.'**
  String get discardChangesMessage;

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'More details'**
  String get moreDetails;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scanBarcode;

  /// No description provided for @createLocationHere.
  ///
  /// In en, this message translates to:
  /// **'Create new location here'**
  String get createLocationHere;

  /// No description provided for @locationNameHint.
  ///
  /// In en, this message translates to:
  /// **'Location name'**
  String get locationNameHint;

  /// No description provided for @lentOnDate.
  ///
  /// In en, this message translates to:
  /// **'Lent on: {date}'**
  String lentOnDate(String date);

  /// No description provided for @expectedReturnOn.
  ///
  /// In en, this message translates to:
  /// **'Expected return: {date}'**
  String expectedReturnOn(String date);

  /// No description provided for @expiryDateOn.
  ///
  /// In en, this message translates to:
  /// **'Expiry date: {date}'**
  String expiryDateOn(String date);

  /// No description provided for @validUntilDate.
  ///
  /// In en, this message translates to:
  /// **'Valid until: {date}'**
  String validUntilDate(String date);

  /// No description provided for @daysLeftCount.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day left} other{{days} days left}}'**
  String daysLeftCount(int days);

  /// No description provided for @expiredAgoOn.
  ///
  /// In en, this message translates to:
  /// **'Expired {days, plural, =1{1 day} other{{days} days}} ago ({date})'**
  String expiredAgoOn(int days, String date);

  /// No description provided for @expiresInOn.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days, plural, =1{1 day} other{{days} days}} ({date})'**
  String expiresInOn(int days, String date);

  /// No description provided for @tagOverdue.
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get tagOverdue;

  /// No description provided for @tagLent.
  ///
  /// In en, this message translates to:
  /// **'LENT'**
  String get tagLent;

  /// No description provided for @tagReturned.
  ///
  /// In en, this message translates to:
  /// **'RETURNED'**
  String get tagReturned;

  /// No description provided for @tagLowStock.
  ///
  /// In en, this message translates to:
  /// **'LOW STOCK'**
  String get tagLowStock;

  /// No description provided for @tagExpired.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get tagExpired;

  /// No description provided for @expiresInShort.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days}d'**
  String expiresInShort(int days);

  /// No description provided for @inPlacePath.
  ///
  /// In en, this message translates to:
  /// **'In: {path}'**
  String inPlacePath(String path);

  /// No description provided for @assetsTracked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 asset tracked} other{{count} assets tracked}}'**
  String assetsTracked(int count);

  /// No description provided for @itemsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemsCountLabel(int count);

  /// No description provided for @nestedCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} nested'**
  String nestedCountLabel(int count);

  /// No description provided for @subContainersCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 sub-container} other{{count} sub-containers}}'**
  String subContainersCountLabel(int count);

  /// No description provided for @statusOnlineTag.
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get statusOnlineTag;

  /// No description provided for @statusOfflineTag.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get statusOfflineTag;

  /// No description provided for @itemNowInUse.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is now in use'**
  String itemNowInUse(String name);

  /// No description provided for @developerBadge.
  ///
  /// In en, this message translates to:
  /// **'DEVELOPER'**
  String get developerBadge;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Smart inventory & asset tracker'**
  String get splashTagline;

  /// No description provided for @continueToApp.
  ///
  /// In en, this message translates to:
  /// **'Continue to app →'**
  String get continueToApp;

  /// No description provided for @changesNeedAttention.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 offline change needs your attention} other{{count} offline changes need your attention}}'**
  String changesNeedAttention(int count);

  /// No description provided for @changesRejectedByServer.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 offline change was rejected by the server} other{{count} offline changes were rejected by the server}}'**
  String changesRejectedByServer(int count);

  /// No description provided for @opRejectedBecause.
  ///
  /// In en, this message translates to:
  /// **'{operation} was rejected: {reason}'**
  String opRejectedBecause(String operation, String reason);

  /// No description provided for @discardChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this change?'**
  String get discardChangeTitle;

  /// No description provided for @discardChangeMessage.
  ///
  /// In en, this message translates to:
  /// **'Your change will be dropped and the version on the server stays.'**
  String get discardChangeMessage;

  /// No description provided for @opCreateItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get opCreateItem;

  /// No description provided for @opUpdateItem.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get opUpdateItem;

  /// No description provided for @opDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get opDeleteItem;

  /// No description provided for @opMoveItem.
  ///
  /// In en, this message translates to:
  /// **'Move item'**
  String get opMoveItem;

  /// No description provided for @opChangeQuantity.
  ///
  /// In en, this message translates to:
  /// **'Change quantity'**
  String get opChangeQuantity;

  /// No description provided for @opCreateBox.
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get opCreateBox;

  /// No description provided for @opUpdateBox.
  ///
  /// In en, this message translates to:
  /// **'Edit location'**
  String get opUpdateBox;

  /// No description provided for @opMoveBox.
  ///
  /// In en, this message translates to:
  /// **'Move location'**
  String get opMoveBox;

  /// No description provided for @opDeleteBox.
  ///
  /// In en, this message translates to:
  /// **'Delete location'**
  String get opDeleteBox;

  /// No description provided for @opLend.
  ///
  /// In en, this message translates to:
  /// **'Lend item'**
  String get opLend;

  /// No description provided for @opReturnLoan.
  ///
  /// In en, this message translates to:
  /// **'Return item'**
  String get opReturnLoan;

  /// No description provided for @opCreateCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get opCreateCategory;

  /// No description provided for @opDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get opDeleteCategory;

  /// No description provided for @opUpdateSettings.
  ///
  /// In en, this message translates to:
  /// **'Change settings'**
  String get opUpdateSettings;

  /// No description provided for @daysOverdueCount.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}} overdue'**
  String daysOverdueCount(int days);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
