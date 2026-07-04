// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../providers/profile_provider.dart';
import '../../about/screens/about_screen.dart';
import '../../settings/screens/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () =>
                setState(() => _isEditing = !_isEditing),
            icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined,
                size: 18),
            label: Text(_isEditing ? 'Cancel' : 'Edit'),
          ),
        ],
      ),
      body: _isEditing
          ? _EditProfileView(
              onSaved: () => setState(() => _isEditing = false),
            )
          : _ViewProfileView(
              onEditTap: () => setState(() => _isEditing = true),
            ),
    );
  }
}

// ─── View Mode ─────────────────────────────────────────────────────────────
class _ViewProfileView extends StatelessWidget {
  final VoidCallback onEditTap;

  const _ViewProfileView({required this.onEditTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<ProfileProvider>().profile;
    final isDark = theme.brightness == Brightness.dark;

    if (!profile.isComplete) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_add_outlined,
                    size: 52, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 24),
              Text('Set Up Your Profile',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'Add your details so RaceForce Pro can calculate accurate calories and track your exam targets.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onEditTap,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('SET UP PROFILE'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayGender =
        profile.gender == 'male' ? 'Male' : 'Female';
    final targetExam =
        AppConstants.examDisplayNames[profile.targetExamId] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        children: [
          // Avatar & name
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0D2152), const Color(0xFF0A3070)]
                    : [AppTheme.primaryColor, AppTheme.primaryLight],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    profile.name.isNotEmpty
                        ? profile.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Rajdhani',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  profile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Rajdhani',
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.military_tech_rounded,
                          color: Colors.amber, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        targetExam,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _SectionLabel('PERSONAL DETAILS'),
          const SizedBox(height: 12),

          _ProfileInfoCard(entries: [
            _InfoEntry(
              label: 'Age',
              value: '${profile.age} years',
              icon: Icons.cake_outlined,
            ),
            _InfoEntry(
              label: 'Gender',
              value: displayGender,
              icon: Icons.person_outline,
            ),
            _InfoEntry(
              label: 'Height',
              value: FormatUtils.formatHeight(profile.heightCm),
              icon: Icons.height_rounded,
            ),
            _InfoEntry(
              label: 'Weight',
              value: FormatUtils.formatWeight(profile.weightKg),
              icon: Icons.monitor_weight_outlined,
            ),
            _InfoEntry(
              label: 'BMI',
              value: profile.bmi.toStringAsFixed(1),
              icon: Icons.favorite_outline_rounded,
            ),
          ]),

          const SizedBox(height: 24),
          _SectionLabel('APP'),
          const SizedBox(height: 12),

          _AppLinkTile(
            icon: Icons.settings_outlined,
            label: 'Settings',
            color: AppTheme.primaryColor,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(height: 8),
          _AppLinkTile(
            icon: Icons.info_outline_rounded,
            label: 'About RaceForce Pro',
            color: const Color(0xFF4A148C),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Edit Mode ─────────────────────────────────────────────────────────────
class _EditProfileView extends StatefulWidget {
  final VoidCallback onSaved;

  const _EditProfileView({required this.onSaved});

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  String _gender = 'male';
  String _targetExamId = AppConstants.examSscGd;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameCtrl = TextEditingController(text: profile.name);
    _ageCtrl = TextEditingController(
        text: profile.age > 0 ? '${profile.age}' : '');
    _heightCtrl = TextEditingController(
        text: profile.heightCm > 0
            ? '${profile.heightCm.toInt()}'
            : '');
    _weightCtrl = TextEditingController(
        text: profile.weightKg > 0
            ? profile.weightKg.toStringAsFixed(1)
            : '');
    _gender = profile.gender;
    _targetExamId = profile.targetExamId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    await context.read<ProfileProvider>().updateProfile(
          name: _nameCtrl.text.trim(),
          age: int.parse(_ageCtrl.text.trim()),
          heightCm: double.parse(_heightCtrl.text.trim()),
          weightKg: double.parse(_weightCtrl.text.trim()),
          gender: _gender,
          targetExamId: _targetExamId,
        );

    if (mounted) {
      setState(() => _saving = false);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel('PERSONAL DETAILS'),
            const SizedBox(height: 14),

            // Name
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),

            // Age
            TextFormField(
              controller: _ageCtrl,
              decoration: const InputDecoration(
                labelText: 'Age (years)',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Age is required';
                final age = int.tryParse(v);
                if (age == null || age < 10 || age > 70) {
                  return 'Enter valid age (10–70)';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Height
            TextFormField(
              controller: _heightCtrl,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                prefixIcon: Icon(Icons.height_rounded),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Height is required';
                final h = double.tryParse(v);
                if (h == null || h < 100 || h > 250) {
                  return 'Enter valid height (100–250 cm)';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Weight
            TextFormField(
              controller: _weightCtrl,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,1}')),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Weight is required';
                final w = double.tryParse(v);
                if (w == null || w < 30 || w > 200) {
                  return 'Enter valid weight (30–200 kg)';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),

            _SectionLabel('GENDER'),
            const SizedBox(height: 12),
            Row(
              children: [
                _GenderOption(
                  label: 'Male',
                  icon: Icons.male_rounded,
                  selected: _gender == 'male',
                  onTap: () => setState(() => _gender = 'male'),
                ),
                const SizedBox(width: 12),
                _GenderOption(
                  label: 'Female',
                  icon: Icons.female_rounded,
                  selected: _gender == 'female',
                  onTap: () => setState(() => _gender = 'female'),
                ),
              ],
            ),

            const SizedBox(height: 22),
            _SectionLabel('TARGET EXAM'),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _targetExamId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  onChanged: (v) {
                    if (v != null) setState(() => _targetExamId = v);
                  },
                  items: AppConstants.examList
                      .map(
                        (id) => DropdownMenuItem(
                          value: id,
                          child: Text(
                            AppConstants.examDisplayNames[id] ?? id,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_saving ? 'Saving…' : 'SAVE PROFILE'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

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

class _InfoEntry {
  final String label;
  final String value;
  final IconData icon;

  _InfoEntry({required this.label, required this.value, required this.icon});
}

class _ProfileInfoCard extends StatelessWidget {
  final List<_InfoEntry> entries;
  const _ProfileInfoCard({required this.entries});

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
        children: entries.asMap().entries.map((e) {
          final isLast = e.key == entries.length - 1;
          final entry = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(entry.icon,
                        size: 20, color: AppTheme.primaryColor),
                    const SizedBox(width: 14),
                    Text(entry.label,
                        style: theme.textTheme.bodyMedium),
                    const Spacer(),
                    Text(entry.value,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
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

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primaryColor.withOpacity(0.12)
                : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppTheme.primaryColor : theme.dividerColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected
                      ? AppTheme.primaryColor
                      : theme.iconTheme.color,
                  size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppTheme.primaryColor
                      : theme.textTheme.bodyMedium?.color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppLinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AppLinkTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label, style: theme.textTheme.bodyLarge),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: theme.textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }
}
