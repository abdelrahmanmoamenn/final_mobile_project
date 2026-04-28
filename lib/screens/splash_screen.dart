import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../navigation/app_router.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _splashDelay = Duration(milliseconds: 2500);

  @override
  void initState() {
    super.initState();
    _routeAfterDelay();
  }

  Future<void> _routeAfterDelay() async {
    await Future<void>.delayed(_splashDelay);
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    final route = user == null ? AppRouter.login : AppRouter.home;

    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A132B),
                  Color(0xFF070E21),
                  Color(0xFF040916),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.2, sigmaY: 3.2),
              child: const SizedBox.shrink(),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, 0.25),
                  radius: 1.2,
                  colors: [
                    AppColors.background.withValues(alpha: 0.2),
                    AppColors.background.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              child: Column(
                children: [
                  const Spacer(flex: 5),
                  Container(
                    width: 168,
                    height: 168,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.card.withValues(alpha: 0.42),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.09),
                        width: 1.2,
                      ),
                    ),
                    child: const Center(
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Icon(
                          Icons.fitness_center,
                          size: 56,
                          color: Color(0xFFAFC7FF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  const Text(
                    'IRON_CORE',
                    style: TextStyle(
                      fontSize: 66,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Sculpt Your Best Self',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(flex: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 14,
                      value: 0.72,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.brandBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'INITIALIZING PROTOCOL…',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(flex: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
