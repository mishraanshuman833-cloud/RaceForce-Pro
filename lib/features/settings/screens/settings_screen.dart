// lib/features/settings/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // ── APPEARANCE ────────────────────────────────────────────
          _SectionHeader('APPEARANCE'),
          const SizedBox(height: 10),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.brightness_6_outlined,
                label: 'Theme',
                trailing: Text(
                  settings.themeModeLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _showThemePicker(context, settings),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── RUN EXPERIENCE ────────────────────────────────────────
          _SectionHeader('RUN EXPERIENCE'),
          const SizedBox(height: 10),

          _SettingsCard(
            children: [
              _SettingsSwitchTile(
                icon: Icons.record_voice_over_outlined,
                label: 'Voice Coach',
                subtitle: 'Audio alerts during your run',
                value: settings.voiceEnabled,
                onChanged: (v) => settings.setVoiceEnabled(v),
              ),
              Divider(height: 1, color: theme.dividerColor),
              _SettingsSwitchTile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                subtitle: 'Reminders and run alerts',
                value: settings.notificationsEnabled,
                onChanged: (v) => settings.setNotificationsEnabled(v),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── UNITS ─────────────────────────────────────────────────
          _SectionHeader('MEASUREMENT UNITS'),
          const SizedBox(height: 10),

          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.straighten_rounded,
                          color: AppTheme.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Distance & Speed',
                              style: theme.textTheme.bodyLarge),
                          Text('Select your preferred unit',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.dividerColor),
              _UnitOption(
                label: 'Kilometers / km/h',
                subtitle: 'Metric system',
                value: AppConstants.unitsKm,
                groupValue: settings.units,
                onChanged: (v) => settings.setUnits(v!),
              ),
              Divider(height: 1, color: theme.dividerColor),
              _UnitOption(
                label: 'Miles / mph',
                subtitle: 'Imperial system',
                value: AppConstants.unitsMiles,
                groupValue: settings.units,
                onChanged: (v) => settings.setUnits(v!),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── VOICE COACH DETAILS ───────────────────────────────────
          if (settings.voiceEnabled) ...[
            _SectionHeader('VOICE COACH ANNOUNCEMENTS'),
            const SizedBox(height: 10),
            _SettingsCard(
              children: [
                _VoiceAnnouncementTile(
                    icon: Icons.play_circle_outline_rounded,
                    label: 'Run Started',
                    detail: 'When you start a run'),
                Divider(height: 1, color: theme.dividerColor),
                _VoiceAnnouncementTile(
                    icon: Icons.timelapse_rounded,
                    label: 'Halfway Remaining',
                    detail: 'At the midpoint of your target distance'),
                Divider(height: 1, color: theme.dividerColor),
                _VoiceAnnouncementTile(
                    icon: Icons.timer_outlined,
                    label: '30 Seconds Remaining',
                    detail: 'When 30 seconds are left'),
                Divider(height: 1, color: theme.dividerColor),
                _VoiceAnnouncementTile(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Run Completed',
                    detail: 'When your run finishes'),
              ],
            ),
            const SizedBox(height: 22),
          ],

          // ── APP INFO ─────────────────────────────────────────────
          _SectionHeader('APP INFO'),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.info_outline_rounded,
                          color: AppTheme.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppConstants.appName,
                              style: theme.textTheme.bodyLarge),
                          Text(
                              'Version ${AppConstants.appVersion}',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Choose Theme',
                    style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 12),
                _ThemeOption(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Light Mode',
                  selected: settings.themeMode == ThemeMode.light,
                  onTap: () {
                    settings.setThemeMode(ThemeMode.light);
                    Navigator.pop(ctx);
                  },
                ),
                _ThemeOption(
                  icon: Icons.nights_stay_outlined,
                  label: 'Dark Mode',
                  selected: settings.themeMode == ThemeMode.dark,
                  onTap: () {
                    settings.setThemeMode(ThemeMode.dark);
                    Navigator.pop(ctx);
                  },
                ),
                _ThemeOption(
                  icon: Icons.brightness_auto_outlined,
                  label: 'System Default',
                  selected: settings.themeMode == ThemeMode.system,
                  onTap: () {
                    settings.setThemeMode(ThemeMode.system);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(letterSpacing: 1.5),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: theme.textTheme.bodyLarge),
            ),
            if (trailing != null) trailing!,
            const SizedBox(width: 4),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded,
                  color: theme.textTheme.bodySmall?.color, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyLarge),
                if (subtitle != null)
                  Text(subtitle!, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _UnitOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _UnitOption({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const SizedBox(width: 44),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.bodyLarge),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceAnnouncementTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;

  const _VoiceAnnouncementTile({
    required this.icon,
    required this.label,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                Text(detail, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: AppTheme.successColor, size: 18),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                color: selected
                    ? AppTheme.primaryColor
                    : theme.iconTheme.color,
                size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: selected ? AppTheme.primaryColor : null,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_rounded,
                  color: AppTheme.primaryColor, size: 22),
          ],
        ),
      ),
    );
  }
}
