// lib/features/standards/screens/standards_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/models/standard_model.dart';
import '../../../data/repositories/standards_repository.dart';
import '../../home/widgets/loading_widget.dart';

class StandardsScreen extends StatefulWidget {
  const StandardsScreen({super.key});

  @override
  State<StandardsScreen> createState() => _StandardsScreenState();
}

class _StandardsScreenState extends State<StandardsScreen>
    with SingleTickerProviderStateMixin {
  final StandardsRepository _repo = StandardsRepository();
  List<ExamStandard> _standards = [];
  bool _loading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStandards();
  }

  Future<void> _loadStandards() async {
    final standards = await _repo.getAllStandards();
    if (mounted) {
      setState(() {
        _standards = standards;
        _loading = false;
      });
    }
  }

  Color _examColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Running Standards'),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const LoadingWidget(message: 'Loading standards…')
          : _standards.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.military_tech_outlined,
                  title: 'No Standards Found',
                  message: 'Standards data could not be loaded.',
                )
              : Column(
                  children: [
                    // Exam selector
                    SizedBox(
                      height: 56,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        scrollDirection: Axis.horizontal,
                        itemCount: _standards.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final s = _standards[index];
                          final isSelected = index == _selectedIndex;
                          final color = _examColor(s.colorHex);
                          return ChoiceChip(
                            label: Text(s.name),
                            selected: isSelected,
                            onSelected: (_) =>
                                setState(() => _selectedIndex = index),
                            selectedColor: color.withOpacity(0.18),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? color
                                  : theme.textTheme.bodyMedium?.color,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? color
                                  : theme.dividerColor,
                            ),
                            showCheckmark: false,
                          );
                        },
                      ),
                    ),

                    Expanded(
                      child: _standards.isEmpty
                          ? const SizedBox()
                          : _ExamDetailView(
                              standard: _standards[_selectedIndex],
                              color: _examColor(
                                  _standards[_selectedIndex].colorHex),
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _ExamDetailView extends StatefulWidget {
  final ExamStandard standard;
  final Color color;

  const _ExamDetailView({required this.standard, required this.color});

  @override
  State<_ExamDetailView> createState() => _ExamDetailViewState();
}

class _ExamDetailViewState extends State<_ExamDetailView> {
  String _selectedGender = 'male';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maleCategories = widget.standard.categories
        .where((c) => c.gender == 'male')
        .toList();
    final femaleCategories = widget.standard.categories
        .where((c) => c.gender == 'female')
        .toList();
    final hasFemaleCat = femaleCategories.isNotEmpty;

    final categories = _selectedGender == 'male'
        ? maleCategories
        : femaleCategories;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exam header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: widget.color.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.military_tech_rounded,
                          color: widget.color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.standard.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: widget.color)),
                          Text(widget.standard.fullName,
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Gender toggle
          if (hasFemaleCat)
            Row(
              children: [
                _GenderChip(
                  label: 'Male',
                  icon: Icons.male_rounded,
                  selected: _selectedGender == 'male',
                  color: widget.color,
                  onTap: () =>
                      setState(() => _selectedGender = 'male'),
                ),
                const SizedBox(width: 10),
                _GenderChip(
                  label: 'Female',
                  icon: Icons.female_rounded,
                  selected: _selectedGender == 'female',
                  color: widget.color,
                  onTap: () =>
                      setState(() => _selectedGender = 'female'),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Events
          if (categories.isEmpty)
            Center(
              child: Text(
                'No data available for this category.',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            ...categories.expand((cat) {
              return cat.events.map((event) {
                return _EventCard(
                  event: event,
                  color: widget.color,
                );
              });
            }).toList(),

          // Additional events
          if (widget.standard.additionalEvents.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('ADDITIONAL PHYSICAL STANDARDS',
                style: theme.textTheme.labelMedium
                    ?.copyWith(letterSpacing: 1.3)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: widget.standard.additionalEvents
                    .where((e) => e.gender == _selectedGender)
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(Icons.fitness_center_rounded,
                                size: 16, color: widget.color),
                            const SizedBox(width: 10),
                            Text(e.name,
                                style: theme.textTheme.bodyMedium),
                            const Spacer(),
                            Text(
                              e.standard,
                              style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: widget.color),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],

          // Additional info
          if (widget.standard.additionalInfo != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.warningColor.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppTheme.warningColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.standard.additionalInfo!,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.warningColor),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Standards shown are for reference. Always verify with the official notification before your exam.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : theme.dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18, color: selected ? color : theme.iconTheme.color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : theme.textTheme.bodyMedium?.color,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final StandardEvent event;
  final Color color;

  const _EventCard({required this.event, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.directions_run_rounded, color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    event.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700, color: color),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${event.distanceMeters}m',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Criteria table header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Category',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(letterSpacing: 1.0)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Time',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(letterSpacing: 1.0),
                      textAlign: TextAlign.center),
                ),
                if (event.qualifyingCriteria.any((c) => c.marks > 0))
                  Expanded(
                    flex: 1,
                    child: Text('Marks',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(letterSpacing: 1.0),
                        textAlign: TextAlign.center),
                  ),
              ],
            ),
          ),

          Divider(height: 1, color: theme.dividerColor),

          ...event.qualifyingCriteria.asMap().entries.map((entry) {
            final index = entry.key;
            final c = entry.value;
            final isLast = index == event.qualifyingCriteria.length - 1;
            final hasMarks = event.qualifyingCriteria.any((c) => c.marks > 0);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.category,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600)),
                            if (c.note.isNotEmpty)
                              Text(c.note,
                                  style: theme.textTheme.labelSmall
                                      ?.copyWith(color: color)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          c.timeDisplay,
                          style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700, color: color),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (hasMarks)
                        Expanded(
                          flex: 1,
                          child: Text(
                            c.marks > 0 ? '${c.marks}' : '-',
                            style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isLast) Divider(height: 1, color: theme.dividerColor),
              ],
            );
          }).toList(),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
