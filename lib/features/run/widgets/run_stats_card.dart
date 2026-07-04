// lib/features/run/widgets/run_stats_card.dart

import 'package:flutter/material.dart';

class RunStatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final bool isPrimary;
  final bool isEstimated;

  const RunStatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.isPrimary = false,
    this.isEstimated = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.2,
              ),
            ),
            if (isEstimated) ...[
              const SizedBox(width: 4),
              Tooltip(
                message: 'Estimated value',
                child: Icon(
                  Icons.info_outline,
                  size: 12,
                  color: theme.textTheme.labelSmall?.color,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: (isPrimary
                        ? theme.textTheme.displaySmall
                        : theme.textTheme.headlineMedium)
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (unit != null)
                TextSpan(
                  text: ' $unit',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class RunStatsGrid extends StatelessWidget {
  final List<Widget> tiles;
  final int crossAxisCount;

  const RunStatsGrid({
    super.key,
    required this.tiles,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 24,
      crossAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: tiles,
    );
  }
}
