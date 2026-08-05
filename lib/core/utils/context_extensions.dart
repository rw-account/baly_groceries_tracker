// lib/core/utils/context_extensions.dart

import 'package:flutter/material.dart';
import 'package:baly_groceries_tracker/l10n/app_localizations.dart';

extension LocalizedBuildContext on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
}
