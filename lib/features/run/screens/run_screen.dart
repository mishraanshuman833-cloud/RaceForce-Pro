// lib/features/run/screens/run_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/models/run_model.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/run_provider.dart';
import '../../../providers/settings_provider.dart';
import '../widgets/run_stats_card.dart';

class RunScreen extends StatefulWidget {
  const RunScreen({super.key});

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> with WidgetsBindingObserver {
  bool _permissionChecked = false;
  bool _permissionGranted = false;
  bool _checkingPermission = true;
  bool _finishConfirmVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
    // Keep screen on while run screen is visible
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permission if user returns from settings
    if (state == AppLifecycleState.resumed && !_permissionGranted) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    setState(() => _checkingPermission = true);
    final status =
        await LocationService.instance.checkAndRequestPermission();
    final granted = status == LocationPermissionStatus.granted;
    if (mounted) {
      setState(() {
        _permissionGranted = granted;
        _permissionChecked = true;
        _checkingPermission = false;
      });
    }
  }

  Future<void> _startRun() async {
    final profile = context.read<ProfileProvider>().profile;
    final runProvider = context.read<RunProvider>();

    runProvider.configure(
      weightKg: profile.weightKg,
      targetExamId: profile.targetExamId,
    );

    await runProvider.startRun();
  }

  Future<void> _onFinishTap() async {
    final runProvider = context.read<RunProvider>();
    if (runProvider.isRunning) {
      await runProvider.pauseRun();
    }
    setState(() => _finishConfirmVisible = true);
  }

  Future<void> _confirmFinish() async {
    final runProvider = context.read<RunProvider>();
    final RunModel run = await runProvider.finishRun();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RunSummaryScreen(run: run),
        ),
      );
    }
  }

  Future<void> _cancelFinish() async {
    setState(() => _finishConfirmVisible = false);
    final runProvider = context.read<RunProvider>();
    if (runProvider.isPaused) {
      await runProvider.resumeRun();
    }
  }

  Future<bool> _onWillPop() async {
    final runProvider = context.read<RunProvider>();
    if (runProvider.isIdle || runProvider.isFinished) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard Run?'),
        content: const Text(
            'Your current run will be lost. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Running'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Discard',
              style: TextStyle(color: AppTheme.stopRed),
            ),
          ),
        ],
      ),
    );

    if (shouldDiscard == true) {
      await context.read<RunProvider>().discardRun();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _checkingPermission
            ? const _LoadingPermission()
            : !_permissionGranted
                ? _PermissionDeniedView(onRetry: _checkPermission)
                : Stack(
                    children: [
                      const _RunTrackingView(),
                      if (_finishConfirmVisible)
                        _FinishConfirmOverlay(
                          onConfirm: _confirmFinish,
                          onCancel: _cancelFinish,
                        ),
                    ],
                  ),
        floatingActionButton: _permissionGranted && !_checkingPermission
            ? _buildFAB()
            : null,
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildFAB() {
    return Consumer<RunProvider>(builder: (context, runProvider, _) {
      if (runProvider.isIdle) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: _startRun,
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              label: const Text('START RUN',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.runningGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        );
      }

      if (runProvider.isFinished) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pause / Resume
            FloatingActionButton(
              heroTag: 'pause_resume',
              onPressed: () async {
                if (runProvider.isRunning) {
                  await runProvider.pauseRun();
                } else {
                  await runProvider.resumeRun();
                }
              },
              backgroundColor: runProvider.isRunning
                  ? AppTheme.pausedAmber
                  : AppTheme.runningGreen,
              foregroundColor: Colors.black,
              child: Icon(
                runProvider.isRunning
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 32,
              ),
            ),
            const SizedBox(width: 24),
            // Finish
            FloatingActionButton.extended(
              heroTag: 'finish',
              onPressed: _finishConfirmVisible ? null : _onFinishTap,
              backgroundColor: AppTheme.stopRed,
              foregroundColor: Colors.white,
              label: const Text('FINISH',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, letterSpacing: 1.0)),
              icon: const Icon(Icons.stop_rounded),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Loading Permission ────────────────────────────────────────────────────
class _LoadingPermission extends StatelessWidget {
  const _LoadingPermission();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking GPS permissions…'),
          ],
        ),
      ),
    );
  }
}

