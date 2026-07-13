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
  String get shareItemDetails => 'مشاركة تفاصيل المواد';

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
  String get shoppingSearchHint => 'ابحث أو أنشئ عنصرًا...';

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
  String get thresholdsSectionTitle => 'حدود التنبيه';

  @override
  String get thresholdsDescription =>
      'يحدد التطبيق حالة كل مادة بناءً على هذه الحدود';

  @override
  String get safeThresholdLabel => '🟢 الحد الآمن';

  @override
  String get warningThresholdLabel => '🟡 حد الانتباه';

  @override
  String get urgentThresholdLabel => '🔴 الحد العاجل';

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
  String get notesHint => 'اكتب أي ملاحظة إضافية';

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
  String get thresholdOrderError =>
      'يجب أن تكون الحدود مرتبة: الآمن > الانتباه > العاجل';

  @override
  String get negativeThresholdError => 'لا يمكن أن تكون الحدود قيمًا سالبة';

  @override
  String get genericSaveError => 'حدث خطأ أثناء حفظ العنصر، حاول مرة أخرى';

  @override
  String get datePickerHelpText => 'اختر تاريخ التجديد';

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
    return 'هل أنت متأكد من حذف \"$itemName\"? سيتم حذفها أيضًا من قائمة الشراء إن كانت مضافة هناك. لا يمكن التراجع عن هذا الإجراء.';
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
  String get batterySnackBarRetry => 'إعادة المحاولة';

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
}
