import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'model/user_model.dart';
import 'navigation/app_router.dart';
import 'screens/splash_screen.dart';
import 'utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const IronCoreApp());
}

class IronCoreApp extends StatelessWidget {
  const IronCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthUserModel>(
      create: (_) => AuthUserModel(),
      child: MaterialApp(
        title: 'Iron Core',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF060C1D),
          fontFamily: 'Roboto',
          colorScheme: const ColorScheme.dark(
            primary: AppColors.brandBlue,
            surface: AppColors.surface,
          ),
        ),
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const SplashScreen(),
      ),
    );
  }
}
