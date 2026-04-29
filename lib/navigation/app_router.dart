import 'package:flutter/material.dart';

import '../screens/active_workout_screen.dart';
import '../screens/auth_gate_screen.dart';
import '../screens/home_screen.dart';
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
  static const String workout = '/workout';
  static const String profile = '/profile';
  static const String activeWorkout = '/active-workout';

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
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case workout:
        return MaterialPageRoute(builder: (_) => const WorkoutScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case activeWorkout:
        return MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
