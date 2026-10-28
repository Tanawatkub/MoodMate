import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app_dependencies.dart';
import 'features/auth/login_screen.dart';
import 'features/home/main_navigation.dart'; // นำเข้า MainNavigation

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MoodMateApp(dependencies: AppDependencies.firebase()));
}

class MoodMateApp extends StatelessWidget {
  final AppDependencies dependencies;

  const MoodMateApp({super.key, required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC48E66),
          surface: const Color(0xFFF6F5EE),
        ),
        useMaterial3: true,
      ),
      home: _AuthGate(dependencies: dependencies),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate({required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  StreamSubscription<String?>? _authSubscription;
  String? _userId;
  bool _isLoading = true;
  bool _hasAuthError = false;

  @override
  void initState() {
    super.initState();
    _userId = widget.dependencies.auth.currentUserId;
    _authSubscription = widget.dependencies.auth.userIdChanges.listen(
      _setUserId,
      onError: (Object error, StackTrace stackTrace) {
        if (!mounted) return;
        setState(() {
          _hasAuthError = true;
          _isLoading = false;
        });
      },
    );
  }

  void _setUserId(String? userId) {
    if (!mounted) return;
    final currentUserId = widget.dependencies.auth.currentUserId;
    final resolvedUserId = userId ?? currentUserId;

    // Avoid returning to the login screen if a stale null event arrives after
    // Firebase has already established the current user.
    if (resolvedUserId == null && _userId != null && currentUserId == _userId) {
      return;
    }

    setState(() {
      _userId = resolvedUserId;
      _hasAuthError = false;
      _isLoading = false;
    });
  }

  void _onLoginSuccess() {
    final userId = widget.dependencies.auth.currentUserId;
    if (userId == null) {
      setState(() {
        _hasAuthError = true;
        _isLoading = false;
      });
      return;
    }
    _setUserId(userId);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F5EE),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFC48E66)),
        ),
      );
    }

    if (_hasAuthError) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F5EE),
        body: Center(
          child: Text('ตรวจสอบสถานะบัญชีไม่สำเร็จ กรุณาปิดแล้วเปิดแอปใหม่'),
        ),
      );
    }

    if (_userId != null) {
      return MainNavigation(dependencies: widget.dependencies);
    }

    return LoginScreen(
      dependencies: widget.dependencies,
      onLoginSuccess: _onLoginSuccess,
    );
  }
}
