// lib/screens/home/widgets/share_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/item_model.dart';
import '../../../core/utils/context_extensions.dart';

class ShareOptionsDialog extends StatefulWidget {
  final List<ItemModel> items;

  const ShareOptionsDialog({super.key, required this.items});

  @override
  State<ShareOptionsDialog> createState() => _ShareOptionsDialogState();
}

class _ShareOptionsDialogState extends State<ShareOptionsDialog> {
  String _statusFilter = 'all'; // all, warning, urgent
  bool _includeDays = true;
  bool _includeRenewal = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      title: Text(context.loc.shareOptionsTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.loc.includedStatusesLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            
            RadioGroup<String>(
              groupValue: _statusFilter,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => _statusFilter = value);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text(context.loc.allStatusesOption),
                    value: 'all',
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: Text(context.loc.warningAndUrgentOption),
                    value: 'warning_urgent',
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: Text(context.loc.warningOnlyOption),
                    value: 'warning',
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: Text(context.loc.urgentOnlyOption),
                    value: 'urgent',
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            
            const Divider(),
            Text(context.loc.additionalOptionsLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: Text(context.loc.includeRemainingDays),
              value: _includeDays,
              onChanged: (value) => setState(() => _includeDays = value!),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: Text(context.loc.includeRenewalDate),
              value: _includeRenewal,
              onChanged: (value) => setState(() => _includeRenewal = value!),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.loc.cancelLabel),
        ),
        FilledButton(
          onPressed: _generateAndShare,
          child: Text(context.loc.shareLabel),
        ),
      ],
    );
  }

  void _generateAndShare() {
    final buffer = StringBuffer();
    final today = DateFormat('yyyy/MM/dd').format(DateTime.now());
    buffer.writeln(context.loc.reportDateFormat(today));
    buffer.writeln(context.loc.itemDetailsHeader);
    buffer.writeln('\n━━━━━━━━━━━━━━━━━━━━\n');

    for (final item in widget.items) {
      if (_statusFilter == 'warning' && item.status != ItemStatus.warning) continue;
      if (_statusFilter == 'urgent' && item.status != ItemStatus.urgent) continue;
      if (_statusFilter == 'warning_urgent' && item.status != ItemStatus.warning && item.status != ItemStatus.urgent) continue;

      buffer.writeln('• ${item.name}');

      if (_includeDays) {
          buffer.writeln(
            context.loc.remainingDaysFormat(item.remainingDays.toString()),
          );
      }

      if (_includeRenewal) {
        final dateStr = DateFormat('yyyy/MM/dd').format(item.expectedExpiryDate);
        buffer.writeln(context.loc.renewalDateFormat(dateStr));
      }

      buffer.writeln();
    }

    Navigator.pop(context);
    
    try {
      SharePlus.instance.share(
        ShareParams(text: buffer.toString()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.loc.shareReportError(e.toString()))),
      );
    }
  }
}