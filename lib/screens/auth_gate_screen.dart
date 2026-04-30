import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'login_screen.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  static const _maxRestoreWait = Duration(seconds: 3);
  static const _pollInterval = Duration(milliseconds: 150);

  User? _user;
  bool _ready = false;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _bootstrapAuthState();
  }

  Future<void> _bootstrapAuthState() async {
    final auth = FirebaseAuth.instance;

    _user = auth.currentUser;
    if (_user != null) {
      if (!mounted) return;
      setState(() => _ready = true);
      _listenForAuthChanges();
      return;
    }

    final startedAt = DateTime.now();
    while (_user == null &&
        DateTime.now().difference(startedAt) < _maxRestoreWait) {
      await Future<void>.delayed(_pollInterval);
      _user = auth.currentUser;
    }

    if (!mounted) return;
    setState(() => _ready = true);
    _listenForAuthChanges();
  }

  void _listenForAuthChanges() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;
      setState(() => _user = user);
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user != null) {
      return const MainShell();
    }

    return const LoginScreen();
  }
}
