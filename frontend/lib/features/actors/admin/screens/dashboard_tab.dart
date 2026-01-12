import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_providers.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    final coursesAsync = ref.watch(adminCoursesProvider);
    const primaryBlue = Color(0xFF0066FF);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Overview',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),

          usersAsync.when(
            data: (users) {
              final studentCount = users
                  .where((u) => u.role == 'STUDENT')
                  .length;
              final teacherCount = users
                  .where((u) => u.role == 'TEACHER')
                  .length;
              final pendingCount = users
                  .where((u) => !u.isApproved && u.role == 'STUDENT')
                  .length;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatBox(
                    'Students',
                    studentCount.toString(),
                    primaryBlue,
                  ),
                  _buildStatBox(
                    'Teachers',
                    teacherCount.toString(),
                    Colors.black,
                  ),
                  _buildStatBox(
                    'Pending',
                    pendingCount.toString(),
                    Colors.orange,
                  ),
                  coursesAsync.when(
                    data: (courses) => _buildStatBox(
                      'Courses',
                      courses.length.toString(),
                      Colors.black,
                    ),
                    loading: () =>
                        _buildStatBox('Courses', '...', Colors.black),
                    error: (_, __) =>
                        _buildStatBox('Courses', '!', Colors.black),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            ),
            error: (e, __) => Text('Error: $e'),
          ),

          const SizedBox(height: 40),
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Refresh Data'),
            subtitle: const Text('Sync with backend server'),
            trailing: const Icon(Icons.refresh, size: 20),
            onTap: () {
              ref.read(usersProvider.notifier).refresh();
              ref.read(adminCoursesProvider.notifier).refresh();
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('View All Users'),
            subtitle: const Text('Navigate to management tab'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              DefaultTabController.of(context).animateTo(2);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
