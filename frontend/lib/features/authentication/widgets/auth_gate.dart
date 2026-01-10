import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/login_screen.dart';
import '../../../shared/services/auth_service_provider.dart';
import '../../../shared/providers/auth_provider.dart';

import '../../actors/admin/screens/admin_home_screen.dart';
import '../../actors/teacher/screens/teacher_home_screen.dart';
import '../../actors/student/screens/student_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authServiceProvider);
    final user = ref.watch(authProvider);

    return FutureBuilder(
      future: authController.loadFromStorage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (user == null) {
          return const LoginScreen();
        }

        switch (user.role) {
          case 'ADMIN':
            return AdminHomeScreen();
          case 'TEACHER':
            return TeacherScreen();
          case 'STUDENT':
            return StudentScreen();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}
