import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../screens/home_screen.dart';
import '../screens/workout_screen.dart';
import '../screens/active_workout_screen.dart';
import '../screens/profile_screen.dart';
import '../utils/app_theme.dart';

class HomePreview extends StatelessWidget {
  const HomePreview({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: AppTheme.darkTheme, home: const HomeScreen());
  }
}

class WorkoutPreview extends StatelessWidget {
  const WorkoutPreview({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: AppTheme.darkTheme, home: const WorkoutScreen());
  }
}

class ActiveWorkoutPreview extends StatelessWidget {
  const ActiveWorkoutPreview({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: ActiveWorkoutScreen(workoutPlan: SampleData.legsWorkout),
    );
  }
}

class ProfilePreview extends StatelessWidget {
  const ProfilePreview({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: AppTheme.darkTheme, home: const ProfileScreen());
  }
}
