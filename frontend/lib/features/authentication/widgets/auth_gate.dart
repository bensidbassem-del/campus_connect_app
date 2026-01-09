import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../screens/login_screen.dart';

import '../../actors/admin/screens/admin_home_screen.dart';
import '../../actors/teacher/screens/teacher_home_screen.dart';
import '../../actors/student/screens/student_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);

    return FutureBuilder(
      future: auth.loadFromStorage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!auth.isLoggedIn) {
          return const LoginScreen();
        }

        switch (auth.userRole) {
          case 'admin':
            return AdminHomeScreen();
          case 'teacher':
            return TeacherScreen();
          case 'student':
            return StudentScreen();
          default:
            return LoginScreen();
        }
      },
    );
  }
}