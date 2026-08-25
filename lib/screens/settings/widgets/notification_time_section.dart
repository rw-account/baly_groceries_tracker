// lib/screens/settings/widgets/notification_time_section.dart

import 'package:baly_groceries_tracker/core/utils/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../services/battery_service.dart';
import '../../../services/workmanager_service.dart';

class NotificationTimeSection extends StatefulWidget {
  const NotificationTimeSection({super.key});

  @override
  State<NotificationTimeSection> createState() => _NotificationTimeSectionState();
}

class _NotificationTimeSectionState extends State<NotificationTimeSection>
    with WidgetsBindingObserver {

  TimeOfDay _selectedTime = const TimeOfDay(hour: 5, minute: 0);
  bool _isLoading = true;
  bool _showBatteryWarning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotificationTime();
    _checkBatteryOptimization();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-checks the battery optimization status when the user returns to the app,
    // for example, after disabling battery optimization in the system settings.
    if (state == AppLifecycleState.resumed) {
      _checkBatteryOptimization();
    }
  }

  Future<void> _loadNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final int hour = prefs.getInt(kNotificationHourKey) ?? kDefaultHour;
    final int minute = prefs.getInt(kNotificationMinuteKey) ?? kDefaultMinute;

    if (!mounted) return;
    setState(() {
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
      _isLoading = false;
    });
  }

  Future<void> _checkBatteryOptimization() async {
    final isIgnoring = await BatteryService.isIgnoringBatteryOptimizations();
    if (!mounted) return;
    setState(() {
      _showBatteryWarning = !isIgnoring;
    });
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      cancelText: context.loc.cancelLabel,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked == null || picked == _selectedTime) return;
    if (!mounted) return;
    await _saveNotificationTime(picked);
  }

  Future<void> _saveNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kNotificationHourKey, time.hour);
    await prefs.setInt(kNotificationMinuteKey, time.minute);

    if (!mounted) return;
    setState(() {
      _selectedTime = time;
    });

    await WorkmanagerService.updateDailyTaskSchedule();

    if (!mounted) return;
    showSuccessSnackBar(context, context.loc.notificationTimeUpdated);
  }

  Future<void> _handleOpenBatterySettings() async {
    final success = await BatteryService.openBatterySettings();
    if (!mounted) return;
    if (success) return;
    showErrorSnackBar(context, context.loc.batterySnackBarError);
  }

  String _formatTimeOfDay(TimeOfDay time) => time.format(context);

  Widget _buildCardShell({
    required ColorScheme colorScheme,
    required Widget child,
    Color? color,
    Color? borderColor,
  }) {
    return Card(
      elevation: 0,
      color: color ?? colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: borderColor ?? colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(ThemeData theme) {
    return Text(
      context.loc.notificationTimeSectionTitle,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBatteryWarningCard(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: _buildCardShell(
        colorScheme: colorScheme,
        color: colorScheme.errorContainer,
        borderColor: colorScheme.error.withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.battery_alert_rounded, 
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.loc.batteryOptimizationWarningTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                context.loc.batteryOptimizationWarningContent,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _handleOpenBatterySettings,
                  icon: const Icon(Icons.settings_outlined, size: 20),
                  label: Text(context.loc.batteryOptimizationOpenSettings),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme),
        const SizedBox(height: 16),
        _buildCardShell(
          colorScheme: colorScheme,
          child: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
                      leading: Icon(Icons.schedule_outlined, color: colorScheme.primary),
                      title: Text(
                        context.loc.notificationTimeLabel,
                        style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        _formatTimeOfDay(_selectedTime),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                      onTap: _pickTime,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.loc.notificationTimeDisclaimer,
                                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        if (_showBatteryWarning) _buildBatteryWarningCard(theme, colorScheme),
      ],
    );
  }
}