// ─── Permission Denied ─────────────────────────────────────────────────────
class _PermissionDeniedView extends StatelessWidget {
  final VoidCallback onRetry;

  const _PermissionDeniedView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('GPS Required')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_off_rounded,
                  size: 60, color: AppTheme.errorColor),
            ),
            const SizedBox(height: 28),
            Text('Location Permission Required',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'RaceForce Pro needs location access to track your run distance, speed and GPS route. Please grant permission to continue.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.location_on_rounded),
                label: const Text('Grant Permission'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await LocationService.instance.openAppSettings();
                },
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Open App Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Main Tracking View ────────────────────────────────────────────────────
class _RunTrackingView extends StatelessWidget {
  const _RunTrackingView();

  @override
  Widget build(BuildContext context) {
    return Consumer2<RunProvider, SettingsProvider>(
      builder: (context, run, settings, _) {
        final theme = Theme.of(context);
        final units = settings.units;
        final isDark = theme.brightness == Brightness.dark;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Text(
                run.isIdle
                    ? 'Ready to Run'
                    : run.isRunning
                        ? '● RUNNING'
                        : run.isPaused
                            ? '⏸ PAUSED'
                            : 'FINISHED',
                style: theme.appBarTheme.titleTextStyle?.copyWith(
                  color: run.isRunning
                      ? AppTheme.runningGreen
                      : run.isPaused
                          ? AppTheme.pausedAmber
                          : null,
                ),
              ),
              leading: const BackButton(),
              actions: [
                if (!run.isIdle)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (run.isRunning
                                  ? AppTheme.runningGreen
                                  : AppTheme.pausedAmber)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          run.isRunning ? 'LIVE' : 'PAUSED',
                          style: TextStyle(
                            color: run.isRunning
                                ? AppTheme.runningGreen
                                : AppTheme.pausedAmber,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Timer
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  const Color(0xFF0D2152),
                                  const Color(0xFF0A3070),
                                ]
                              : [
                                  AppTheme.primaryColor,
                                  AppTheme.primaryLight,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(24),
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
                          Text(
                            'ELAPSED TIME',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            FormatUtils.formatDuration(run.elapsedSeconds),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 62,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Rajdhani',
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Distance (hero stat)
                    _StatCard(
                      child: RunStatTile(
                        label: 'Distance',
                        value: _distanceValue(run.totalDistanceMeters, units),
                        unit: units == AppConstants.unitsMiles ? 'mi' : 'km',
                        isPrimary: true,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Speed row
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            child: RunStatTile(
                              label: 'Speed',
                              value: _speedValue(run.currentSpeedMps, units),
                              unit: units == AppConstants.unitsMiles
                                  ? 'mph'
                                  : 'km/h',
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _StatCard(
                            child: RunStatTile(
                              label: 'Avg Speed',
                              value: _speedValue(run.averageSpeedMps, units),
                              unit: units == AppConstants.unitsMiles
                                  ? 'mph'
                                  : 'km/h',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Pace row
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            child: RunStatTile(
                              label: 'Current Pace',
                              value: _currentPaceDisplay(
                                  run.currentPaceMps, units),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _StatCard(
                            child: RunStatTile(
                              label: 'Avg Pace',
                              value: _currentPaceDisplay(
                                  run.averagePaceMps, units),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Calories + Steps row
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            child: RunStatTile(
                              label: 'Calories (Est.)',
                              value:
                                  run.estimatedCalories.toInt().toString(),
                              unit: 'kcal',
                              isEstimated: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _StatCard(
                            child: run.stepsSupported
                                ? RunStatTile(
                                    label: 'Steps',
                                    value: FormatUtils.formatSteps(run.steps),
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.directions_walk_rounded,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color,
                                        size: 22,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Steps',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Not supported',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(fontSize: 10),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),

                    if (run.isIdle) ...[
                      const SizedBox(height: 28),
                      _IdleHint(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _distanceValue(double meters, String units) {
    if (units == AppConstants.unitsMiles) {
      return (meters / 1000.0 * 0.621371).toStringAsFixed(2);
    }
    return (meters / 1000.0).toStringAsFixed(2);
  }

  String _speedValue(double mps, String units) {
    if (mps <= 0) return '0.0';
    if (units == AppConstants.unitsMiles) {
      return (mps * 2.23694).toStringAsFixed(1);
    }
    return (mps * 3.6).toStringAsFixed(1);
  }

  String _currentPaceDisplay(double mps, String units) {
    if (mps <= 0) return '--:--';
    if (units == AppConstants.unitsMiles) {
      final spm = 1609.34 / mps;
      return '${(spm ~/ 60).toString().padLeft(2, '0')}:${(spm % 60).toInt().toString().padLeft(2, '0')}';
    }
    final spk = 1000.0 / mps;
    return '${(spk ~/ 60).toString().padLeft(2, '0')}:${(spk % 60).toInt().toString().padLeft(2, '0')}';
  }
}

class _StatCard extends StatelessWidget {
  final Widget child;

  const _StatCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: child,
    );
  }
}

class _IdleHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Press START RUN below to begin GPS tracking. All metrics update live.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Finish Confirm Overlay ────────────────────────────────────────────────
class _FinishConfirmOverlay extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _FinishConfirmOverlay(
      {required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: Colors.black54,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.stopRed.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.stop_circle_outlined,
                      color: AppTheme.stopRed, size: 40),
                ),
                const SizedBox(height: 20),
                Text('Finish Run?', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 10),
                Text(
                  'Your run will be saved to history.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        child: const Text('Keep Going'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.stopRed,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Finish'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Run Summary Screen ────────────────────────────────────────────────────
class RunSummaryScreen extends StatelessWidget {
  final RunModel run;

  const RunSummaryScreen({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final units = context.watch<SettingsProvider>().units;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            floating: true,
            title: const Text('Run Complete!'),
            actions: [
              TextButton.icon(
                onPressed: () {
                  context.read<RunProvider>().resetToIdle();
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                icon: const Icon(Icons.home_outlined),
                label: const Text('Home'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  // Trophy banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF0D2152), const Color(0xFF0A3070)]
                            : [AppTheme.primaryColor, AppTheme.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.emoji_events_rounded,
                            color: Colors.amber, size: 52),
                        const SizedBox(height: 10),
                        const Text(
                          'GREAT RUN!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            fontFamily: 'Rajdhani',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FormatUtils.formatDateTime(run.date),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats
                  _SummaryRow(
                    label: 'Distance',
                    value: units == AppConstants.unitsMiles
                        ? FormatUtils.formatDistanceMiles(run.distanceMeters)
                        : FormatUtils.formatDistanceKm(run.distanceMeters),
                    icon: Icons.route_rounded,
                    iconColor: AppTheme.primaryColor,
                  ),
                  _SummaryRow(
                    label: 'Duration',
                    value: FormatUtils.formatDuration(run.durationSeconds),
                    icon: Icons.timer_outlined,
                    iconColor: AppTheme.accentColor,
                  ),
                  _SummaryRow(
                    label: 'Avg Speed',
                    value: FormatUtils.formatSpeed(run.avgSpeedMps, units),
                    icon: Icons.speed_rounded,
                    iconColor: AppTheme.successColor,
                  ),
                  _SummaryRow(
                    label: 'Avg Pace',
                    value: FormatUtils.formatPace(run.avgPaceMps, units),
                    icon: Icons.directions_run_rounded,
                    iconColor: const Color(0xFF7B1FA2),
                  ),
                  _SummaryRow(
                    label: 'Calories (Estimated)',
                    value: FormatUtils.formatCalories(run.estimatedCalories),
                    icon: Icons.local_fire_department_rounded,
                    iconColor: Colors.deepOrange,
                    note: 'est.',
                  ),
                  if (run.steps != null)
                    _SummaryRow(
                      label: 'Steps',
                      value: '${run.steps}',
                      icon: Icons.directions_walk_rounded,
                      iconColor: Colors.teal,
                    ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<RunProvider>().resetToIdle();
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('BACK TO HOME'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? note;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Text(label, style: theme.textTheme.bodyMedium),
          if (note != null) ...[
            const SizedBox(width: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                note!,
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
