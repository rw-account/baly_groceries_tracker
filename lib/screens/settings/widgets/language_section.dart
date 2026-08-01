// lib/screens/settings/widgets/language_section.dart

import 'package:flutter/material.dart';
import '../../../core/utils/context_extensions.dart';
import 'language_option.dart';

class LanguageSection extends StatelessWidget {
  const LanguageSection({
    super.key,
    required this.currentLanguageCode,
    required this.onLanguageSelected,
  });

  final String currentLanguageCode;
  final ValueChanged<String> onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.language,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        LanguageOption(
          label: context.loc.arabic,
          isSelected: currentLanguageCode == 'ar',
          onTap: () => onLanguageSelected('ar'),
        ),
        const SizedBox(height: 8),
        LanguageOption(
          label: context.loc.english,
          isSelected: currentLanguageCode == 'en',
          onTap: () => onLanguageSelected('en'),
        ),
      ],
    );
  }
}
