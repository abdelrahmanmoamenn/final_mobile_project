import 'package:flutter/material.dart';

import '../main.dart';
import '../model/user_model.dart';
import '../screens/active_workout_screen.dart';
import '../screens/auth_gate_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/workout_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String authGate = '/auth-gate';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String home = '/home';
  static const String mainShell = '/main-shell';
  static const String workout = '/workout';
  static const String activeWorkout = '/active-workout';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case authGate:
        return MaterialPageRoute(builder: (_) => const AuthGateScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case home:
      case mainShell:
        final int index = settings.arguments is int ? settings.arguments as int : 0;
        return MaterialPageRoute(builder: (_) => MainShell(initialIndex: index));
      case workout:
        return MaterialPageRoute(builder: (_) => const WorkoutScreen());
      case activeWorkout:
        final args = settings.arguments as WorkoutPlan?;
        return MaterialPageRoute(
          builder: (_) => ActiveWorkoutScreen(workoutPlan: args ?? SampleData.legsWorkout),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
