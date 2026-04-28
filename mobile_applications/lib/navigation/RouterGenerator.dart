import 'package:flutter/material.dart';
import '../navigation/AppRoutes.dart';
import '../screens/home.dart';
import '../screens/details.dart';
import '../screens/favorites.dart';
import '../screens/signup.dart';
import '../screens/login.dart';
import '../model/Item.dart';

class RouterGenerator {
  static Route generateRoute(RouteSettings settings) {
    final arguments = settings.arguments;

    switch (settings.name) {
      case AppRoutes.homeScreen:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case AppRoutes.detailScreen:
        final item = arguments as Item;
        return MaterialPageRoute(
          builder: (_) => DetailsScreen(item: item),
        );

      case AppRoutes.favoritesScreen:
        return MaterialPageRoute(
          builder: (_) => const FavoritesScreen(),
        );

      case AppRoutes.signupScreen:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case AppRoutes.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('No Route Found')),
          ),
        );
    }
  }
}

