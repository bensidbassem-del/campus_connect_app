import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/models/user_model.dart';
import '../providers/admin_providers.dart';
import '../../../../shared/services/api_client.dart';

class UserManagementTab extends ConsumerStatefulWidget {
  const UserManagementTab({super.key});

  @override
  ConsumerState<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends ConsumerState<UserManagementTab> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'New Req.', 'Students', 'Teachers'];
  final _searchController = TextEditingController();

  static const primaryBlue = Color(0xFF4A80F0);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildTopNav(),
          Expanded(
            child: usersAsync.when(
              data: (users) {
                final query = _searchController.text.toLowerCase();
                final filtered = users.where((u) {
                  final matchesSearch =
                      u.name.toLowerCase().contains(query) ||
                      u.email.toLowerCase().contains(query);
                  if (!matchesSearch) {
                    return false;
                  }

                  if (_selectedFilter == 0) {
                    return true;
                  }
                  if (_selectedFilter == 1) {
                    return !u.isApproved && u.role == 'STUDENT';
                  }
                  if (_selectedFilter == 2) {
                    return u.role == 'STUDENT';
                  }
                  if (_selectedFilter == 3) {
                    return u.role == 'TEACHER';
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _buildRoundedUserCard(filtered[index]),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: primaryBlue),
              ),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedFilter == 3
          ? Padding(
              padding: const EdgeInsets.only(
                bottom: 70,
              ), // Move up for floating bar
              child: FloatingActionButton.extended(
                onPressed: _showCreateTeacherDialog,
                backgroundColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                icon: const Icon(Icons.add_circle, color: Colors.white),
                label: const Text(
                  'Add Teacher',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildTopNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search community...',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: primaryBlue),
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_filters.length, (index) {
                final active = _selectedFilter == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_filters[index]),
                    selected: active,
                    onSelected: (v) => setState(() => _selectedFilter = index),
                    selectedColor: primaryBlue,
                    labelStyle: TextStyle(
                      color: active ? Colors.white : const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide.none,
                    showCheckmark: false,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedUserCard(AppUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: user.role == 'TEACHER'
                    ? [const Color(0xFF1E293B), const Color(0xFF475569)]
                    : [const Color(0xFF4A80F0), const Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                _buildDynamicBadge(user),
              ],
            ),
          ),
          _buildActionButtons(user),
        ],
      ),
    );
  }

  Widget _buildDynamicBadge(AppUser user) {
    String label = user.role;
    Color color = user.role == 'TEACHER'
        ? const Color(0xFF1E293B)
        : primaryBlue;

    if (user.role == 'STUDENT' && !user.isApproved) {
      label = 'PENDING';
      color = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppUser user) {
    if (!user.isApproved &&
        user.role == 'STUDENT' &&
        user.rejectionReason == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRoundAction(
            Icons.check_circle_rounded,
            Colors.green,
            () => ref.read(usersProvider.notifier).approveStudent(user.id),
          ),
          const SizedBox(width: 8),
          _buildRoundAction(
            Icons.cancel_rounded,
            Colors.red,
            () => _showRejectDialog(user.id),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (user.isApproved) ...[
          _buildRoundAction(
            Icons.chat_bubble_rounded,
            primaryBlue,
            () => _showSendMessageDialog(user),
          ),
          if (user.role == 'STUDENT') ...[
            const SizedBox(width: 8),
            _buildRoundAction(
              Icons.group_add_rounded,
              primaryBlue,
              () => _showAssignGroupDialog(user),
            ),
          ],
        ],
        const SizedBox(width: 8),
        _buildRoundAction(
          Icons.delete_rounded,
          const Color(0xFFCBD5E1),
          () => _confirmDelete(user),
        ),
      ],
    );
  }

  Widget _buildRoundAction(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.face_retouching_off_rounded,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No members found',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- Dialogs slightly updated with rounded corners ---

  void _showSendMessageDialog(AppUser receiver) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text(
          'Message to ${receiver.name}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Type something nice...',
            filled: true,
            fillColor: const Color(0xFFF8FAFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe later'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(apiClientProvider).post('messages/', {
                'receiver': receiver.id,
                'content': controller.text,
              });
              if (!mounted) {
                return;
              }
              nav.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Message delivered!')),
              );
            },
            child: const Text(
              'Send Chat',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTeacherDialog() {
    final uC = TextEditingController();
    final eC = TextEditingController();
    final pC = TextEditingController();
    final fC = TextEditingController();
    final lC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: const Text(
          'New Professor',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModernField(uC, 'Username', Icons.person_outline),
              _buildModernField(eC, 'Email Address', Icons.email_outlined),
              _buildModernField(
                pC,
                'Secret Password',
                Icons.lock_outline,
                obscure: true,
              ),
              _buildModernField(fC, 'First Name', Icons.badge_outlined),
              _buildModernField(lC, 'Last Name', Icons.badge_outlined),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            onPressed: () {
              ref
                  .read(usersProvider.notifier)
                  .createTeacher(
                    username: uC.text,
                    email: eC.text,
                    password: pC.text,
                    firstName: fC.text,
                    lastName: lC.text,
                  );
              Navigator.pop(context);
            },
            child: const Text(
              'Create Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernField(
    TextEditingController c,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: const Color(0xFFF8FAFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _showAssignGroupDialog(AppUser student) {
    final groupsAsync = ref.watch(adminGroupsProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text(
          'Assign ${student.name.split(" ")[0]}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: groupsAsync.when(
          data: (groups) {
            if (groups.isEmpty) return const Text('No groups yet');
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Text(
                      group.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(group.academicYear),
                    onTap: () {
                      ref
                          .read(usersProvider.notifier)
                          .assignToGroup(student.id, group.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text('Error: $e'),
        ),
      ),
    );
  }

  void _showRejectDialog(String id) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text(
          'Reject Registration',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Reason for rejection',
            filled: true,
            fillColor: Colors.red[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              ref
                  .read(usersProvider.notifier)
                  .rejectStudent(id, controller.text);
              Navigator.pop(context);
            },
            child: const Text(
              'Confirm Reject',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text(
          'Delete User',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text('Delete ${user.name} permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(usersProvider.notifier).deleteUser(user.id, user.role);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete permanently',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
