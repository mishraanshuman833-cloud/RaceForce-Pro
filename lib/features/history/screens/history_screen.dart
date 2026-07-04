// lib/features/history/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/models/run_model.dart';
import '../../../data/repositories/run_repository.dart';
import '../../../providers/settings_provider.dart';
import '../../home/widgets/loading_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final RunRepository _repo = RunRepository();
  List<RunModel> _runs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRuns();
  }

  Future<void> _loadRuns() async {
    setState(() => _loading = true);
    final runs = await _repo.getAllRuns();
    if (mounted) {
      setState(() {
        _runs = runs;
        _loading = false;
      });
    }
  }

  Future<void> _deleteRun(String id) async {
    await _repo.deleteRun(id);
    _loadRuns();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Run deleted')),
      );
    }
  }

  Future<void> _confirmDelete(RunModel run) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Run?'),
        content: Text(
          'Delete run from ${FormatUtils.formatDateShort(run.date)}? This cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: TextStyle(color: AppTheme.stopRed)),
          ),
        ],
      ),
    );
    if (confirm == true) _deleteRun(run.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Run History'),
        automaticallyImplyLeading: false,
        actions: [
          if (_runs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear all runs',
              onPressed: _confirmClearAll,
            ),
        ],
      ),
      body: _loading
          ? const LoadingWidget(message: 'Loading history…')
          : _runs.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.directions_run_rounded,
                  title: 'No Runs Yet',
                  message:
                      'Complete your first run and it will appear here with full stats.',
                  action: null,
                )
              : RefreshIndicator(
                  onRefresh: _loadRuns,
                  color: theme.colorScheme.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    itemCount: _runs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 2),
                    itemBuilder: (context, index) {
                      final run = _runs[index];
                      return _RunHistoryCard(
                        run: run,
                        onDelete: () => _confirmDelete(run),
                        onTap: () => _openDetail(run),
                      );
                    },
                  ),
                ),
    );
  }

  void _openDetail(RunModel run) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RunDetailScreen(run: run),
      ),
    );
  }

  Future<void> _confirmClearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text(
            'This will permanently delete all saved runs. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear All',
                style: TextStyle(color: AppTheme.stopRed)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _repo.deleteAllRuns();
      _loadRuns();
    }
  }
}

// ─── Run History Card ──────────────────────────────────────────────────────
class _RunHistoryCard extends StatelessWidget {
  final RunModel run;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _RunHistoryCard({
    required this.run,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final units = context.watch<SettingsProvider>().units;

    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.directions_run_rounded,
                    color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FormatUtils.formatDate(run.date),
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      FormatUtils.formatTime(run.date),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MiniStat(
                          icon: Icons.route_rounded,
                          value: units == AppConstants.unitsMiles
                              ? FormatUtils.formatDistanceMiles(
                                  run.distanceMeters)
                              : FormatUtils.formatDistanceKm(
                                  run.distanceMeters),
                        ),
                        const SizedBox(width: 12),
                        _MiniStat(
                          icon: Icons.timer_outlined,
                          value: FormatUtils.formatDuration(
                              run.durationSeconds),
                        ),
                        const SizedBox(width: 12),
                        _MiniStat(
                          icon: Icons.speed_rounded,
                          value: FormatUtils.formatPace(
                              run.avgPaceMps, units),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    color: theme.textTheme.bodySmall?.color,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                        minWidth: 28, minHeight: 28),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MiniStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.primaryColor),
        const SizedBox(width: 3),
        Text(value, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

// ─── Run Detail Screen ─────────────────────────────────────────────────────
class RunDetailScreen extends StatelessWidget {
  final RunModel run;

  const RunDetailScreen({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final units = context.watch<SettingsProvider>().units;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Run Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0D2152), const Color(0xFF0A3070)]
                      : [AppTheme.primaryColor, AppTheme.primaryLight],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.directions_run_rounded,
                      color: Colors.white, size: 36),
                  const SizedBox(height: 10),
                  Text(
                    FormatUtils.formatDate(run.date),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Rajdhani'),
                  ),
                  Text(
                    FormatUtils.formatTime(run.date),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text('STATS',
                style: theme.textTheme.labelMedium
                    ?.copyWith(letterSpacing: 1.5)),
            const SizedBox(height: 12),

            _DetailRow(
              label: 'Distance',
              value: units == AppConstants.unitsMiles
                  ? FormatUtils.formatDistanceMiles(run.distanceMeters)
                  : FormatUtils.formatDistanceKm(run.distanceMeters),
              icon: Icons.route_rounded,
              color: AppTheme.primaryColor,
            ),
            _DetailRow(
              label: 'Duration',
              value: FormatUtils.formatDuration(run.durationSeconds),
              icon: Icons.timer_outlined,
              color: AppTheme.accentColor,
            ),
            _DetailRow(
              label: 'Average Speed',
              value: FormatUtils.formatSpeed(run.avgSpeedMps, units),
              icon: Icons.speed_rounded,
              color: AppTheme.successColor,
            ),
            _DetailRow(
              label: 'Average Pace',
              value: FormatUtils.formatPace(run.avgPaceMps, units),
              icon: Icons.directions_run_rounded,
              color: const Color(0xFF7B1FA2),
            ),
            _DetailRow(
              label: 'Calories (Estimated)',
              value: FormatUtils.formatCalories(run.estimatedCalories),
              icon: Icons.local_fire_department_rounded,
              color: Colors.deepOrange,
              note: 'est.',
            ),
            if (run.steps != null)
              _DetailRow(
                label: 'Steps',
                value: '${run.steps}',
                icon: Icons.directions_walk_rounded,
                color: Colors.teal,
              ),
            if (run.maxSpeedMps > 0)
              _DetailRow(
                label: 'Max Speed',
                value: FormatUtils.formatSpeed(run.maxSpeedMps, units),
                icon: Icons.flash_on_rounded,
                color: Colors.amber,
              ),

            if (run.targetExamId != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                label: 'Target Exam',
                value: AppConstants.examDisplayNames[run.targetExamId] ??
                    run.targetExamId!,
                icon: Icons.military_tech_outlined,
                color: const Color(0xFF1565C0),
              ),
            ],

            if (run.route.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('GPS ROUTE',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.map_outlined,
                        color: AppTheme.primaryColor, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      '${run.route.length} GPS points recorded',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? note;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                if (note != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      note!,
                      style: const TextStyle(
                          fontSize: 9,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
