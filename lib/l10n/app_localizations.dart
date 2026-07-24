import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('en')
  ];

  /// Placeholder text for the search field
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مادة...'**
  String get searchHint;

  /// Message shown when search yields no items
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج مطابقة'**
  String get noResultsFound;

  /// Generic error message with the error details
  ///
  /// In ar, this message translates to:
  /// **'خطأ: {error}'**
  String errorMessage(String error);

  /// Label for the add item button
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get addButtonLabel;

  /// Title shown when the items list is empty
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواد بعد'**
  String get emptyStateTitle;

  /// Subtitle prompting the user to add a new item when list is empty
  ///
  /// In ar, this message translates to:
  /// **'اضغط زر اضافة مادة جديدة'**
  String get emptyStateSubtitle;

  /// Title for the share options dialog
  ///
  /// In ar, this message translates to:
  /// **'خيارات المشاركة'**
  String get shareOptionsTitle;

  /// Label for the included statuses section in share dialog
  ///
  /// In ar, this message translates to:
  /// **'الحالات المضمنة:'**
  String get includedStatusesLabel;

  /// Radio option text for including all statuses in share
  ///
  /// In ar, this message translates to:
  /// **'كل الحالات'**
  String get allStatusesOption;

  /// Radio option text for warning and urgent statuses only
  ///
  /// In ar, this message translates to:
  /// **'حالات التنبيه والعاجلة فقط'**
  String get warningAndUrgentOption;

  /// Radio option text for warning status only
  ///
  /// In ar, this message translates to:
  /// **'حالة التنبيه فقط'**
  String get warningOnlyOption;

  /// Radio option text for urgent status only
  ///
  /// In ar, this message translates to:
  /// **'الحالة العاجلة فقط'**
  String get urgentOnlyOption;

  /// Label for the additional options section in share dialog
  ///
  /// In ar, this message translates to:
  /// **'خيارات إضافية:'**
  String get additionalOptionsLabel;

  /// Checkbox label to include remaining days count in share
  ///
  /// In ar, this message translates to:
  /// **'تضمين عدد الأيام المتبقية'**
  String get includeRemainingDays;

  /// Checkbox label to include renewal date in share
  ///
  /// In ar, this message translates to:
  /// **'تضمين تاريخ التجديد'**
  String get includeRenewalDate;

  /// Cancel button label
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancelLabel;

  /// Share button label
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get shareLabel;

  /// Report date line format in shared text
  ///
  /// In ar, this message translates to:
  /// **'📅 تاريخ التقرير: {date}'**
  String reportDateFormat(String date);

  /// Header for the item details section in shared text
  ///
  /// In ar, this message translates to:
  /// **'📋 تفاصيل المواد'**
  String get itemDetailsHeader;

  /// Format for showing remaining days in shared text, including leading space and parentheses
  ///
  /// In ar, this message translates to:
  /// **'   • المتبقي: {days} يوم'**
  String remainingDaysFormat(String days);

  /// Format for showing renewal date in shared text, including leading space and brackets
  ///
  /// In ar, this message translates to:
  /// **'   • تاريخ التجديد: {date}'**
  String renewalDateFormat(String date);

  /// Error message when sharing fails
  ///
  /// In ar, this message translates to:
  /// **'تعذر مشاركة التقرير: {error}'**
  String shareReportError(String error);

  /// Status label for safe items in summary bar
  ///
  /// In ar, this message translates to:
  /// **'آمن'**
  String get statusSafe;

  /// Status label for warning items in summary bar
  ///
  /// In ar, this message translates to:
  /// **'انتبه'**
  String get statusWarning;

  /// Status label for urgent items in summary bar
  ///
  /// In ar, this message translates to:
  /// **'عاجل'**
  String get statusUrgent;

  /// App title shown in the home app bar
  ///
  /// In ar, this message translates to:
  /// **'متابعة طلبات البيت'**
  String get appTitle;

  /// Menu item text for sharing item details
  ///
  /// In ar, this message translates to:
  /// **'مشاركة تفاصيل المواد'**
  String get shareItemDetails;

  /// Title for the shopping list screen app bar
  ///
  /// In ar, this message translates to:
  /// **'قائمة الشراء'**
  String get shoppingListTitle;

  /// Menu item for deleting all shopping list items
  ///
  /// In ar, this message translates to:
  /// **'حذف كل العناصر'**
  String get deleteAllItemsMenu;

  /// Menu item for sharing the shopping list
  ///
  /// In ar, this message translates to:
  /// **'مشاركة القائمة'**
  String get shareListMenu;

  /// Tooltip for the close button in selection mode app bar
  ///
  /// In ar, this message translates to:
  /// **'إلغاء التحديد'**
  String get clearSelectionTooltip;

  /// Count of selected items shown in the selection mode app bar
  ///
  /// In ar, this message translates to:
  /// **'تم تحديد {count} عنصر'**
  String selectedCountFormat(String count);

  /// Tooltip for the delete button in selection mode app bar
  ///
  /// In ar, this message translates to:
  /// **'حذف المحدد'**
  String get deleteSelectedTooltip;

  /// Generic error message shown when an error occurs
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {error}'**
  String errorOccurredFormat(String error);

  /// Error message when deleting a single shopping item fails
  ///
  /// In ar, this message translates to:
  /// **'تعذر حذف \"{itemTitle}\"'**
  String failedToDeleteFormat(String itemTitle);

  /// Success message when a single item is deleted, shown in undo snackbar
  ///
  /// In ar, this message translates to:
  /// **'تم حذف \"{itemTitle}\"'**
  String deletedFormat(String itemTitle);

  /// Label for the undo action button in snackbar
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get undoLabel;

  /// Error message when restoring a deleted single item fails
  ///
  /// In ar, this message translates to:
  /// **'تعذر استعادة \"{itemTitle}\"'**
  String failedToRestoreFormat(String itemTitle);

  /// Title for the bulk delete confirmation dialog
  ///
  /// In ar, this message translates to:
  /// **'حذف العناصر المحددة'**
  String get deleteSelectedTitle;

  /// Confirmation message in the bulk delete dialog
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف ({count}) عنصر؟'**
  String confirmDeleteSelectedFormat(String count);

  /// Label for the delete button in dialogs
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get deleteButtonLabel;

  /// Error message when bulk delete fails
  ///
  /// In ar, this message translates to:
  /// **'تعذر حذف العناصر المحددة'**
  String get failedToDeleteSelected;

  /// Success message when bulk delete succeeds, shown in undo snackbar
  ///
  /// In ar, this message translates to:
  /// **'تم حذف ({count}) عنصر'**
  String deletedSelectedFormat(String count);

  /// Error message when restoring bulk deleted items fails
  ///
  /// In ar, this message translates to:
  /// **'تعذر استعادة العناصر'**
  String get failedToRestoreItems;

  /// Title for the delete all confirmation dialog
  ///
  /// In ar, this message translates to:
  /// **'حذف جميع العناصر'**
  String get deleteAllTitle;

  /// Confirmation message in the delete all dialog
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف كل عناصر قائمة الشراء؟ لا يمكن التراجع.'**
  String get confirmDeleteAllMessage;

  /// Label for the delete all button
  ///
  /// In ar, this message translates to:
  /// **'حذف الكل'**
  String get deleteAllButton;

  /// Success message after deleting all items
  ///
  /// In ar, this message translates to:
  /// **'تم حذف جميع عناصر قائمة الشراء'**
  String get deletedAllItems;

  /// Error message when deleting all items fails
  ///
  /// In ar, this message translates to:
  /// **'تعذر حذف جميع عناصر قائمة الشراء'**
  String get failedToDeleteAllItems;

  /// Message shown when attempting to share an empty list
  ///
  /// In ar, this message translates to:
  /// **'القائمة فارغة'**
  String get listIsEmpty;

  /// Checkbox label to include price in share
  ///
  /// In ar, this message translates to:
  /// **'تضمين السعر'**
  String get includePrice;

  /// Checkbox label to include purchase status in share
  ///
  /// In ar, this message translates to:
  /// **'تضمين حالة الشراء'**
  String get includePurchaseStatus;

  /// Header for the shared shopping list text
  ///
  /// In ar, this message translates to:
  /// **'🛒 قائمة الشراء'**
  String get shareListHeader;

  /// Format for item price in shared text, including leading space
  ///
  /// In ar, this message translates to:
  /// **'   • السعر: {price}'**
  String priceFormat(String price);

  /// Completed status indicator in shared text, including leading space and brackets
  ///
  /// In ar, this message translates to:
  /// **'   • مكتمل ✅'**
  String get completedFormat;

  /// Not completed status indicator in shared text, including leading space and brackets
  ///
  /// In ar, this message translates to:
  /// **'   • غير مكتمل ❌'**
  String get notCompletedFormat;

  /// Error message when sharing the shopping list fails
  ///
  /// In ar, this message translates to:
  /// **'تعذر مشاركة القائمة: {error}'**
  String failedToShareList(String error);

  /// Label for the total amount in shopping list summary bar
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get totalLabel;

  /// Title shown when the shopping list is empty
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناصر في قائمة الشراء'**
  String get shoppingEmptyStateTitle;

  /// Subtitle shown when the shopping list is empty
  ///
  /// In ar, this message translates to:
  /// **'اضغط على زر الإضافة لبدء التسوق'**
  String get shoppingEmptyStateSubtitle;

  /// Label for the add item button in empty state
  ///
  /// In ar, this message translates to:
  /// **'إضافة عنصر'**
  String get addItemButton;

  /// App bar title when adding a new item in manual mode
  ///
  /// In ar, this message translates to:
  /// **'إضافة عنصر جديد'**
  String get addNewItemTitle;

  /// App bar title when adding an item to the shopping list, also used as tooltip for the add button
  ///
  /// In ar, this message translates to:
  /// **'إضافة إلى قائمة الشراء'**
  String get addToShoppingListTitle;

  /// Error message when adding an item to the shopping list fails
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء الإضافة، حاول مرة أخرى'**
  String get addErrorRetry;

  /// Validation message when the item already exists in the shopping list
  ///
  /// In ar, this message translates to:
  /// **'هذا العنصر موجود بالفعل في قائمة الشراء.'**
  String get itemExistsInShoppingList;

  /// Validation message when the item exists in the inventory but not in the shopping list
  ///
  /// In ar, this message translates to:
  /// **'هذا العنصر مُتابع في التطبيق. يُرجى إضافته من شاشة البحث السابقة.'**
  String get itemTrackedInApp;

  /// Validation error for invalid price format
  ///
  /// In ar, this message translates to:
  /// **'صيغة السعر غير صحيحة'**
  String get invalidPriceFormatMessage;

  /// Validation error when price is negative
  ///
  /// In ar, this message translates to:
  /// **'السعر لا يمكن أن يكون سالبًا'**
  String get priceCannotBeNegative;

  /// Failure message when item could not be added
  ///
  /// In ar, this message translates to:
  /// **'لم تتم إضافة العنصر، حاول مرة أخرى'**
  String get itemNotAddedRetry;

  /// Placeholder text for the shopping list search field
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم عنصر...'**
  String get shoppingSearchHint;

  /// Tooltip for the clear search button
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get clearSearchTooltip;

  /// Hint shown when search field is empty
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بكتابة اسم العنصر للإضافة'**
  String get startTypingHint;

  /// Section header for search results
  ///
  /// In ar, this message translates to:
  /// **'نتائج البحث'**
  String get searchResultsSection;

  /// Label for the quick add tile showing the current search query
  ///
  /// In ar, this message translates to:
  /// **'إضافة \"{query}\" كعنصر جديد'**
  String addAsNewItemFormat(String query);

  /// Subtitle shown when an item is already in the shopping list
  ///
  /// In ar, this message translates to:
  /// **'موجود في قائمة الشراء'**
  String get alreadyInShoppingList;

  /// Hint text for the item name field
  ///
  /// In ar, this message translates to:
  /// **'مثال: حليب، بيض، أرز…'**
  String get itemNameHint;

  /// Label for the item name text field
  ///
  /// In ar, this message translates to:
  /// **'اسم العنصر'**
  String get itemNameLabel;

  /// Label for the price text field
  ///
  /// In ar, this message translates to:
  /// **'السعر (اختياري)'**
  String get priceLabel;

  /// Hint text for the price field
  ///
  /// In ar, this message translates to:
  /// **'0.00'**
  String get priceHint;

  /// Button label shown while submitting the form
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الإضافة…'**
  String get addingLabel;

  /// Label for the add to list submit button
  ///
  /// In ar, this message translates to:
  /// **'إضافة للقائمة'**
  String get addToListButton;

  /// App bar title when editing an existing item
  ///
  /// In ar, this message translates to:
  /// **'تعديل المادة'**
  String get editItemTitle;

  /// App bar title when adding a new item
  ///
  /// In ar, this message translates to:
  /// **'إضافة مادة جديدة'**
  String get addItemScreenTitle;

  /// Tooltip for the back button
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get backTooltip;

  /// Tooltip for the delete button
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get deleteTooltip;

  /// Section title for notifications settings
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsSectionTitle;

  /// Title for the enable notifications switch
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الإشعارات'**
  String get enableNotificationsTitle;

  /// Subtitle when notifications are enabled
  ///
  /// In ar, this message translates to:
  /// **'ستصلك إشعارات عند الاقتراب من النفاد'**
  String get notificationsEnabledSubtitle;

  /// Subtitle when notifications are disabled
  ///
  /// In ar, this message translates to:
  /// **'لن تصلك أي إشعارات لهذه المادة'**
  String get notificationsDisabledSubtitle;

  /// Section title for the delete item option
  ///
  /// In ar, this message translates to:
  /// **'حذف المادة'**
  String get deleteItemSectionTitle;

  /// Title for the delete item confirmation dialog
  ///
  /// In ar, this message translates to:
  /// **'حذف المادة'**
  String get deleteItemTitle;

  /// Section title for alert thresholds
  ///
  /// In ar, this message translates to:
  /// **'حدود التنبيه'**
  String get thresholdsSectionTitle;

  /// Description text for thresholds section
  ///
  /// In ar, this message translates to:
  /// **'يحدد التطبيق حالة كل مادة بناءً على هذه الحدود'**
  String get thresholdsDescription;

  /// Label for the warning threshold field
  ///
  /// In ar, this message translates to:
  /// **'🟡 حد الانتباه'**
  String get warningThresholdLabel;

  /// Label for the urgent threshold field
  ///
  /// In ar, this message translates to:
  /// **'🔴 الحد العاجل'**
  String get urgentThresholdLabel;

  /// Section title for item information
  ///
  /// In ar, this message translates to:
  /// **'معلومات المادة'**
  String get itemInfoSectionTitle;

  /// Label for the item name field
  ///
  /// In ar, this message translates to:
  /// **'اسم المادة'**
  String get itemNameFieldLabel;

  /// Hint text for the item name field in add/edit screen
  ///
  /// In ar, this message translates to:
  /// **'مثال: سكر، دقيق، زيت'**
  String get itemNameFieldHint;

  /// Label for the quantity description field
  ///
  /// In ar, this message translates to:
  /// **'وصف الكمية (اختياري)'**
  String get quantityDescriptionLabel;

  /// Hint text for the quantity description field
  ///
  /// In ar, this message translates to:
  /// **'مثال: كيس 5 كيلو، عبوتان'**
  String get quantityDescriptionHint;

  /// Label for the expected days field
  ///
  /// In ar, this message translates to:
  /// **'عدد الأيام المتوقعة للنفاد'**
  String get expectedDaysLabel;

  /// Hint text for the expected days field
  ///
  /// In ar, this message translates to:
  /// **'مثال: 30'**
  String get expectedDaysHint;

  /// Suffix for days field
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get daysSuffix;

  /// Label for the notes field
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات (اختياري)'**
  String get notesLabel;

  /// Button label when saving changes in edit mode
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get saveChangesButton;

  /// Button label when adding a new item
  ///
  /// In ar, this message translates to:
  /// **'إضافة المادة'**
  String get addItemSubmitButton;

  /// Validation error when name is empty
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب'**
  String get nameRequiredError;

  /// Validation error when days field is empty
  ///
  /// In ar, this message translates to:
  /// **'أدخل عدد الأيام'**
  String get enterDaysError;

  /// Validation error when days is not a valid number
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقمًا صحيحًا'**
  String get enterValidNumberError;

  /// Error message for duplicate item name
  ///
  /// In ar, this message translates to:
  /// **'الاسم موجود مسبقاً'**
  String get duplicateNameError;

  /// Error message for invalid days input
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال عدد أيام صحيح'**
  String get invalidDaysError;

  /// Error message when thresholds are not in correct order
  ///
  /// In ar, this message translates to:
  /// **'أيام الانتباه يجب أن تكون أكبر من العاجل'**
  String get thresholdOrderError;

  /// Error message when threshold is negative
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن أن تكون الحدود قيمًا سالبة'**
  String get negativeThresholdError;

  /// Error message displayed when the user tries to submit without selecting a refresh date.
  ///
  /// In ar, this message translates to:
  /// **'يرجى ادخال تاريخ التجديد'**
  String get refreshDateRequiredError;

  /// Generic error message when saving fails
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء حفظ العنصر، حاول مرة أخرى'**
  String get genericSaveError;

  /// Help text for the date picker
  ///
  /// In ar, this message translates to:
  /// **'اختر تاريخ التجديد'**
  String get datePickerHelpText;

  /// Cancel text for the date picker
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get datePickerCancelText;

  /// Confirm text for the date picker
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get datePickerConfirmText;

  /// Error message when date picker fails to open
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح منتقي التاريخ، يرجى المحاولة مرة أخرى'**
  String get datePickerError;

  /// Title for the reset date dialog
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين تاريخ التجديد'**
  String get resetDateDialogTitle;

  /// Content for the reset date dialog
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تعيين تاريخ التجديد إلى تاريخ اليوم؟'**
  String get resetDateDialogContent;

  /// Cancel label for the reset date dialog
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get resetDateCancelLabel;

  /// Confirm label for the reset date dialog
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get resetDateConfirmLabel;

  /// Title for the discard changes dialog
  ///
  /// In ar, this message translates to:
  /// **'تجاهل التغييرات؟'**
  String get discardDialogTitle;

  /// Content for the discard changes dialog
  ///
  /// In ar, this message translates to:
  /// **'لديك تغييرات غير محفوظة. هل تريد الخروج دون حفظ؟'**
  String get discardDialogContent;

  /// Cancel label for the discard dialog
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get discardCancelLabel;

  /// Label for the discard action button
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get discardLabel;

  /// Title for the delete item dialog
  ///
  /// In ar, this message translates to:
  /// **'حذف المادة'**
  String get deleteItemDialogTitle;

  /// Content for the delete item dialog with item name placeholder
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف \"{itemName}\"؟ سيتم حذفها أيضًا من قائمة الشراء إن كانت مضافة هناك. لا يمكن التراجع عن هذا الإجراء.'**
  String deleteItemDialogContentFormat(String itemName);

  /// Cancel label for the delete item dialog
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get deleteItemCancelLabel;

  /// Delete button label for the delete item dialog
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get deleteItemButtonLabel;

  /// Error message when deleting an item fails
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حذف المادة، يرجى المحاولة مرة أخرى'**
  String get deleteItemError;

  /// Suffix for threshold days in accessibility label
  ///
  /// In ar, this message translates to:
  /// **'بالأيام'**
  String get thresholdDaysSuffix;

  /// Suffix text for threshold field
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get thresholdFieldSuffix;

  /// Label for the refresh date field
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التجديد'**
  String get refreshDateLabel;

  /// Hint text for the refresh date field
  ///
  /// In ar, this message translates to:
  /// **'YYYY-MM-DD'**
  String get refreshDateHint;

  /// Tooltip for the pick refresh date button
  ///
  /// In ar, this message translates to:
  /// **'اختيار تاريخ التجديد'**
  String get pickRefreshDateTooltip;

  /// Label for the reset to today button
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين إلى تاريخ اليوم'**
  String get resetToTodayButton;

  /// App bar title for the expiry screen
  ///
  /// In ar, this message translates to:
  /// **'عناصر على وشك النفاد'**
  String get expiryScreenTitle;

  /// Menu item for adding all items to shopping list
  ///
  /// In ar, this message translates to:
  /// **'إضافة كل المواد إلى قائمة الشراء'**
  String get addAllToShoppingListMenu;

  /// Message when all items are already in shopping list
  ///
  /// In ar, this message translates to:
  /// **'جميع العناصر موجودة بالفعل في قائمة الشراء'**
  String get allItemsAlreadyInShoppingList;

  /// Success message when all items added to shopping list
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة جميع العناصر الى قائمة الشراء.'**
  String get allItemsAddedToShoppingList;

  /// Error message when adding all items to shopping list fails
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء إضافة العناصر إلى قائمة الشراء: {error}'**
  String failedToAddAllItemsFormat(String error);

  /// Success message when single item added to shopping list
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة \"{itemName}\" إلى قائمة الشراء'**
  String itemAddedToShoppingListFormat(String itemName);

  /// Message when item already exists in shopping list
  ///
  /// In ar, this message translates to:
  /// **'\"{itemName}\" موجود بالفعل في قائمة الشراء'**
  String itemAlreadyInShoppingListFormat(String itemName);

  /// Error message when adding single item fails
  ///
  /// In ar, this message translates to:
  /// **'فشل إضافة العنصر: {error}'**
  String failedToAddItemFormat(String error);

  /// Notice text explaining which items are displayed
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة: تُعرض فقط المواد ذات الحالة (انتباه) أو (عاجل). المواد الآمنة لا تظهر هنا.'**
  String get expiryNoticeText;

  /// Chip label showing item is already in shopping list
  ///
  /// In ar, this message translates to:
  /// **'في القائمة'**
  String get inShoppingListChipLabel;

  /// Label when item expires today
  ///
  /// In ar, this message translates to:
  /// **'ينفد اليوم'**
  String get expiresToday;

  /// Format for item expiring in future with relative date
  ///
  /// In ar, this message translates to:
  /// **'ينفد {date}'**
  String expiresInFormat(String date);

  /// Format for expired item with relative date
  ///
  /// In ar, this message translates to:
  /// **'نفد {date}'**
  String expiredFormat(String date);

  /// Title for empty state in expiry screen
  ///
  /// In ar, this message translates to:
  /// **'ممتاز! مخزونك في حالة آمنة'**
  String get expiryEmptyStateTitle;

  /// Subtitle for empty state in expiry screen
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناصر تحتاج إلى انتباه حالياً'**
  String get expiryEmptyStateSubtitle;

  /// Label for expired expiry bucket
  ///
  /// In ar, this message translates to:
  /// **'❌ نفدت'**
  String get expiryBucketExpiredLabel;

  /// Label for three days expiry bucket
  ///
  /// In ar, this message translates to:
  /// **'ينتهي خلال 3 أيام'**
  String get expiryBucketThreeDaysLabel;

  /// Label for one week expiry bucket
  ///
  /// In ar, this message translates to:
  /// **'ينتهي خلال أسبوع'**
  String get expiryBucketWeekLabel;

  /// Label for two weeks expiry bucket
  ///
  /// In ar, this message translates to:
  /// **'ينتهي خلال أسبوعين'**
  String get expiryBucketTwoWeeksLabel;

  /// Label for one month expiry bucket
  ///
  /// In ar, this message translates to:
  /// **'ينتهي خلال شهر'**
  String get expiryBucketMonthLabel;

  /// Label for more than a month expiry bucket
  ///
  /// In ar, this message translates to:
  /// **'ينتهي بعد أكثر من شهر'**
  String get expiryBucketMoreThanMonthLabel;

  /// Bottom navigation label for home tab
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get mainNavHomeLabel;

  /// Tooltip for home tab
  ///
  /// In ar, this message translates to:
  /// **'الشاشة الرئيسية'**
  String get mainNavHomeTooltip;

  /// Bottom navigation label for expiry tab
  ///
  /// In ar, this message translates to:
  /// **'النفاد'**
  String get mainNavExpiryLabel;

  /// Tooltip for expiry tab
  ///
  /// In ar, this message translates to:
  /// **'العناصر القريبة من النفاد'**
  String get mainNavExpiryTooltip;

  /// Bottom navigation label for shopping tab
  ///
  /// In ar, this message translates to:
  /// **'الشراء'**
  String get mainNavShoppingLabel;

  /// Tooltip for shopping tab
  ///
  /// In ar, this message translates to:
  /// **'قائمة التسوق'**
  String get mainNavShoppingTooltip;

  /// Dialog title when editing price with item name
  ///
  /// In ar, this message translates to:
  /// **'السعر لـ \"{itemName}\"'**
  String editPriceDialogTitleWithItem(String itemName);

  /// Dialog title when editing price without item name
  ///
  /// In ar, this message translates to:
  /// **'تعديل السعر'**
  String get editPriceDialogTitle;

  /// Label for price field in edit price dialog
  ///
  /// In ar, this message translates to:
  /// **'السعر (اختياري)'**
  String get priceFieldLabel;

  /// Hint text for price field
  ///
  /// In ar, this message translates to:
  /// **'0.00'**
  String get priceFieldHint;

  /// Validation error for invalid price format in edit price dialog
  ///
  /// In ar, this message translates to:
  /// **'صيغة السعر غير صحيحة'**
  String get invalidPriceFormat;

  /// Validation error for negative price in edit price dialog
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن أن يكون السعر سالباً'**
  String get priceCannotBeNegativeDialog;

  /// Cancel button in dialogs
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get dialogCancel;

  /// Save button in dialogs
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get dialogSave;

  /// Subtitle for shopping items linked to inventory
  ///
  /// In ar, this message translates to:
  /// **'مُتابع في التطبيق'**
  String get shoppingItemTrackedInApp;

  /// Subtitle for manually added shopping items
  ///
  /// In ar, this message translates to:
  /// **'عنصر مُضاف يدوياً'**
  String get shoppingItemManualEntry;

  /// Text showing when item was last refreshed
  ///
  /// In ar, this message translates to:
  /// **'تم التجديد {relativeDate}'**
  String itemCardRefreshedText(String relativeDate);

  /// Actually used for quantity description, but keeping key name for consistency
  ///
  /// In ar, this message translates to:
  /// **'تم التجديد {relativeDate}'**
  String itemCardQuantityDescription(String relativeDate);

  /// Format for remaining days when positive
  ///
  /// In ar, this message translates to:
  /// **'يكفي {days} يوم'**
  String itemRemainingDaysPositiveFormat(String days);

  /// Text when item expires today
  ///
  /// In ar, this message translates to:
  /// **'ينتهي اليوم'**
  String get itemRemainingDaysZero;

  /// Format for expired items with days since expiry
  ///
  /// In ar, this message translates to:
  /// **'انتهى منذ {days} يوم'**
  String itemRemainingDaysNegativeFormat(String days);

  /// Label for expected expiry section in item card
  ///
  /// In ar, this message translates to:
  /// **'النفاد المتوقع'**
  String get expectedExpiryLabel;

  /// Text when notifications are disabled
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات متوقفة'**
  String get notificationsStopped;

  /// Text showing when notification will start
  ///
  /// In ar, this message translates to:
  /// **'سيبدأ التنبيه بعد {days} يوم'**
  String notificationStartsInFormat(String days);

  /// Text when notification is currently active
  ///
  /// In ar, this message translates to:
  /// **'التنبيه نشط الآن'**
  String get notificationActiveNow;

  /// Title for unknown route error screen
  ///
  /// In ar, this message translates to:
  /// **'الصفحة غير موجودة'**
  String get errorUnknownRouteTitle;

  /// Message for unknown route error screen
  ///
  /// In ar, this message translates to:
  /// **'الرابط الذي حاولت فتحه غير صحيح أو لم يعد متوفرًا.'**
  String get errorUnknownRouteMessage;

  /// Title for item not found error screen
  ///
  /// In ar, this message translates to:
  /// **'العنصر غير موجود'**
  String get errorItemNotFoundTitle;

  /// Message for item not found error screen
  ///
  /// In ar, this message translates to:
  /// **'لم نعثر على هذا العنصر، قد يكون تم حذفه مسبقًا.'**
  String get errorItemNotFoundMessage;

  /// Title shown when fetching an item from the source fails
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل العنصر'**
  String get errorItemLoadFailedTitle;

  /// Message shown when fetching an item from the source fails
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء جلب بيانات العنصر، يرجى المحاولة مرة أخرى.'**
  String get errorItemLoadFailedMessage;

  /// Title shown when an unexpected error occurs while loading an item screen
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل العنصر'**
  String get errorItemLoadUnexpectedTitle;

  /// Message shown when an unexpected error occurs while loading an item screen
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع أثناء تحميل هذه الشاشة.'**
  String get errorItemLoadUnexpectedMessage;

  /// Retry button label on error screens
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى الرئيسية'**
  String get errorRetryLabel;

  /// Title for battery optimization dialog
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الاشعارات في الخلفية'**
  String get batteryDialogTitle;

  /// Content for battery optimization dialog
  ///
  /// In ar, this message translates to:
  /// **'قد تؤخر إعدادات توفير البطارية التنبيهات.\n\nلضمان وصولها في الوقت المناسب، يُفضل استثناء التطبيق من قيود البطارية.'**
  String get batteryDialogContent;

  /// Not now button in battery dialog
  ///
  /// In ar, this message translates to:
  /// **'ليس الآن'**
  String get batteryDialogNotNow;

  /// Open settings button in battery dialog
  ///
  /// In ar, this message translates to:
  /// **'فتح الإعدادات'**
  String get batteryDialogOpenSettings;

  /// Error snackbar when battery settings can't be opened
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح الإعدادات تلقائيًا. لضمان ظهور الاشعارات التذكيرية يرجى الذهاب إلى الإعدادات > التطبيقات > تطبيقنا > البطارية > السماح بالتشغيل في الخلفية'**
  String get batterySnackBarError;

  /// Retry button in battery error snackbar to try opening settings again
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get batterySnackBarRetry;

  /// Notification channel name
  ///
  /// In ar, this message translates to:
  /// **'الملخص اليومي'**
  String get notificationChannelName;

  /// Notification channel description
  ///
  /// In ar, this message translates to:
  /// **'إشعار يومي يوضح العناصر التي تحتاج انتباه'**
  String get notificationChannelDescription;

  /// Title for daily summary notification
  ///
  /// In ar, this message translates to:
  /// **'ملخص طلبات البيت'**
  String get notificationTitle;

  /// Prefix for urgent items in notification
  ///
  /// In ar, this message translates to:
  /// **'🔴 عاجل: '**
  String get notificationUrgentPrefix;

  /// Prefix for warning items in notification
  ///
  /// In ar, this message translates to:
  /// **'🟡 انتبه: '**
  String get notificationWarningPrefix;

  /// Settings menu item and screen title
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// Arabic language name
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// English language name
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// Language selection label
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// Language selection prompt
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get selectLanguage;

  /// Backup & Restore section title
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي والاستعادة'**
  String get backupAndRestore;

  /// Label for creating a backup
  ///
  /// In ar, this message translates to:
  /// **'إنشاء نسخة احتياطية'**
  String get createBackup;

  /// Label for restoring a backup
  ///
  /// In ar, this message translates to:
  /// **'استعادة نسخة احتياطية'**
  String get restoreBackup;

  /// Success message for backup creation
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء النسخة الاحتياطية بنجاح'**
  String get backupSuccess;

  /// Error message when backup creation fails
  ///
  /// In ar, this message translates to:
  /// **'فشل إنشاء النسخة الاحتياطية'**
  String get backupFailed;

  /// Success message for backup restore
  ///
  /// In ar, this message translates to:
  /// **'تم استعادة النسخة الاحتياطية بنجاح'**
  String get restoreSuccess;

  /// Error message when backup restore fails
  ///
  /// In ar, this message translates to:
  /// **'فشل استعادة النسخة الاحتياطية'**
  String get restoreFailed;

  /// Error when database file not found
  ///
  /// In ar, this message translates to:
  /// **'ملف قاعدة البيانات غير موجود'**
  String get backupFileNotFound;

  /// Message when user cancels restore operation
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء العملية'**
  String get operationCancelled;

  /// Processing indicator text
  ///
  /// In ar, this message translates to:
  /// **'جاري المعالجة...'**
  String get processing;

  /// File filter label for .db files
  ///
  /// In ar, this message translates to:
  /// **'ملفات قاعدة البيانات (*.db)'**
  String get backupFileExtension;

  /// Subtitle for the create backup action
  ///
  /// In ar, this message translates to:
  /// **'إنشاء نسخة احتياطية من قاعدة البيانات'**
  String get createBackupSubtitle;

  /// Subtitle for the restore backup action
  ///
  /// In ar, this message translates to:
  /// **'استعادة البيانات من ملف نسخة احتياطية'**
  String get restoreBackupSubtitle;

  /// Message shown while settings are loading
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحميل الإعدادات...'**
  String get loadingSettingsMessage;

  /// Message shown when settings fail to load
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تحميل الإعدادات'**
  String get errorLoadingSettingsMessage;

  /// Error when the selected backup file is invalid or corrupted
  ///
  /// In ar, this message translates to:
  /// **'ملف النسخة الاحتياطية غير صالح'**
  String get restoreInvalidFile;

  /// Error when the selected restore file is not found
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على ملف النسخة الاحتياطية'**
  String get restoreFileNotFound;

  /// Generic unknown error message
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير معروف'**
  String get unknownError;

  /// Dialog title when restoring backup
  ///
  /// In ar, this message translates to:
  /// **'تأكيد استعادة النسخة الاحتياطية'**
  String get restoreConfirmationTitle;

  /// Dialog content explaining that current data will be replaced and the app will restart after a successful restore
  ///
  /// In ar, this message translates to:
  /// **'سيتم استبدال جميع البيانات الحالية بالبيانات الموجودة في النسخة الاحتياطية.\n\nبعد نجاح الاستعادة، سيتم إعادة تشغيل التطبيق لتحديث البيانات.\n\nهل تريد المتابعة؟'**
  String get restoreConfirmationContent;

  /// Button label to confirm restore
  ///
  /// In ar, this message translates to:
  /// **'استعادة'**
  String get restoreConfirmLabel;

  /// Text displayed while loading
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get loading;

  /// Title for first onboarding page
  ///
  /// In ar, this message translates to:
  /// **'بيت منظم، وراحة بال'**
  String get onboardingTitle1;

  /// Body text for first onboarding page
  ///
  /// In ar, this message translates to:
  /// **'انقل عناء التفكير بمتطلبات البيت بالكامل إلى تطبيقك. تتبع النواقص بذكاء ووفر طاقتك الذهنية لما هو أهم.'**
  String get onboardingBody1;

  /// Title for second onboarding page
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات في وقتها، بلا مفاجآت'**
  String get onboardingTitle2;

  /// Body text for second onboarding page
  ///
  /// In ar, this message translates to:
  /// **'تصلك تنبيهات عند اقتراب النواقص من النفاد، لتبقى مستعداً دائماً وتتجنب النقص المفاجئ.'**
  String get onboardingBody2;

  /// Title for third onboarding page
  ///
  /// In ar, this message translates to:
  /// **'تسوق سهل'**
  String get onboardingTitle3;

  /// Body text for third onboarding page
  ///
  /// In ar, this message translates to:
  /// **'بنقرة زر، حوّل نواقصك إلى قائمة تسوق منظمة بدقة، وشاركها بسهولة عبر واتساب.'**
  String get onboardingBody3;

  /// Title for fourth onboarding page
  ///
  /// In ar, this message translates to:
  /// **'بياناتك في أمان'**
  String get onboardingTitle4;

  /// Body text for fourth onboarding page
  ///
  /// In ar, this message translates to:
  /// **'بلا إنترنت. بلا حسابات. بياناتك ملكك وحدك وعلى جهازك، مع إمكانية النسخ الاحتياطي المحلي متى أردت.'**
  String get onboardingBody4;

  /// Skip button text on onboarding
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get onboardingSkip;

  /// Next button text on onboarding
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get onboardingNext;

  /// Done button text on onboarding
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get onboardingDone;

  /// Title for language selection screen
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get languageSelectionTitle;

  /// Subtitle for language selection screen
  ///
  /// In ar, this message translates to:
  /// **'اختر لغتك المفضلة'**
  String get languageSelectionSubtitle;

  /// Error message when changing language fails
  ///
  /// In ar, this message translates to:
  /// **'فشل تغيير اللغة. حاول مجدداً'**
  String get languageChangeFailed;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
