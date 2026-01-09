import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'student_profile_tab.dart';
import 'student_schedule_tab.dart';
import 'student_marks_tab.dart';

class StudentScreen extends ConsumerWidget {
  const StudentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Campus Connect - Student',
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
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
              tooltip: 'Notifications',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {},
              tooltip: 'Logout',
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.cyanAccent[400],
            unselectedLabelColor: Colors.grey[300],
            indicatorColor: Colors.cyanAccent[400],
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.person), text: 'Profile'),
              Tab(icon: Icon(Icons.schedule), text: 'Schedule'),
              Tab(icon: Icon(Icons.grade), text: 'Grades'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE0F7FA),
                Color(0xFFB2EBF2),
              ],
            ),
          ),
          child: const TabBarView(
            children: [
              StudentProfileTab(),
              StudentScheduleTab(),
              StudentMarksTab(),
            ],
          ),
        ),
      ),
    );
  }
}
