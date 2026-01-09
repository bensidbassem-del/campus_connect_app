import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../screens/login_screen.dart';

import '../../actors/admin/screens/admin_home_screen.dart';
import '../../actors/teacher/screens/teacher_home_screen.dart';
import '../../actors/student/screens/student_home_screen.dart';

/// AuthGate - Decides where to navigate based on authentication state
/// 
/// Flow:
/// 1. Check if JWT token exists in storage
/// 2. If no token → LoginScreen
/// 3. If token exists → Check user role and navigate accordingly:
///    - ADMIN → AdminHomeScreen
///    - TEACHER → TeacherHomeScreen
///    - STUDENT → StudentHomeScreen




class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  /// Check if user is logged in and get their role
  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userString = prefs.getString('user');

      if (token != null && userString != null) {
        final user = jsonDecode(userString);
        setState(() {
          _isAuthenticated = true;
          _userRole = user['role']; // 'ADMIN', 'TEACHER', or 'STUDENT'
          _isLoading = false;
        });
      } else {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking auth status
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Not authenticated → LoginScreen
    if (!_isAuthenticated) {
      return const LoginScreen();
    }

    // Authenticated → Route based on role
    switch (_userRole) {
      case 'ADMIN':
        return const AdminHomeScreen();
      case 'TEACHER':
        return const TeacherHomeScreen();
      case 'STUDENT':
        return const StudentHomeScreen();
      default:
        // If role is unknown, logout and go to login
        return const LoginScreen();
    }
  }
}
