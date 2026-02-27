import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data.dart';
import 'duo_theme.dart';

// ═══════════════════════════════════════════════════
//  PROFILE SCREEN
// ═══════════════════════════════════════════════════

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final name = state.userName.isEmpty ? 'Learner' : state.userName;
        final initials = name.isNotEmpty ? name[0].toUpperCase() : 'L';

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── HEADER ──
                  const Center(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Duo.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── AVATAR & NAME ──
                  Row(
                    children: [
                      // Avatar circle
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Duo.green,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Duo.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).textTheme.bodyLarge?.color ?? Duo.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'ISL Learner',
                              style: TextStyle(
                                fontSize: 14,
                                color: Duo.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Edit button
                      GestureDetector(
                        onTap: () => _showEditNameDialog(context, state),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: Duo.border, width: 2),
                            borderRadius: BorderRadius.circular(Duo.r12),
                          ),
                          child: const Icon(Icons.edit,
                              color: Duo.blue, size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),
                  const Divider(color: Duo.border, thickness: 2),
                  const SizedBox(height: 20),

                  // ── STATISTICS ──
                  Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? Duo.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.local_fire_department,
                          iconColor: Duo.orange,
                          value: '${state.streak}',
                          label: 'Day streak',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.bolt,
                          iconColor: Duo.gold,
                          value: '${state.totalXP}',
                          label: 'Total XP',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.school,
                          iconColor: Duo.blue,
                          value: '${state.lessonsCompleted}',
                          label: 'Lessons',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.search,
                          iconColor: Duo.purple,
                          value: '${state.practiceCompleted}',
                          label: 'Practice',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),
                  const Divider(color: Duo.border, thickness: 2),
                  const SizedBox(height: 20),

                  // ── ACHIEVEMENTS ──
                  Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? Duo.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...List.generate(achievements.length, (i) {
                    final a = achievements[i];
                    final progress = state.getAchievementProgress(i);
                    final completed = progress >= a.target;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Duo.r16),
                        border: Border.all(
                          color: completed ? a.color : Duo.border,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Badge icon
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: completed
                                  ? a.color
                                  : Duo.disabled,
                              borderRadius: BorderRadius.circular(Duo.r12),
                            ),
                            child: Icon(
                              a.icon,
                              color: completed
                                  ? Duo.white
                                  : Duo.textSecondary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Text & progress
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).textTheme.bodyLarge?.color ?? Duo.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  a.description,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Duo.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ChunkyProgressBar(
                                  value: progress / a.target,
                                  color: a.color,
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Progress text
                          Text(
                            '$progress/${a.target}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: completed ? a.color : Duo.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 28),
                  const Divider(color: Duo.border, thickness: 2),
                  const SizedBox(height: 20),

                  // ── SETTINGS ──
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? Duo.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dark Mode Switch
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Duo.r16),
                      border: Border.all(color: Duo.border, width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.dark_mode, color: Duo.purple, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Dark Mode',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).textTheme.bodyLarge?.color ?? Duo.textPrimary,
                            ),
                          ),
                        ),
                        Switch(
                          value: state.isDarkMode,
                          onChanged: (_) => state.toggleDarkMode(),
                          activeColor: Duo.green,
                        ),
                      ],
                    ),
                  ),

                  // Show words switch
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Duo.r16),
                      border: Border.all(color: Duo.border, width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.text_fields,
                            color: Duo.blue, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Show words in lessons',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Duo.textPrimary,
                                ),
                              ),
                              Text(
                                'Display object name during Level 1',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Duo.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: state.showWordsInLesson,
                          onChanged: (_) => state.toggleShowWords(),
                          activeColor: Duo.green,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context, AppState state) {
    final controller = TextEditingController(text: state.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(Duo.r20)),
        title: const Text('Edit Name',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Duo.r12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Duo.r12),
              borderSide: const BorderSide(color: Duo.green, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Duo.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              state.setUserName(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save',
                style: TextStyle(
                    color: Duo.green, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── STAT CARD WIDGET ──

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Duo.r16),
        border: Border.all(color: Duo.border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Duo.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Duo.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
