import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'teacher_courses_tab.dart';
import 'attendance_tab.dart';
import 'marks_tab.dart';
import '../../../../shared/services/auth_service.dart';

class TeacherScreen extends ConsumerWidget {
  const TeacherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Campus Connect - Teacher',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.cyan[800],
          foregroundColor: Colors.white,
          elevation: 4,
          actions: [
            IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authServiceProvider).logout();
              },
              tooltip: 'Logout',
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.cyanAccent[400],
            unselectedLabelColor: Colors.grey[300],
            indicatorColor: Colors.cyanAccent[400],
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.folder), text: 'Courses'),
              Tab(icon: Icon(Icons.person), text: 'Attendance'),
              Tab(icon: Icon(Icons.grade), text: 'Marks'),
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
            children: [TeacherCoursesTab(), AttendanceTab(), MarksTab()],
          ),
        ),
      ),
    );
  }
}
