import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/dashboard_tab.dart';
import '../screens/courses_tab.dart';
import '../screens/settings_tab.dart';
import '../screens/user_management_tab.dart';
import '../../../../shared/services/auth_service.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryBlue = Color(0xFF0066FF);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Campus Connect Admin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined, color: Colors.black),
              onPressed: () {
                ref.read(authServiceProvider).logout();
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: primaryBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryBlue,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: 'Courses'),
              Tab(text: 'Dashboard'),
              Tab(text: 'Users'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CoursesTab(),
            DashboardTab(),
            UserManagementTab(),
            SettingsTab(),
          ],
        ),
      ),
    );
  }
}
