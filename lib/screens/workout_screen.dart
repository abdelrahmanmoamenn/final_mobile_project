import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../navigation/app_router.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/widgets.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  WorkoutType _selectedType = WorkoutType.push;

  String get _dateLabel {
    final now = DateTime.now();
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final week = ((now.day - 1) ~/ 7) + 1;
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day} • Week $week';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const FormAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's Focus", style: AppTextStyles.headline1),
                Text(
                  _dateLabel,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Workout Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _WorkoutTab(
                        label: 'Push',
                        isActive: _selectedType == WorkoutType.push,
                        onTap: () =>
                            setState(() => _selectedType = WorkoutType.push),
                      ),
                      const SizedBox(width: 12),
                      _WorkoutTab(
                        label: 'Pull',
                        isActive: _selectedType == WorkoutType.pull,
                        onTap: () =>
                            setState(() => _selectedType = WorkoutType.pull),
                      ),
                      const SizedBox(width: 12),
                      _WorkoutTab(
                        label: 'Legs',
                        isActive: _selectedType == WorkoutType.legs,
                        onTap: () =>
                            setState(() => _selectedType = WorkoutType.legs),
                      ),
                      const SizedBox(width: 12),
                      _WorkoutTab(
                        label: 'Custom',
                        isActive: _selectedType == WorkoutType.custom,
                        onTap: () =>
                            setState(() => _selectedType = WorkoutType.custom),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Summary Stats
                _buildSummaryStats(),
                const SizedBox(height: 32),

                // Exercises List Header
                SectionHeader(
                  title: 'Exercises (${_currentWorkout.exercises.length})',
                  icon: Icons.list,
                ),
                const SizedBox(height: 16),

                // Exercises List
                ..._currentWorkout.exercises.map(
                  (exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ExerciseListTile(
                      name: exercise.name,
                      muscleGroup: exercise.muscleGroup,
                      sets: exercise.sets,
                      reps: exercise.reps,
                      restSeconds: exercise.restSeconds,
                    ),
                  ),
                ),
                const SizedBox(height: 120), // Space for bottom button
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.cardBorder, width: 0.5),
                ),
              ),
              child: PrimaryButton(
                label: 'Start Workout',
                leadingIcon: Icons.bolt,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.activeWorkout,
                    arguments: _currentWorkout,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  WorkoutPlan get _currentWorkout => SampleData.workoutsByType[_selectedType]!;

  Widget _buildSummaryStats() {
    return Row(
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _currentWorkout.estimatedBurnKcal.toString(),
                      style: AppTextStyles.headline3,
                    ),
                    const SizedBox(width: 4),
                    const Text('kcal', style: AppTextStyles.label),
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
                    Icon(Icons.timer, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text('Duration', style: AppTextStyles.label),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _currentWorkout.estimatedDurationMin.toString(),
                      style: AppTextStyles.headline3,
                    ),
                    const SizedBox(width: 4),
                    const Text('min', style: AppTextStyles.label),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkoutTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _WorkoutTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
