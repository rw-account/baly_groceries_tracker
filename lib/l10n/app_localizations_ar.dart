// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get searchHint => 'ابحث عن مادة...';

  @override
  String get noResultsFound => 'لا توجد نتائج مطابقة';

  @override
  String errorMessage(String error) {
    return 'خطأ: $error';
  }

  @override
  String get addButtonLabel => 'إضافة';

  @override
  String get emptyStateTitle => 'لا توجد مواد بعد';

  @override
  String get emptyStateSubtitle => 'اضغط زر اضافة مادة جديدة';

  @override
  String get shareOptionsTitle => 'خيارات المشاركة';

  @override
  String get includedStatusesLabel => 'الحالات المضمنة:';

  @override
  String get allStatusesOption => 'كل الحالات';

  @override
  String get warningAndUrgentOption => 'حالات التنبيه والعاجلة فقط';

  @override
  String get warningOnlyOption => 'حالة التنبيه فقط';

  @override
  String get urgentOnlyOption => 'الحالة العاجلة فقط';

  @override
  String get additionalOptionsLabel => 'خيارات إضافية:';

  @override
  String get includeRemainingDays => 'تضمين عدد الأيام المتبقية';

  @override
  String get includeRenewalDate => 'تضمين تاريخ التجديد';

  @override
  String get cancelLabel => 'إلغاء';

  @override
  String get shareLabel => 'مشاركة';

  @override
  String reportDateFormat(String date) {
    return '📅 تاريخ التقرير: $date';
  }

  @override
  String get itemDetailsHeader => '📋 تفاصيل المواد';

  @override
  String remainingDaysFormat(String days) {
    return '   • المتبقي: $days يوم';
  }

  @override
  String renewalDateFormat(String date) {
    return '   • تاريخ التجديد: $date';
  }

  @override
  String shareReportError(String error) {
    return 'تعذر مشاركة التقرير: $error';
  }

  @override
  String get statusSafe => 'آمن';

  @override
  String get statusWarning => 'انتبه';

  @override
  String get statusUrgent => 'عاجل';

  @override
  String get appTitle => 'متابعة طلبات البيت';

  @override
  String get aboutLabel => 'عن التطبيق';

  @override
  String get shareItemDetails => 'مشاركة تفاصيل المواد';

  @override
  String get aboutDialogDescription =>
      'هذا التطبيق مجاني ومفتوح المصدر. يمكنك زيارة صفحة المشروع الرسمية على GitHub:';

  @override
  String get githubLinkOpenFailed => 'تعذر فتح الرابط، تأكد من وجود متصفح مثبت';

  @override
  String get githubLinkOpenError => 'حدث خطأ أثناء فتح الرابط';

  @override
  String get closeLabel => 'إغلاق';

  @override
  String get showLicensesLabel => 'عرض التراخيص';

  @override
  String get shoppingListTitle => 'قائمة الشراء';

  @override
  String get deleteAllItemsMenu => 'حذف كل العناصر';

  @override
  String get shareListMenu => 'مشاركة القائمة';

  @override
  String get clearSelectionTooltip => 'إلغاء التحديد';

  @override
  String selectedCountFormat(String count) {
    return 'تم تحديد $count عنصر';
  }

  @override
  String get deleteSelectedTooltip => 'حذف المحدد';

  @override
  String errorOccurredFormat(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String failedToDeleteFormat(String itemTitle) {
    return 'تعذر حذف \"$itemTitle\"';
  }

  @override
  String deletedFormat(String itemTitle) {
    return 'تم حذف \"$itemTitle\"';
  }

  @override
  String get undoLabel => 'تراجع';

  @override
  String failedToRestoreFormat(String itemTitle) {
    return 'تعذر استعادة \"$itemTitle\"';
  }

  @override
  String get deleteSelectedTitle => 'حذف العناصر المحددة';

  @override
  String confirmDeleteSelectedFormat(String count) {
    return 'هل تريد حذف ($count) عنصر؟';
  }

  @override
  String get deleteButtonLabel => 'حذف';

  @override
  String get failedToDeleteSelected => 'تعذر حذف العناصر المحددة';

  @override
  String deletedSelectedFormat(String count) {
    return 'تم حذف ($count) عنصر';
  }

  @override
  String get failedToRestoreItems => 'تعذر استعادة العناصر';

  @override
  String get deleteAllTitle => 'حذف جميع العناصر';

  @override
  String get confirmDeleteAllMessage =>
      'هل أنت متأكد من حذف كل عناصر قائمة الشراء؟ لا يمكن التراجع.';

  @override
  String get deleteAllButton => 'حذف الكل';

  @override
  String get deletedAllItems => 'تم حذف جميع عناصر قائمة الشراء';

  @override
  String get failedToDeleteAllItems => 'تعذر حذف جميع عناصر قائمة الشراء';

  @override
  String get listIsEmpty => 'القائمة فارغة';

  @override
  String get includePrice => 'تضمين السعر';

  @override
  String get includePurchaseStatus => 'تضمين حالة الشراء';

  @override
  String get shareListHeader => '🛒 قائمة الشراء';

  @override
  String priceFormat(String price) {
    return '   • السعر: $price';
  }

  @override
  String get completedFormat => '   • مكتمل ✅';

  @override
  String get notCompletedFormat => '   • غير مكتمل ❌';

  @override
  String failedToShareList(String error) {
    return 'تعذر مشاركة القائمة: $error';
  }

  @override
  String get totalLabel => 'الإجمالي';

  @override
  String get shoppingEmptyStateTitle => 'لا توجد عناصر في قائمة الشراء';

  @override
  String get shoppingEmptyStateSubtitle => 'اضغط على زر الإضافة لبدء التسوق';

  @override
  String get addItemButton => 'إضافة عنصر';

  @override
  String get addNewItemTitle => 'إضافة عنصر جديد';

  @override
  String get addToShoppingListTitle => 'إضافة إلى قائمة الشراء';

  @override
  String get addErrorRetry => 'حدث خطأ أثناء الإضافة، حاول مرة أخرى';

  @override
  String get itemExistsInShoppingList =>
      'هذا العنصر موجود بالفعل في قائمة الشراء.';

  @override
  String get itemTrackedInApp =>
      'هذا العنصر مُتابع في التطبيق. يُرجى إضافته من شاشة البحث السابقة.';

  @override
  String get invalidPriceFormatMessage => 'صيغة السعر غير صحيحة';

  @override
  String get priceCannotBeNegative => 'السعر لا يمكن أن يكون سالبًا';

  @override
  String get itemNotAddedRetry => 'لم تتم إضافة العنصر، حاول مرة أخرى';

  @override
  String get shoppingSearchHint => 'اكتب اسم عنصر...';

  @override
  String get clearSearchTooltip => 'مسح البحث';

  @override
  String get startTypingHint => 'ابدأ بكتابة اسم العنصر للإضافة';

  @override
  String get searchResultsSection => 'نتائج البحث';

  @override
  String addAsNewItemFormat(String query) {
    return 'إضافة \"$query\" كعنصر جديد';
  }

  @override
  String get alreadyInShoppingList => 'موجود في قائمة الشراء';

  @override
  String get itemNameHint => 'مثال: حليب، بيض، أرز…';

  @override
  String get itemNameLabel => 'اسم العنصر';

  @override
  String get priceLabel => 'السعر (اختياري)';

  @override
  String get priceHint => '0.00';

  @override
  String get addingLabel => 'جارٍ الإضافة…';

  @override
  String get addToListButton => 'إضافة للقائمة';

  @override
  String get editItemTitle => 'تعديل المادة';

  @override
  String get addItemScreenTitle => 'إضافة مادة جديدة';

  @override
  String get backTooltip => 'رجوع';

  @override
  String get deleteTooltip => 'حذف';

  @override
  String get notificationsSectionTitle => 'الإشعارات';

  @override
  String get enableNotificationsTitle => 'تفعيل الإشعارات';

  @override
  String get notificationsEnabledSubtitle =>
      'ستصلك إشعارات عند الاقتراب من النفاد';

  @override
  String get notificationsDisabledSubtitle => 'لن تصلك أي إشعارات لهذه المادة';

  @override
  String get deleteItemSectionTitle => 'حذف المادة';

  @override
  String get deleteItemTitle => 'حذف المادة';

  @override
  String get thresholdsSectionTitle => 'حدود التنبيه';

  @override
  String get thresholdsDescription =>
      'يحدد التطبيق حالة كل مادة بناءً على هذه الحدود';

  @override
  String get warningThresholdLabel => '🟡 حد الانتباه';

  @override
  String get urgentThresholdLabel => '🔴 حد العاجل';

  @override
  String get itemInfoSectionTitle => 'معلومات المادة';

  @override
  String get itemNameFieldLabel => 'اسم المادة';

  @override
  String get itemNameFieldHint => 'مثال: سكر، دقيق، زيت';

  @override
  String get quantityDescriptionLabel => 'وصف الكمية (اختياري)';

  @override
  String get quantityDescriptionHint => 'مثال: كيس 5 كيلو، عبوتان';

  @override
  String get expectedDaysLabel => 'عدد الأيام المتوقعة للنفاد';

  @override
  String get expectedDaysHint => 'مثال: 30';

  @override
  String get daysSuffix => 'يوم';

  @override
  String get notesLabel => 'ملاحظات (اختياري)';

  @override
  String get saveChangesButton => 'حفظ التعديلات';

  @override
  String get addItemSubmitButton => 'إضافة المادة';

  @override
  String get nameRequiredError => 'الاسم مطلوب';

  @override
  String get enterDaysError => 'أدخل عدد الأيام';

  @override
  String get enterValidNumberError => 'أدخل رقمًا صحيحًا';

  @override
  String get duplicateNameError => 'الاسم موجود مسبقاً';

  @override
  String get invalidDaysError => 'يرجى إدخال عدد أيام صحيح';

  @override
  String get thresholdOrderError => 'أيام الانتباه يجب أن تكون أكبر من العاجل';

  @override
  String get negativeThresholdError => 'لا يمكن أن تكون الحدود قيمًا سالبة';

  @override
  String get refreshDateRequiredError => 'يرجى ادخال تاريخ التجديد';

  @override
  String get genericSaveError => 'حدث خطأ أثناء حفظ العنصر، حاول مرة أخرى';

  @override
  String get renewalDatePickerHelpText => 'اختر تاريخ التجديد';

  @override
  String get datePickerCancelText => 'إلغاء';

  @override
  String get datePickerConfirmText => 'تأكيد';

  @override
  String get datePickerError =>
      'تعذّر فتح منتقي التاريخ، يرجى المحاولة مرة أخرى';

  @override
  String get resetDateDialogTitle => 'إعادة تعيين تاريخ التجديد';

  @override
  String get resetDateDialogContent =>
      'هل تريد تعيين تاريخ التجديد إلى تاريخ اليوم؟';

  @override
  String get resetDateCancelLabel => 'إلغاء';

  @override
  String get resetDateConfirmLabel => 'موافق';

  @override
  String get discardDialogTitle => 'تجاهل التغييرات؟';

  @override
  String get discardDialogContent =>
      'لديك تغييرات غير محفوظة. هل تريد الخروج دون حفظ؟';

  @override
  String get discardCancelLabel => 'إلغاء';

  @override
  String get discardLabel => 'تجاهل';

  @override
  String get deleteItemDialogTitle => 'حذف المادة';

  @override
  String deleteItemDialogContentFormat(String itemName) {
    return 'هل أنت متأكد من حذف \"$itemName\"؟ سيتم حذفها أيضًا من قائمة الشراء إن كانت مضافة هناك. لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get deleteItemCancelLabel => 'إلغاء';

  @override
  String get deleteItemButtonLabel => 'حذف';

  @override
  String get deleteItemError => 'تعذّر حذف المادة، يرجى المحاولة مرة أخرى';

  @override
  String get thresholdDaysSuffix => 'بالأيام';

  @override
  String get thresholdFieldSuffix => 'يوم';

  @override
  String get refreshDateLabel => 'تاريخ التجديد';

  @override
  String get refreshDateHint => 'YYYY-MM-DD';

  @override
  String get pickRefreshDateTooltip => 'اختيار تاريخ التجديد';

  @override
  String get resetToTodayButton => 'إعادة تعيين إلى تاريخ اليوم';

  @override
  String get expiryScreenTitle => 'عناصر على وشك النفاد';

  @override
  String get addAllToShoppingListMenu => 'إضافة كل المواد إلى قائمة الشراء';

  @override
  String get allItemsAlreadyInShoppingList =>
      'جميع العناصر موجودة بالفعل في قائمة الشراء';

  @override
  String get allItemsAddedToShoppingList =>
      'تمت إضافة جميع العناصر الى قائمة الشراء.';

  @override
  String failedToAddAllItemsFormat(String error) {
    return 'حدث خطأ أثناء إضافة العناصر إلى قائمة الشراء: $error';
  }

  @override
  String itemAddedToShoppingListFormat(String itemName) {
    return 'تمت إضافة \"$itemName\" إلى قائمة الشراء';
  }

  @override
  String itemAlreadyInShoppingListFormat(String itemName) {
    return '\"$itemName\" موجود بالفعل في قائمة الشراء';
  }

  @override
  String failedToAddItemFormat(String error) {
    return 'فشل إضافة العنصر: $error';
  }

  @override
  String get expiryNoticeText =>
      'ملاحظة: تُعرض فقط المواد ذات الحالة (انتباه) أو (عاجل). المواد الآمنة لا تظهر هنا.';

  @override
  String get inShoppingListChipLabel => 'في القائمة';

  @override
  String get expiresToday => 'ينفد اليوم';

  @override
  String expiresInFormat(String date) {
    return 'ينفد $date';
  }

  @override
  String expiredFormat(String date) {
    return 'نفد $date';
  }

  @override
  String get expiryEmptyStateTitle => 'ممتاز! مخزونك في حالة آمنة';

  @override
  String get expiryEmptyStateSubtitle =>
      'لا توجد عناصر تحتاج إلى انتباه حالياً';

  @override
  String get expiryBucketExpiredLabel => '❌ نفدت';

  @override
  String get expiryBucketThreeDaysLabel => 'ينتهي خلال 3 أيام';

  @override
  String get expiryBucketWeekLabel => 'ينتهي خلال أسبوع';

  @override
  String get expiryBucketTwoWeeksLabel => 'ينتهي خلال أسبوعين';

  @override
  String get expiryBucketMonthLabel => 'ينتهي خلال شهر';

  @override
  String get expiryBucketMoreThanMonthLabel => 'ينتهي بعد أكثر من شهر';

  @override
  String get mainNavHomeLabel => 'الرئيسية';

  @override
  String get mainNavHomeTooltip => 'الشاشة الرئيسية';

  @override
  String get mainNavExpiryLabel => 'النفاد';

  @override
  String get mainNavExpiryTooltip => 'العناصر القريبة من النفاد';

  @override
  String get mainNavShoppingLabel => 'الشراء';

  @override
  String get mainNavShoppingTooltip => 'قائمة التسوق';

  @override
  String editPriceDialogTitleWithItem(String itemName) {
    return 'السعر لـ \"$itemName\"';
  }

  @override
  String get editPriceDialogTitle => 'تعديل السعر';

  @override
  String get priceFieldLabel => 'السعر (اختياري)';

  @override
  String get priceFieldHint => '0.00';

  @override
  String get invalidPriceFormat => 'صيغة السعر غير صحيحة';

  @override
  String get priceCannotBeNegativeDialog => 'لا يمكن أن يكون السعر سالباً';

  @override
  String get dialogCancel => 'إلغاء';

  @override
  String get dialogSave => 'حفظ';

  @override
  String get shoppingItemTrackedInApp => 'مُتابع في التطبيق';

  @override
  String get shoppingItemManualEntry => 'عنصر مُضاف يدوياً';

  @override
  String itemCardRefreshedText(String relativeDate) {
    return 'تم التجديد $relativeDate';
  }

  @override
  String itemCardQuantityDescription(String relativeDate) {
    return 'تم التجديد $relativeDate';
  }

  @override
  String itemRemainingDaysPositiveFormat(String days) {
    return 'يكفي $days يوم';
  }

  @override
  String get itemRemainingDaysZero => 'ينتهي اليوم';

  @override
  String itemRemainingDaysNegativeFormat(String days) {
    return 'انتهى منذ $days يوم';
  }

  @override
  String get expectedExpiryLabel => 'النفاد المتوقع';

  @override
  String get notificationsStopped => 'الإشعارات متوقفة';

  @override
  String notificationStartsInFormat(String days) {
    return 'سيبدأ التنبيه بعد $days يوم';
  }

  @override
  String get notificationActiveNow => 'التنبيه نشط الآن';

  @override
  String get errorUnknownRouteTitle => 'الصفحة غير موجودة';

  @override
  String get errorUnknownRouteMessage =>
      'الرابط الذي حاولت فتحه غير صحيح أو لم يعد متوفرًا.';

  @override
  String get errorItemNotFoundTitle => 'العنصر غير موجود';

  @override
  String get errorItemNotFoundMessage =>
      'لم نعثر على هذا العنصر، قد يكون تم حذفه مسبقًا.';

  @override
  String get errorItemLoadFailedTitle => 'تعذّر تحميل العنصر';

  @override
  String get errorItemLoadFailedMessage =>
      'حدث خطأ أثناء جلب بيانات العنصر، يرجى المحاولة مرة أخرى.';

  @override
  String get errorItemLoadUnexpectedTitle => 'تعذّر تحميل العنصر';

  @override
  String get errorItemLoadUnexpectedMessage =>
      'حدث خطأ غير متوقع أثناء تحميل هذه الشاشة.';

  @override
  String get errorRetryLabel => 'العودة إلى الرئيسية';

  @override
  String get batteryDialogTitle => 'تفعيل الاشعارات في الخلفية';

  @override
  String get batteryDialogContent =>
      'قد تؤخر إعدادات توفير البطارية التنبيهات.\n\nلضمان وصولها في الوقت المناسب، يُفضل استثناء التطبيق من قيود البطارية.';

  @override
  String get batteryDialogNotNow => 'ليس الآن';

  @override
  String get batteryDialogOpenSettings => 'فتح الإعدادات';

  @override
  String get batterySnackBarError =>
      'تعذر فتح الإعدادات تلقائيًا. لضمان ظهور الاشعارات التذكيرية يرجى الذهاب إلى الإعدادات > التطبيقات > تطبيقنا > البطارية > السماح بالتشغيل في الخلفية';

  @override
  String get notificationChannelName => 'الملخص اليومي';

  @override
  String get notificationChannelDescription =>
      'إشعار يومي يوضح العناصر التي تحتاج انتباه';

  @override
  String get notificationTitle => 'ملخص طلبات البيت';

  @override
  String get notificationUrgentPrefix => '🔴 عاجل: ';

  @override
  String get notificationWarningPrefix => '🟡 انتبه: ';

  @override
  String get settings => 'الإعدادات';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get backupAndRestore => 'النسخ الاحتياطي والاستعادة';

  @override
  String get createBackup => 'إنشاء نسخة احتياطية';

  @override
  String get restoreBackup => 'استعادة نسخة احتياطية';

  @override
  String get backupSuccess => 'تم إنشاء النسخة الاحتياطية بنجاح';

  @override
  String get backupFailed => 'فشل إنشاء النسخة الاحتياطية';

  @override
  String get restoreSuccess => 'تم استعادة النسخة الاحتياطية بنجاح';

  @override
  String get restoreFailed => 'فشل استعادة النسخة الاحتياطية';

  @override
  String get backupFileNotFound => 'ملف قاعدة البيانات غير موجود';

  @override
  String get operationCancelled => 'تم إلغاء العملية';

  @override
  String get processing => 'جاري المعالجة...';

  @override
  String get backupFileExtension => 'ملفات قاعدة البيانات (*.db)';

  @override
  String get createBackupSubtitle => 'إنشاء نسخة احتياطية من قاعدة البيانات';

  @override
  String get restoreBackupSubtitle => 'استعادة البيانات من ملف نسخة احتياطية';

  @override
  String get loadingSettingsMessage => 'جارٍ تحميل الإعدادات...';

  @override
  String get errorLoadingSettingsMessage => 'حدث خطأ أثناء تحميل الإعدادات';

  @override
  String get restoreInvalidFile => 'ملف النسخة الاحتياطية غير صالح';

  @override
  String get restoreFileNotFound => 'لم يتم العثور على ملف النسخة الاحتياطية';

  @override
  String get unknownError => 'حدث خطأ غير معروف';

  @override
  String get restoreConfirmationTitle => 'تأكيد استعادة النسخة الاحتياطية';

  @override
  String get restoreConfirmationContent =>
      'سيتم استبدال جميع البيانات الحالية بالبيانات الموجودة في النسخة الاحتياطية.\n\nبعد نجاح الاستعادة، سيتم إعادة تشغيل التطبيق لتحديث البيانات.\n\nهل تريد المتابعة؟';

  @override
  String get restoreConfirmLabel => 'استعادة';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get onboardingTitle1 => 'بيت منظم، وراحة بال';

  @override
  String get onboardingBody1 =>
      'انقل عناء التفكير بمتطلبات البيت بالكامل إلى تطبيقك. تتبع النواقص بذكاء ووفر طاقتك الذهنية لما هو أهم.';

  @override
  String get onboardingTitle2 => 'تنبيهات في وقتها، بلا مفاجآت';

  @override
  String get onboardingBody2 =>
      'تصلك تنبيهات عند اقتراب النواقص من النفاد، لتبقى مستعداً دائماً وتتجنب النقص المفاجئ.';

  @override
  String get onboardingTitle3 => 'تسوق سهل';

  @override
  String get onboardingBody3 =>
      'بنقرة زر، حوّل نواقصك إلى قائمة تسوق منظمة بدقة، وشاركها بسهولة عبر واتساب.';

  @override
  String get onboardingTitle4 => 'بياناتك في أمان';

  @override
  String get onboardingBody4 =>
      'بلا إنترنت. بلا حسابات. بياناتك ملكك وحدك وعلى جهازك، مع إمكانية النسخ الاحتياطي المحلي متى أردت.';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingDone => 'ابدأ';

  @override
  String get languageSelectionTitle => 'اختر اللغة';

  @override
  String get languageSelectionSubtitle => 'اختر لغتك المفضلة';

  @override
  String get languageChangeFailed => 'فشل تغيير اللغة. حاول مجدداً';

  @override
  String restockDialogTitleWithItem(String itemName) {
    return 'تجديد كمية: $itemName';
  }

  @override
  String get restockDialogTitleDefault => 'تجديد الكمية';

  @override
  String get restockDialogDescription =>
      'أدخل الكميات ليتم حساب الإجمالي وتحديث العداد من جديد.';

  @override
  String get currentDaysLabel => 'الأيام الحالية المتبقية';

  @override
  String get currentDaysHint => 'أدخل الأيام الحالية';

  @override
  String get requiredFieldError => 'مطلوب';

  @override
  String get invalidNumberError => 'أدخل رقماً صحيحاً';

  @override
  String originalValueLabel(int days) {
    return 'القيمة الأصلية المسجّلة: $days يوم';
  }

  @override
  String get addedDaysLabel => 'الأيام الجديدة المضافة (للكمية المشتراة)';

  @override
  String get addedDaysHint => 'أدخل عدد الأيام الجديدة';

  @override
  String get finalTotalLabel => 'الإجمالي النهائي للحفظ';

  @override
  String daysValueText(int days) {
    return '$days يوم';
  }

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get saveUpdateButton => 'حفظ التحديث';

  @override
  String get lastRefreshedLabel => 'آخر تجديد';

  @override
  String get outOfStockDatePickerHelpText => 'اختر تاريخ النفاد';

  @override
  String stockStatusDialogTitleWithItem(String itemName) {
    return 'تصحيح حالة: $itemName';
  }

  @override
  String get stockStatusDialogTitle => 'تصحيح حالة المادة';

  @override
  String get stockStatusChooseCorrectStatus => 'اختر الحالة الصحيحة للمادة:';

  @override
  String get stockStatusOutOfStockOption => 'نفدت فعلياً';

  @override
  String get stockStatusToday => 'اليوم';

  @override
  String get stockStatusYesterday => 'أمس';

  @override
  String get stockStatusOtherDate => 'تاريخ آخر';

  @override
  String get stockStatusStillAvailableOption => 'ما زالت لدي';

  @override
  String get stockStatusResetRemainingDays => 'إعادة ضبط الأيام المتبقية';

  @override
  String get stockStatusRemainingDaysLabel => 'الأيام المتبقية';

  @override
  String get stockStatusRemainingDaysHint => 'أدخل عدد الأيام';

  @override
  String get fieldRequiredValidation => 'مطلوب';

  @override
  String get enterValidNumberValidation => 'أدخل رقماً صحيحاً';

  @override
  String get saveLabel => 'حفظ';

  @override
  String get realityCheckSectionTitle => 'تصحيح الحالة أو التجديد';

  @override
  String get restockButtonLabel => 'اشتريت كمية جديدة (تجديد مبكر)';

  @override
  String get realityMismatchTitle => 'مخالفة الواقع للتوقع؟';

  @override
  String get realityMismatchDescription =>
      'إذا نفدت المادة فعلياً أو كان لا يزال لديك منها دون شراء جديد، قم بالتصحيح فوراً.';

  @override
  String get correctNowButtonLabel => 'تصحيح الواقع الآن';

  @override
  String get depletedToday => 'نفد اليوم.';

  @override
  String depletedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نفد قبل $count يوم.',
      many: 'نفد قبل $count يوماً.',
      few: 'نفد قبل $count أيام.',
      two: 'نفد قبل يومين.',
      one: 'نفد قبل يوم.',
    );
    return '$_temp0';
  }

  @override
  String get changeHistoryTitle => 'سجل التعديلات';

  @override
  String get changeHistoryEmpty => 'لا يوجد سجل تعديلات لهذا العنصر.';

  @override
  String get actionCreate => 'إنشاء';

  @override
  String get actionUpdate => 'تعديل';

  @override
  String get actionRestock => 'تجديد كمية';

  @override
  String get actionStockCorrection => 'تصحيح كمية';

  @override
  String get actionDelete => 'حذف';

  @override
  String get revertButton => 'الاستعادة لهذه النسخة';

  @override
  String get revertConfirmTitle => 'تأكيد الاستعادة';

  @override
  String get revertConfirmMessage =>
      'هل أنت متأكد من أنك تريد الرجوع إلى هذه النسخة؟ سيتم استبدال البيانات الحالية بالحالة التي كانت محفوظة في ذلك الوقت.';

  @override
  String get revertSuccess => 'تمت استعادة نسخة العنصر بنجاح.';

  @override
  String get revertFailed => 'تعذرت استعادة نسخة العنصر.';

  @override
  String revertDescription(String date) {
    return 'تمت الاستعادة إلى نسخة $date';
  }

  @override
  String diffNameChanged(String oldVal, String newVal) {
    return 'الاسم: $oldVal ← $newVal';
  }

  @override
  String diffQtyDescChanged(String oldVal, String newVal) {
    return 'الكمية: $oldVal ← $newVal';
  }

  @override
  String diffExpectedDaysChanged(String oldVal, String newVal) {
    return 'الأيام المتوقعة: $oldVal يوم ← $newVal يوم';
  }

  @override
  String diffWarningDaysChanged(String oldVal, String newVal) {
    return 'حد الانتباه: $oldVal يوم ← $newVal يوم';
  }

  @override
  String diffUrgentDaysChanged(String oldVal, String newVal) {
    return 'حد العاجل: $oldVal يوم ← $newVal يوم';
  }

  @override
  String diffNotificationsChanged(String oldVal, String newVal) {
    return 'الإشعارات: $oldVal ← $newVal';
  }

  @override
  String get diffNotesChanged => 'تم تحديث الملاحظات';

  @override
  String diffRefreshedAtChangedFromTo(String oldVal, String newVal) {
    return 'تاريخ التجديد:\n    من : $oldVal\n    إلى: $newVal';
  }

  @override
  String get diffItemCreated => 'تم إنشاء العنصر بالإعدادات الأولية';

  @override
  String get diffItemDeleted => 'تم حذف العنصر';

  @override
  String get diffNoChanges => 'لم يتم رصد تغييرات في الخصائص';

  @override
  String get enabledText => 'مفعّل';

  @override
  String get disabledText => 'معطّل';

  @override
  String get customRetentionDaysTitle => 'أيام الاحتفاظ المخصصة';

  @override
  String get customRetentionDaysContent => 'أدخل عدد الأيام للاحتفاظ بالسجلات.';

  @override
  String get customRetentionDaysLabel => 'عدد الأيام';

  @override
  String get customRetentionDaysHint => 'مثال: 30';

  @override
  String get autoDeletionOffNoLogsRemoved =>
      'الحذف التلقائي معطل. لم تتم إزالة أي سجلات.';

  @override
  String logDeletedCount(int deletedCount) {
    return 'تم حذف $deletedCount سجل.';
  }

  @override
  String get noLogsMatchedRetention => 'لا توجد سجلات تطابق سياسة الاحتفاظ.';

  @override
  String get deleteLogNowConfirmTitle => 'حذف السجلات الآن؟';

  @override
  String get deleteLogNowConfirmContent =>
      'هل أنت متأكد أنك تريد حذف السجلات الأقدم من فترة الاحتفاظ المحددة؟';

  @override
  String get logManagement => 'إدارة السجلات';

  @override
  String get logRetentionOff => 'إيقاف';

  @override
  String get logRetentionOffWarning =>
      'سيؤدي هذا إلى الاحتفاظ بجميع السجلات إلى الأبد، مما قد يستهلك مساحة تخزين كبيرة.';

  @override
  String get logRetentionThreeMonths => '3 أشهر';

  @override
  String get logRetentionSixMonths => '6 أشهر';

  @override
  String get logRetentionOneYear => 'سنة واحدة';

  @override
  String customRetentionFormat(int days) {
    return 'مخصص ($days يوم)';
  }

  @override
  String get logRetentionCustom => 'مخصص';

  @override
  String get deleteLogNow => 'حذف السجلات الآن';

  @override
  String get customRetentionDaysValidationError =>
      'يرجى إدخال عدد أيام صحيح (يوم واحد على الأقل)';

  @override
  String get logRetentionSectionSubtitle =>
      'حدد المدة التي يحتفظ فيها التطبيق بسجل التغييرات قبل حذفه تلقائياً.';

  @override
  String get logRetentionDurationLabel => 'مدة الاحتفاظ بالسجل';

  @override
  String get logRetentionDaysMustBePositive => 'يجب أن يكون العدد أكبر من صفر';

  @override
  String get retentionPolicyUpdated => 'تم تحديث سياسة الاحتفاظ بالسجلات';

  @override
  String get expectedDaysNote =>
      'يكفي رقم تقريبي، ولا يشترط أن يكون دقيقًا بنسبة 100٪';
}
