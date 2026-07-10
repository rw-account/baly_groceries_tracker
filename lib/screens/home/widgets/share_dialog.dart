// lib/screens/home/widgets/share_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/item_model.dart';

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
      title: const Text('خيارات المشاركة'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الحالات المضمنة:', style: TextStyle(fontWeight: FontWeight.bold)),
            
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
                    title: const Text('كل الحالات'),
                    value: 'all',
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: const Text('حالات التنبيه والعاجلة فقط'),
                    value: 'warning_urgent',
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: const Text('حالة التنبيه فقط'),
                    value: 'warning',
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: const Text('الحالة العاجلة فقط'),
                    value: 'urgent',
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            
            const Divider(),
            const Text('خيارات إضافية:', style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: const Text('تضمين عدد الأيام المتبقية'),
              value: _includeDays,
              onChanged: (value) => setState(() => _includeDays = value!),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('تحديد تاريخ التجديد'),
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
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _generateAndShare,
          child: const Text('مشاركة'),
        ),
      ],
    );
  }

  void _generateAndShare() {
    final buffer = StringBuffer();
    final today = DateFormat('yyyy/MM/dd').format(DateTime.now());
    buffer.writeln('📅 تاريخ التقرير: $today');
    buffer.writeln('📋 تفاصيل المواد:');
    buffer.writeln('-------------------');

    for (final item in widget.items) {
      if (_statusFilter == 'warning' && item.status != ItemStatus.warning) continue;
      if (_statusFilter == 'urgent' && item.status != ItemStatus.urgent) continue;
      if (_statusFilter == 'warning_urgent' && item.status != ItemStatus.warning && item.status != ItemStatus.urgent) continue;

      String line = '• ${item.name}';

      if (_includeDays) {
        line += ' (متبقي: ${item.remainingDays} يوم)';
      }

      if (_includeRenewal) {
        final dateStr = DateFormat('yyyy/MM/dd').format(item.expectedExpiryDate);
        line += ' [التجديد: $dateStr]';
      }

      buffer.writeln(line);
    }

    Navigator.pop(context);
    
    try {
      SharePlus.instance.share(
        ShareParams(text: buffer.toString()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر مشاركة التقرير: $e')),
      );
    }
  }
}