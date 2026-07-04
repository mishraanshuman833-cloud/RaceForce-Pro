// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/repositories/run_repository.dart';
import '../../../data/repositories/standards_repository.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../run/screens/run_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../standards/screens/standards_screen.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/premium_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardTab(),
    StandardsScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  final RunRepository _runRepository = RunRepository();
  final StandardsRepository _standardsRepository = StandardsRepository();

  RunStats _stats = RunStats.empty();
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _statsLoading = true);
    final stats = await _runRepository.getOverallStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _statsLoading = false;
      });
    }
  }

  void _onStartRun(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RunScreen()),
    );
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<ProfileProvider>().profile;
    final settings = context.watch<SettingsProvider>();
    final units = settings.units;
    final isDark = theme.brightness == Brightness.dark;

    final greeting = _getGreeting();
    final displayName = profile.name.isNotEmpty ? profile.name : 'Athlete';
    final targetExam =
        AppConstants.examDisplayNames[profile.targetExamId] ?? 'SSC GD';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              snap: true,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E88E5), Color(0xFFFF6D00)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.directions_run_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppConstants.appName,
                    style: theme.appBarTheme.titleTextStyle,
                  ),
                ],
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Greeting banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
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
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      greeting,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      displayName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Rajdhani',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.military_tech,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      targetExam,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          PremiumButton(
                            label: 'START RUN',
                            icon: Icons.play_arrow_rounded,
                            onPressed: () => _onStartRun(context),
                            width: double.infinity,
                            height: 54,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Overall stats heading
                    Text(
                      'YOUR PROGRESS',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Stats grid
                    _statsLoading
                        ? const SizedBox(
                            height: 180,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.45,
                            children: [
                              DashboardCard(
                                title: 'Total Runs',
                                value: '${_stats.totalRuns}',
                                icon: Icons.flag_rounded,
                                iconColor: AppTheme.primaryColor,
                              ),
                              DashboardCard(
                                title: 'Total Distance',
                                value: units == AppConstants.unitsMiles
                                    ? FormatUtils.formatDistanceMiles(
                                        _stats.totalDistanceMeters)
                                    : FormatUtils.formatDistanceKm(
                                        _stats.totalDistanceMeters),
                                icon: Icons.route_rounded,
                                iconColor: AppTheme.accentColor,
                              ),
                              DashboardCard(
                                title: 'Total Time',
                                value: FormatUtils.formatDurationHuman(
                                    _stats.totalDurationSeconds),
                                icon: Icons.timer_outlined,
                                iconColor: AppTheme.successColor,
                              ),
                              DashboardCard(
                                title: 'Calories Burned',
                                value: '~${_stats.totalCalories.toInt()}',
                                subtitle: 'kcal (estimated)',
                                icon: Icons.local_fire_department_rounded,
                                iconColor: Colors.deepOrange,
                              ),
                            ],
                          ),

                    const SizedBox(height: 28),

                    // Quick links
                    Text(
                      'QUICK ACCESS',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _QuickAccessRow(
                      items: [
                        _QuickItem(
                          icon: Icons.military_tech_outlined,
                          label: 'Standards',
                          color: const Color(0xFF4A148C),
                          onTap: () {},
                        ),
                        _QuickItem(
                          icon: Icons.history,
                          label: 'History',
                          color: AppTheme.primaryColor,
                          onTap: () {},
                        ),
                        _QuickItem(
                          icon: Icons.person_outline,
                          label: 'Profile',
                          color: AppTheme.accentColor,
                          onTap: () {},
                        ),
                        _QuickItem(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          color: AppTheme.successColor,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}

class _QuickItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickAccessRow extends StatelessWidget {
  final List<_QuickItem> items;

  const _QuickAccessRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: item.onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, color: item.color, size: 26),
                      const SizedBox(height: 6),
                      Text(
                        item.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
