// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get searchHint => 'Search for an item...';

  @override
  String get noResultsFound => 'No matching results found';

  @override
  String errorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get addButtonLabel => 'Add';

  @override
  String get emptyStateTitle => 'No items yet';

  @override
  String get emptyStateSubtitle => 'Tap the button to add a new item';

  @override
  String get shareOptionsTitle => 'Sharing Options';

  @override
  String get includedStatusesLabel => 'Included statuses:';

  @override
  String get allStatusesOption => 'All statuses';

  @override
  String get warningAndUrgentOption => 'Warning and urgent statuses only';

  @override
  String get warningOnlyOption => 'Warning status only';

  @override
  String get urgentOnlyOption => 'Urgent status only';

  @override
  String get additionalOptionsLabel => 'Additional options:';

  @override
  String get includeRemainingDays => 'Include remaining days';

  @override
  String get includeRenewalDate => 'Include renewal date';

  @override
  String get cancelLabel => 'Cancel';

  @override
  String get shareLabel => 'Share';

  @override
  String reportDateFormat(String date) {
    return '📅 Report date: $date';
  }

  @override
  String get itemDetailsHeader => '📋 Item details';

  @override
  String remainingDaysFormat(String days) {
    return '   • Remaining: $days days';
  }

  @override
  String renewalDateFormat(String date) {
    return '   • Renewal: $date';
  }

  @override
  String shareReportError(String error) {
    return 'Could not share the report: $error';
  }

  @override
  String get statusSafe => 'Safe';

  @override
  String get statusWarning => 'Warning';

  @override
  String get statusUrgent => 'Urgent';

  @override
  String get appTitle => 'Home Orders Tracker';

  @override
  String get shareItemDetails => 'Share item details';

  @override
  String get shoppingListTitle => 'Shopping List';

  @override
  String get deleteAllItemsMenu => 'Delete all items';

  @override
  String get shareListMenu => 'Share list';

  @override
  String get clearSelectionTooltip => 'Clear selection';

  @override
  String selectedCountFormat(String count) {
    return 'Selected items: $count';
  }

  @override
  String get deleteSelectedTooltip => 'Delete selected';

  @override
  String errorOccurredFormat(String error) {
    return 'An error occurred: $error';
  }

  @override
  String failedToDeleteFormat(String itemTitle) {
    return 'Could not delete \"$itemTitle\"';
  }

  @override
  String deletedFormat(String itemTitle) {
    return 'Deleted \"$itemTitle\"';
  }

  @override
  String get undoLabel => 'Undo';

  @override
  String failedToRestoreFormat(String itemTitle) {
    return 'Could not restore \"$itemTitle\"';
  }

  @override
  String get deleteSelectedTitle => 'Delete Selected Items';

  @override
  String confirmDeleteSelectedFormat(String count) {
    return 'Delete $count items?';
  }

  @override
  String get deleteButtonLabel => 'Delete';

  @override
  String get failedToDeleteSelected => 'Could not delete the selected items';

  @override
  String deletedSelectedFormat(String count) {
    return 'Deleted $count items';
  }

  @override
  String get failedToRestoreItems => 'Could not restore the items';

  @override
  String get deleteAllTitle => 'Delete All Items';

  @override
  String get confirmDeleteAllMessage =>
      'Are you sure you want to delete all shopping list items? This cannot be undone.';

  @override
  String get deleteAllButton => 'Delete All';

  @override
  String get deletedAllItems => 'All shopping list items were deleted';

  @override
  String get failedToDeleteAllItems =>
      'Could not delete all shopping list items';

  @override
  String get listIsEmpty => 'The list is empty';

  @override
  String get includePrice => 'Include price';

  @override
  String get includePurchaseStatus => 'Include purchase status';

  @override
  String get shareListHeader => '🛒 Shopping list';

  @override
  String priceFormat(String price) {
    return '   • Price: $price';
  }

  @override
  String get completedFormat => '   • ✅ Completed';

  @override
  String get notCompletedFormat => '   • ❌ Not completed';

  @override
  String failedToShareList(String error) {
    return 'Could not share the list: $error';
  }

  @override
  String get totalLabel => 'Total';

  @override
  String get shoppingEmptyStateTitle => 'No items in the shopping list';

  @override
  String get shoppingEmptyStateSubtitle =>
      'Tap the add button to start shopping';

  @override
  String get addItemButton => 'Add Item';

  @override
  String get addNewItemTitle => 'Add New Item';

  @override
  String get addToShoppingListTitle => 'Add to Shopping List';

  @override
  String get addErrorRetry =>
      'An error occurred while adding. Please try again.';

  @override
  String get itemExistsInShoppingList =>
      'This item is already in the shopping list.';

  @override
  String get itemTrackedInApp =>
      'This item is already tracked in the app. Please add it from the previous search screen.';

  @override
  String get invalidPriceFormatMessage => 'Invalid price format';

  @override
  String get priceCannotBeNegative => 'Price cannot be negative';

  @override
  String get itemNotAddedRetry => 'The item was not added. Please try again.';

  @override
  String get shoppingSearchHint => 'Enter an item name...';

  @override
  String get clearSearchTooltip => 'Clear search';

  @override
  String get startTypingHint => 'Start typing the item name to add it';

  @override
  String get searchResultsSection => 'Search Results';

  @override
  String addAsNewItemFormat(String query) {
    return 'Add \"$query\" as a new item';
  }

  @override
  String get alreadyInShoppingList => 'Already in the shopping list';

  @override
  String get itemNameHint => 'Example: milk, eggs, rice...';

  @override
  String get itemNameLabel => 'Item name';

  @override
  String get priceLabel => 'Price (optional)';

  @override
  String get priceHint => '0.00';

  @override
  String get addingLabel => 'Adding...';

  @override
  String get addToListButton => 'Add to List';

  @override
  String get editItemTitle => 'Edit Item';

  @override
  String get addItemScreenTitle => 'Add New Item';

  @override
  String get backTooltip => 'Back';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String get notificationsSectionTitle => 'Notifications';

  @override
  String get enableNotificationsTitle => 'Enable notifications';

  @override
  String get notificationsEnabledSubtitle =>
      'You will receive notifications when supplies are close to running out';

  @override
  String get notificationsDisabledSubtitle =>
      'You will not receive notifications for this item';

  @override
  String get deleteItemSectionTitle => 'Delete Item';

  @override
  String get deleteItemTitle => 'Delete Item';

  @override
  String get thresholdsSectionTitle => 'Alert Thresholds';

  @override
  String get thresholdsDescription =>
      'The app determines each item\'s status based on these thresholds';

  @override
  String get warningThresholdLabel => '🟡 Warning threshold';

  @override
  String get urgentThresholdLabel => '🔴 Urgent threshold';

  @override
  String get itemInfoSectionTitle => 'Item Information';

  @override
  String get itemNameFieldLabel => 'Item name';

  @override
  String get itemNameFieldHint => 'Example: sugar, flour, oil';

  @override
  String get quantityDescriptionLabel => 'Quantity description (optional)';

  @override
  String get quantityDescriptionHint => 'Example: 5 kg bag, two packs';

  @override
  String get expectedDaysLabel => 'Expected days until depletion';

  @override
  String get expectedDaysHint => 'Example: 30';

  @override
  String get daysSuffix => 'days';

  @override
  String get notesLabel => 'Notes (optional)';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get addItemSubmitButton => 'Add Item';

  @override
  String get nameRequiredError => 'Name is required';

  @override
  String get enterDaysError => 'Enter the number of days';

  @override
  String get enterValidNumberError => 'Enter a valid number';

  @override
  String get duplicateNameError => 'This name already exists';

  @override
  String get invalidDaysError => 'Please enter a valid number of days';

  @override
  String get thresholdOrderError =>
      'Warning days must be greater than urgent days.';

  @override
  String get negativeThresholdError => 'Threshold values cannot be negative';

  @override
  String get refreshDateRequiredError => 'Please enter the refresh date';

  @override
  String get genericSaveError =>
      'An error occurred while saving the item. Please try again.';

  @override
  String get renewalDatePickerHelpText => 'Select renewal date';

  @override
  String get datePickerCancelText => 'Cancel';

  @override
  String get datePickerConfirmText => 'Confirm';

  @override
  String get datePickerError =>
      'Could not open the date picker. Please try again.';

  @override
  String get resetDateDialogTitle => 'Reset Renewal Date';

  @override
  String get resetDateDialogContent =>
      'Do you want to set the renewal date to today\'s date?';

  @override
  String get resetDateCancelLabel => 'Cancel';

  @override
  String get resetDateConfirmLabel => 'OK';

  @override
  String get discardDialogTitle => 'Discard changes?';

  @override
  String get discardDialogContent =>
      'You have unsaved changes. Do you want to exit without saving?';

  @override
  String get discardCancelLabel => 'Cancel';

  @override
  String get discardLabel => 'Discard';

  @override
  String get deleteItemDialogTitle => 'Delete Item';

  @override
  String deleteItemDialogContentFormat(String itemName) {
    return 'Are you sure you want to delete \"$itemName\"? It will also be removed from the shopping list if it was added there. This action cannot be undone.';
  }

  @override
  String get deleteItemCancelLabel => 'Cancel';

  @override
  String get deleteItemButtonLabel => 'Delete';

  @override
  String get deleteItemError => 'Could not delete the item. Please try again.';

  @override
  String get thresholdDaysSuffix => 'in days';

  @override
  String get thresholdFieldSuffix => 'days';

  @override
  String get refreshDateLabel => 'Renewal date';

  @override
  String get refreshDateHint => 'YYYY-MM-DD';

  @override
  String get pickRefreshDateTooltip => 'Select renewal date';

  @override
  String get resetToTodayButton => 'Reset to today\'s date';

  @override
  String get expiryScreenTitle => 'Items About to Run Out';

  @override
  String get addAllToShoppingListMenu => 'Add all items to the shopping list';

  @override
  String get allItemsAlreadyInShoppingList =>
      'All items are already in the shopping list';

  @override
  String get allItemsAddedToShoppingList =>
      'All items were added to the shopping list.';

  @override
  String failedToAddAllItemsFormat(String error) {
    return 'An error occurred while adding items to the shopping list: $error';
  }

  @override
  String itemAddedToShoppingListFormat(String itemName) {
    return '\"$itemName\" was added to the shopping list';
  }

  @override
  String itemAlreadyInShoppingListFormat(String itemName) {
    return '\"$itemName\" is already in the shopping list';
  }

  @override
  String failedToAddItemFormat(String error) {
    return 'Failed to add the item: $error';
  }

  @override
  String get expiryNoticeText =>
      'Note: Only items with Warning or Urgent status are shown. Safe items do not appear here.';

  @override
  String get inShoppingListChipLabel => 'In list';

  @override
  String get expiresToday => 'Runs out today';

  @override
  String expiresInFormat(String date) {
    return 'Runs out $date';
  }

  @override
  String expiredFormat(String date) {
    return 'Ran out $date';
  }

  @override
  String get expiryEmptyStateTitle =>
      'Great! Your inventory is in safe condition';

  @override
  String get expiryEmptyStateSubtitle => 'No items need attention right now';

  @override
  String get expiryBucketExpiredLabel => '❌ Ran out';

  @override
  String get expiryBucketThreeDaysLabel => 'Runs out within 3 days';

  @override
  String get expiryBucketWeekLabel => 'Runs out within a week';

  @override
  String get expiryBucketTwoWeeksLabel => 'Runs out within two weeks';

  @override
  String get expiryBucketMonthLabel => 'Runs out within a month';

  @override
  String get expiryBucketMoreThanMonthLabel => 'Runs out in more than a month';

  @override
  String get mainNavHomeLabel => 'Home';

  @override
  String get mainNavHomeTooltip => 'Home screen';

  @override
  String get mainNavExpiryLabel => 'Expiry';

  @override
  String get mainNavExpiryTooltip => 'Items close to running out';

  @override
  String get mainNavShoppingLabel => 'Shopping';

  @override
  String get mainNavShoppingTooltip => 'Shopping list';

  @override
  String editPriceDialogTitleWithItem(String itemName) {
    return 'Price for \"$itemName\"';
  }

  @override
  String get editPriceDialogTitle => 'Edit Price';

  @override
  String get priceFieldLabel => 'Price (optional)';

  @override
  String get priceFieldHint => '0.00';

  @override
  String get invalidPriceFormat => 'Invalid price format';

  @override
  String get priceCannotBeNegativeDialog => 'Price cannot be negative';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogSave => 'Save';

  @override
  String get shoppingItemTrackedInApp => 'Tracked in the app';

  @override
  String get shoppingItemManualEntry => 'Manually added item';

  @override
  String itemCardRefreshedText(String relativeDate) {
    return 'Renewed $relativeDate';
  }

  @override
  String itemCardQuantityDescription(String relativeDate) {
    return 'Renewed $relativeDate';
  }

  @override
  String itemRemainingDaysPositiveFormat(String days) {
    return 'Enough for $days days';
  }

  @override
  String get itemRemainingDaysZero => 'Runs out today';

  @override
  String itemRemainingDaysNegativeFormat(String days) {
    return 'Ran out $days days ago';
  }

  @override
  String get expectedExpiryLabel => 'Expected depletion';

  @override
  String get notificationsStopped => 'Notifications are off';

  @override
  String notificationStartsInFormat(String days) {
    return 'Alerts will start in $days days';
  }

  @override
  String get notificationActiveNow => 'Alert is active now';

  @override
  String get errorUnknownRouteTitle => 'Page Not Found';

  @override
  String get errorUnknownRouteMessage =>
      'The link you tried to open is invalid or no longer available.';

  @override
  String get errorItemNotFoundTitle => 'Item Not Found';

  @override
  String get errorItemNotFoundMessage =>
      'We could not find this item. It may have already been deleted.';

  @override
  String get errorItemLoadFailedTitle => 'Could not load item';

  @override
  String get errorItemLoadFailedMessage =>
      'An error occurred while fetching the item data. Please try again.';

  @override
  String get errorItemLoadUnexpectedTitle => 'Could not load item';

  @override
  String get errorItemLoadUnexpectedMessage =>
      'An unexpected error occurred while loading this screen.';

  @override
  String get errorRetryLabel => 'Back to Home';

  @override
  String get batteryDialogTitle => 'Enable background notifications';

  @override
  String get batteryDialogContent =>
      'Battery optimization settings may delay notifications.\n\nTo receive them on time, please exclude the app from battery restrictions.';

  @override
  String get batteryDialogNotNow => 'Not now';

  @override
  String get batteryDialogOpenSettings => 'Open Settings';

  @override
  String get batterySnackBarError =>
      'Could not open settings automatically. To ensure reminder notifications appear, go to Settings > Apps > Home Orders Tracker > Battery > Allow background activity';

  @override
  String get notificationChannelName => 'Daily Summary';

  @override
  String get notificationChannelDescription =>
      'A daily notification showing items that need attention';

  @override
  String get notificationTitle => 'Home Orders Summary';

  @override
  String get notificationUrgentPrefix => '🔴 Urgent: ';

  @override
  String get notificationWarningPrefix => '🟡 Warning: ';

  @override
  String get settings => 'Settings';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get backupAndRestore => 'Backup & Restore';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get restoreBackup => 'Restore Backup';

  @override
  String get backupSuccess => 'Backup created successfully';

  @override
  String get backupFailed => 'Failed to create backup';

  @override
  String get restoreSuccess => 'Backup restored successfully';

  @override
  String get restoreFailed => 'Failed to restore backup';

  @override
  String get backupFileNotFound => 'Database file not found';

  @override
  String get operationCancelled => 'Operation cancelled';

  @override
  String get processing => 'Processing...';

  @override
  String get backupFileExtension => 'Database files (*.db)';

  @override
  String get createBackupSubtitle => 'Create a backup of the database';

  @override
  String get restoreBackupSubtitle => 'Restore data from a backup file';

  @override
  String get loadingSettingsMessage => 'Loading settings...';

  @override
  String get errorLoadingSettingsMessage => 'Error loading settings';

  @override
  String get restoreInvalidFile => 'The backup file is invalid';

  @override
  String get restoreFileNotFound => 'Backup file not found';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get restoreConfirmationTitle => 'Confirm Backup Restore';

  @override
  String get restoreConfirmationContent =>
      'All current data will be replaced with the data from the backup file.\n\nAfter a successful restore, the app will restart to refresh the data.\n\nDo you want to continue?';

  @override
  String get restoreConfirmLabel => 'Restore';

  @override
  String get loading => 'Loading...';

  @override
  String get onboardingTitle1 => 'Organized Home, Peace of Mind';

  @override
  String get onboardingBody1 =>
      'Transfer the burden of tracking household needs entirely to the app. Smartly track what\'s running low and save your mental energy for what truly matters.';

  @override
  String get onboardingTitle2 => 'Timely Alerts, No Surprises';

  @override
  String get onboardingBody2 =>
      'Receive alerts when items are running low, so you stay prepared and avoid sudden shortages.';

  @override
  String get onboardingTitle3 => 'Effortless Shopping';

  @override
  String get onboardingBody3 =>
      'With a single tap, turn your missing items into a neatly organized shopping list and easily share it via WhatsApp.';

  @override
  String get onboardingTitle4 => 'Your Data Stays Yours';

  @override
  String get onboardingBody4 =>
      'No internet. No accounts. Your data is yours alone and stays on your device, with the option to back it up locally whenever you want.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingDone => 'Start';

  @override
  String get languageSelectionTitle => 'Select Language';

  @override
  String get languageSelectionSubtitle => 'Choose your preferred language';

  @override
  String get languageChangeFailed =>
      'Failed to change language. Please try again.';

  @override
  String restockDialogTitleWithItem(String itemName) {
    return 'Restock: $itemName';
  }

  @override
  String get restockDialogTitleDefault => 'Restock Quantity';

  @override
  String get restockDialogDescription =>
      'Enter the quantities to calculate the total and update the counter.';

  @override
  String get currentDaysLabel => 'Current Remaining Days';

  @override
  String get currentDaysHint => 'Enter the current days';

  @override
  String get requiredFieldError => 'Required';

  @override
  String get invalidNumberError => 'Enter a valid number';

  @override
  String originalValueLabel(int days) {
    return 'Originally recorded value: $days days';
  }

  @override
  String get addedDaysLabel => 'New Added Days (for the purchased quantity)';

  @override
  String get addedDaysHint => 'Enter the number of new days';

  @override
  String get finalTotalLabel => 'Final Total to Save';

  @override
  String daysValueText(int days) {
    return '$days days';
  }

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveUpdateButton => 'Save Update';

  @override
  String get lastRefreshedLabel => 'Last refreshed';

  @override
  String get outOfStockDatePickerHelpText => 'Select out-of-stock date';

  @override
  String stockStatusDialogTitleWithItem(String itemName) {
    return 'Correct status: $itemName';
  }

  @override
  String get stockStatusDialogTitle => 'Correct item status';

  @override
  String get stockStatusChooseCorrectStatus =>
      'Choose the correct status for the item:';

  @override
  String get stockStatusOutOfStockOption => 'Actually out of stock';

  @override
  String get stockStatusToday => 'Today';

  @override
  String get stockStatusYesterday => 'Yesterday';

  @override
  String get stockStatusOtherDate => 'Other date';

  @override
  String get stockStatusStillAvailableOption => 'Still have it';

  @override
  String get stockStatusResetRemainingDays => 'Reset remaining days';

  @override
  String get stockStatusRemainingDaysLabel => 'Remaining days';

  @override
  String get stockStatusRemainingDaysHint => 'Enter number of days';

  @override
  String get fieldRequiredValidation => 'Required';

  @override
  String get enterValidNumberValidation => 'Enter a valid number';

  @override
  String get saveLabel => 'Save';

  @override
  String get realityCheckSectionTitle => 'Correct Status or Restock';

  @override
  String get restockButtonLabel => 'Bought a new quantity (early restock)';

  @override
  String get realityMismatchTitle => 'Reality doesn\'t match the expectation?';

  @override
  String get realityMismatchDescription =>
      'If the item has actually run out, or you still have some without buying new, correct it immediately.';

  @override
  String get correctNowButtonLabel => 'Correct Reality Now';

  @override
  String get depletedToday => 'Ran out today.';

  @override
  String depletedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ran out $count days ago.',
      one: 'Ran out 1 day ago.',
    );
    return '$_temp0';
  }

  @override
  String get changeHistoryTitle => 'Change History';

  @override
  String get changeHistoryEmpty => 'No change history found for this item.';

  @override
  String get actionCreate => 'Created';

  @override
  String get actionUpdate => 'Updated';

  @override
  String get actionRestock => 'Restocked';

  @override
  String get actionStockCorrection => 'Stock Correction';

  @override
  String get actionDelete => 'Deleted';

  @override
  String get revertButton => 'Revert to this version';

  @override
  String get revertConfirmTitle => 'Confirm Revert';

  @override
  String get revertConfirmMessage =>
      'Are you sure you want to revert to this version? Current data will be replaced with the state saved at that time.';

  @override
  String get revertSuccess => 'Successfully reverted item version.';

  @override
  String get revertFailed => 'Failed to revert item version.';

  @override
  String revertDescription(String date) {
    return 'Reverted to version from $date';
  }

  @override
  String diffNameChanged(String oldVal, String newVal) {
    return 'Name: $oldVal → $newVal';
  }

  @override
  String diffQtyDescChanged(String oldVal, String newVal) {
    return 'Quantity: $oldVal → $newVal';
  }

  @override
  String diffExpectedDaysChanged(String oldVal, String newVal) {
    return 'Expected days: $oldVal days → $newVal days';
  }

  @override
  String diffWarningDaysChanged(String oldVal, String newVal) {
    return 'Warning threshold: $oldVal days → $newVal days';
  }

  @override
  String diffUrgentDaysChanged(String oldVal, String newVal) {
    return 'Urgent threshold: $oldVal days → $newVal days';
  }

  @override
  String diffNotificationsChanged(String oldVal, String newVal) {
    return 'Notifications: $oldVal → $newVal';
  }

  @override
  String get diffNotesChanged => 'Notes updated';

  @override
  String diffRefreshedAtChangedFromTo(String oldVal, String newVal) {
    return 'Renewal date:\n    From: $oldVal\n    To:      $newVal';
  }

  @override
  String get diffItemCreated => 'Item created with initial settings';

  @override
  String get diffItemDeleted => 'Item was deleted';

  @override
  String get diffNoChanges => 'No property changes detected';

  @override
  String get enabledText => 'Enabled';

  @override
  String get disabledText => 'Disabled';

  @override
  String get customRetentionDaysTitle => 'Custom Retention Days';

  @override
  String get customRetentionDaysContent =>
      'Enter the number of days to retain logs.';

  @override
  String get customRetentionDaysLabel => 'Number of Days';

  @override
  String get customRetentionDaysHint => 'e.g., 30';

  @override
  String get autoDeletionOffNoLogsRemoved =>
      'Auto-deletion is off. No logs were removed.';

  @override
  String logDeletedCount(int deletedCount) {
    return '$deletedCount logs deleted.';
  }

  @override
  String get noLogsMatchedRetention => 'No logs matched the retention policy.';

  @override
  String get deleteLogNowConfirmTitle => 'Delete Logs Now?';

  @override
  String get deleteLogNowConfirmContent =>
      'Are you sure you want to delete logs older than the selected retention period?';

  @override
  String get logManagement => 'Log Management';

  @override
  String get logRetentionOff => 'Off';

  @override
  String get logRetentionOffWarning =>
      'This will keep all logs forever, which may consume significant storage space.';

  @override
  String get logRetentionThreeMonths => '3 Months';

  @override
  String get logRetentionSixMonths => '6 Months';

  @override
  String get logRetentionOneYear => '1 Year';

  @override
  String customRetentionFormat(int days) {
    return 'Custom ($days days)';
  }

  @override
  String get logRetentionCustom => 'Custom';

  @override
  String get deleteLogNow => 'Delete Logs Now';

  @override
  String get customRetentionDaysValidationError =>
      'Please enter a valid number of days (at least 1 day)';

  @override
  String get logRetentionSectionSubtitle =>
      'Choose how long the app keeps change history before it is automatically deleted.';

  @override
  String get logRetentionDurationLabel => 'Log retention duration';

  @override
  String get logRetentionDaysMustBePositive =>
      'The number must be greater than zero';

  @override
  String get retentionPolicyUpdated => 'Log retention policy updated';

  @override
  String get expectedDaysNote =>
      'An approximate number is enough; it doesn\'t have to be 100% accurate.';
}
