import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../admin/screens/admin_home_screen.dart';
import '../../teacher/screens/teacher_home_screen.dart';
import '../../student/screens/student_home_screen.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart'; // your AuthService

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Example using your AuthService
    final authService = ref.watch(authServiceProvider);
    final isLoggedIn = authService.isLoggedIn;
    final role = authService.userRole; // 'admin', 'teacher', 'student'

    if (!isLoggedIn) {
      return const LoginScreen();
    }

    switch (role) {
      case 'admin':
        return const AdminHomeScreen();
      case 'teacher':
        return const TeacherHomeScreen();
      case 'student':
        return const StudentHomeScreen();
      default:
        return const LoginScreen();
    }
  }
}
