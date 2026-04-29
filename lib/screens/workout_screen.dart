import 'package:flutter/material.dart';
import '../navigation/app_router.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/widgets.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CoachAIAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Focus",
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'Thursday, Oct 12 • Week 4',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Workout Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _WorkoutTab(label: 'Push', isActive: true),
                  const SizedBox(width: 12),
                  _WorkoutTab(label: 'Pull', isActive: false),
                  const SizedBox(width: 12),
                  _WorkoutTab(label: 'Legs', isActive: false),
                  const SizedBox(width: 12),
                  _WorkoutTab(label: 'Custom', isActive: false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Summary Stats
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text('Est. Burn', style: AppTextStyles.label),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '450',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'kcal',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text('Duration', style: AppTextStyles.label),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '65',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'min',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Exercises List Header
            const SectionHeader(
              title: 'Exercises (6)',
              icon: Icons.list,
              actionLabel: 'Edit',
            ),
            const SizedBox(height: 16),

            // Exercises List
            const ExerciseListTile(
              name: 'Barbell Bench Press',
              muscleGroup: 'Chest',
              sets: 4,
              reps: 10,
              restSeconds: 90,
            ),
            const SizedBox(height: 12),
            const ExerciseListTile(
              name: 'Incline DB Press',
              muscleGroup: 'Chest',
              sets: 3,
              reps: 12,
              restSeconds: 60,
            ),
            const SizedBox(height: 12),
            const ExerciseListTile(
              name: 'Tricep Pushdowns',
              muscleGroup: 'Triceps',
              sets: 3,
              reps: 15,
              restSeconds: 45,
            ),
            const SizedBox(height: 80), // Space for bottom button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        color: AppColors.background,
        child: PrimaryButton(
          label: 'Start Workout',
          leadingIcon: Icons.bolt,
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.activeWorkout);
          },
        ),
      ),
    );
  }
}

class _WorkoutTab extends StatelessWidget {
  final String label;
  final bool isActive;

  const _WorkoutTab({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.tertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}
