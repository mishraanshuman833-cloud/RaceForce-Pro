// lib/features/about/screens/about_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),

            // App logo
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E88E5), Color(0xFFFF6D00)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.35),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_run_rounded,
                size: 58,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFFFF6D00)],
              ).createShader(bounds),
              child: Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Rajdhani',
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Version ${AppConstants.appVersion}',
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 10),

            Text(
              AppConstants.appDescription,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Developer Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF0D2152), const Color(0xFF0A3070)]
                      : [AppTheme.primaryColor, AppTheme.primaryLight],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Text(
                      'AM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Rajdhani',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Developed by',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.developerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Rajdhani',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppConstants.developerEmail,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Feature list
            _SectionLabel('WHAT\'S INSIDE V1.0'),
            const SizedBox(height: 14),

            _FeatureCard(
              features: const [
                _Feature(
                    icon: Icons.gps_fixed_rounded,
                    label: 'Live GPS Tracking',
                    detail: 'Real-time route and distance'),
                _Feature(
                    icon: Icons.timer_outlined,
                    label: 'Live Run Metrics',
                    detail: 'Timer, speed, pace, calories, steps'),
                _Feature(
                    icon: Icons.record_voice_over_outlined,
                    label: 'Voice Coach',
                    detail: 'Smart audio alerts during your run'),
                _Feature(
                    icon: Icons.military_tech_outlined,
                    label: 'Official Standards',
                    detail: 'SSC GD, UP Police, Delhi Police, CISF, CRPF'),
                _Feature(
                    icon: Icons.history_rounded,
                    label: 'Run History',
                    detail: 'Every run saved with full stats'),
                _Feature(
                    icon: Icons.brightness_6_outlined,
                    label: 'Light & Dark Mode',
                    detail: 'Premium Material Design 3 UI'),
              ],
            ),

            const SizedBox(height: 28),

            _SectionLabel('STANDARDS DATA'),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.warningColor.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppTheme.warningColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Running standards shown are based on official exam notifications. Always verify with the latest official notification before your exam. Standards may change.',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.warningColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            _SectionLabel('CALORIES DISCLAIMER'),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Text(
                'Calorie values shown in the app are ESTIMATES calculated using the MET (Metabolic Equivalent of Task) formula based on your weight and run speed. Actual calories burned vary based on individual physiology, terrain, and other factors.',
                style: theme.textTheme.bodySmall,
              ),
            ),

            const SizedBox(height: 28),

            Text(
              '© 2024 ${AppConstants.developerName}. All rights reserved.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Made with ❤️ for Indian exam aspirants.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(letterSpacing: 1.5),
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String label;
  final String detail;

  const _Feature(
      {required this.icon, required this.label, required this.detail});
}

class _FeatureCard extends StatelessWidget {
  final List<_Feature> features;
  const _FeatureCard({required this.features});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: features.asMap().entries.map((e) {
          final isLast = e.key == features.length - 1;
          final f = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(f.icon,
                          color: AppTheme.primaryColor, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.label,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600)),
                          Text(f.detail,
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded,
                        color: AppTheme.successColor, size: 18),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 1, color: theme.dividerColor),
            ],
          );
        }).toList(),
      ),
    );
  }
}
