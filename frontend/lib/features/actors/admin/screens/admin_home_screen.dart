import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/dashboard_tab.dart';
import '../screens/courses_tab.dart';
import '../screens/settings_tab.dart';
import '../screens/user_management_tab.dart';

class Admin {
  final String id;
  final String name;
  final String email;
  Admin({required this.id, required this.name, required this.email});
}

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Campus Connect Admin',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.cyan[800],
          foregroundColor: Colors.white,
          elevation: 4,
          bottom: TabBar(
            labelColor: Colors.cyanAccent[400],
            unselectedLabelColor: Colors.grey[300],
            indicatorColor: Colors.cyanAccent[400],
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.folder), text: 'Courses'),
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.manage_accounts), text: 'Users'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
            ),
          ),
          child: const TabBarView(
            children: [
              CoursesTab(),
              DashboardTab(),
              UserManagementTab(),
              SettingsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
