import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_providers.dart';
import 'admin_style.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  static const primaryBlue = Color(0xFF4A80F0);
  static const darkSlate = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    final coursesAsync = ref.watch(adminCoursesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Parent provides background
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildWelcomeMessage(),
            const SizedBox(height: 16),

            _buildSectionTitle('Overview'),
            const SizedBox(height: 4),
            usersAsync.when(
              data: (users) {
                final pendingCount = users
                    .where((u) => !u.isApproved && u.role == 'STUDENT')
                    .length;
                final studentCount = users
                    .where((u) => u.isApproved && u.role == 'STUDENT')
                    .length;
                final teacherCount = users
                    .where((u) => u.role == 'TEACHER')
                    .length;

                return GridView.count(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.1,
                  children: [
                    _buildDynamicStatCard(
                      'Students',
                      studentCount.toString(),
                      Icons.people_rounded,
                      primaryBlue,
                      const Color(0xFFEEF2FF),
                    ),
                    _buildDynamicStatCard(
                      'Teachers',
                      teacherCount.toString(),
                      Icons.school_rounded,
                      const Color(0xFF10B981), // Emerald
                      const Color(0xFFECFDF5),
                    ),
                    _buildDynamicStatCard(
                      'Pending',
                      pendingCount.toString(),
                      Icons.pending_actions_rounded,
                      const Color(0xFFF59E0B), // Amber
                      const Color(0xFFFFFBEB),
                    ),
                    coursesAsync.when(
                      data: (courses) => _buildDynamicStatCard(
                        'Courses',
                        courses.length.toString(),
                        Icons.collections_bookmark_rounded,
                        const Color(0xFF8B5CF6), // Violet
                        const Color(0xFFF5F3FF),
                      ),
                      loading: () => _buildDynamicStatCard(
                        'Courses',
                        '...',
                        Icons.book,
                        darkSlate,
                        Colors.white,
                      ),
                      error: (_, __) => _buildDynamicStatCard(
                        'Courses',
                        '!',
                        Icons.error,
                        Colors.red,
                        Colors.white,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    color: primaryBlue,
                    strokeWidth: 3,
                  ),
                ),
              ),
              error: (e, __) => Text('Error: $e'),
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Quick Access'),
            const SizedBox(height: 16),
            _buildModernActionTile(
              context,
              'Authentication Requests',
              'Verify new student registrations',
              Icons.vignette_rounded,
              const Color(0xFF4A80F0),
              onTap: () =>
                  ref.read(adminTabProvider.notifier).state = 2, // Users
            ),
            _buildModernActionTile(
              context,
              'Academic Scheduling',
              'Update group timetables',
              Icons.calendar_month_rounded,
              const Color(0xFF8B5CF6),
              onTap: () =>
                  ref.read(adminTabProvider.notifier).state = 1, // Academy
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: AdminStyle.body.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'Administrator',
          style: AdminStyle.header.copyWith(fontSize: 28, letterSpacing: -1),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title, // Removed toUpperCase()
      style: AdminStyle.subHeader.copyWith(
        fontSize: 14,
        color: const Color(0xFF94A3B8), // Muted color
        fontWeight: FontWeight.w700,
        letterSpacing: 0, // Removed wide spacing
      ),
    );
  }

  Widget _buildDynamicStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFFCBD5E1),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
