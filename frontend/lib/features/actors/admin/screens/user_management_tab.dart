import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/models/user_model.dart';
import '../providers/admin_providers.dart';
import 'admin_style.dart';

class UserManagementTab extends ConsumerStatefulWidget {
  const UserManagementTab({super.key});

  @override
  ConsumerState<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends ConsumerState<UserManagementTab> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'New Req.', 'Students', 'Teachers'];
  final _searchController = TextEditingController();

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
                child: CircularProgressIndicator(color: AdminStyle.primary),
              ),
              error: (e, st) =>
                  Center(child: Text('Error: $e', style: AdminStyle.body)),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedFilter == 3
          ? Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: FloatingActionButton.extended(
                onPressed: _showCreateTeacherDialog,
                backgroundColor: AdminStyle.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                icon: const Icon(Icons.add_circle, color: Colors.white),
                label: Text('Add Teacher', style: AdminStyle.button),
              ),
            )
          : null,
    );
  }

  Widget _buildTopNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AdminStyle.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() {}),
            decoration: AdminStyle.inputDec(
              'Search community...',
              icon: Icons.search_rounded,
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
                    selectedColor: AdminStyle.primary,
                    labelStyle: TextStyle(
                      color: active ? Colors.white : AdminStyle.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    backgroundColor: AdminStyle.bg,
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
        color: AdminStyle.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
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
                    : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
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
                  style: AdminStyle.subHeader.copyWith(fontSize: 16),
                ),
                Text(user.email, style: AdminStyle.body.copyWith(fontSize: 12)),
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
        ? AdminStyle.textPrimary
        : AdminStyle.primary;

    if (user.role == 'STUDENT' && !user.isApproved) {
      label = 'PENDING';
      color = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
    if (user.role == 'STUDENT' &&
        !user.isApproved &&
        user.rejectionReason == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRoundAction(
            Icons.check_circle_rounded,
            AdminStyle.secondary,
            () => ref.read(usersProvider.notifier).approveStudent(user.id),
          ),
          const SizedBox(width: 8),
          _buildRoundAction(
            Icons.cancel_rounded,
            AdminStyle.error,
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
            AdminStyle.primary,
            () => _showSendMessageDialog(user),
          ),
          if (user.role == 'STUDENT') ...[
            const SizedBox(width: 8),
            _buildRoundAction(
              Icons.group_add_rounded,
              AdminStyle.primary,
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
          color: color.withOpacity(0.1),
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
          Text(
            'No members found',
            style: AdminStyle.body.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --- Dialogs ---

  void _showSendMessageDialog(AppUser receiver) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text(
          'Message to ${receiver.name}',
          style: AdminStyle.header.copyWith(fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          decoration: AdminStyle.inputDec('Type something nice...'),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Maybe later', style: AdminStyle.body),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminStyle.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref
                    .read(usersProvider.notifier)
                    .sendMessage(receiver.id, controller.text);
                nav.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Message delivered!')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to send message: $e')),
                );
              }
            },
            child: Text('Send Chat', style: AdminStyle.button),
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
        title: Text(
          'New Professor',
          style: AdminStyle.header.copyWith(fontSize: 18),
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
            child: Text('Cancel', style: AdminStyle.body),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminStyle.textPrimary,
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
            child: Text('Create Profile', style: AdminStyle.button),
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
        decoration: AdminStyle.inputDec(label, icon: icon),
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
          style: AdminStyle.header.copyWith(fontSize: 18),
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
                      style: AdminStyle.subHeader.copyWith(fontSize: 14),
                    ),
                    subtitle: Text(
                      group.academicYear,
                      style: AdminStyle.body.copyWith(fontSize: 12),
                    ),
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
        title: Text(
          'Reject Registration',
          style: AdminStyle.header.copyWith(fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          decoration: AdminStyle.inputDec(
            'Reason for rejection',
          ).copyWith(fillColor: Colors.red[50]),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AdminStyle.body),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminStyle.error,
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
            child: Text('Confirm Reject', style: AdminStyle.button),
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
        title: Text(
          'Delete User',
          style: AdminStyle.header.copyWith(fontSize: 18),
        ),
        content: Text(
          'Delete ${user.name} permanently?',
          style: AdminStyle.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AdminStyle.body),
          ),
          TextButton(
            onPressed: () {
              ref.read(usersProvider.notifier).deleteUser(user.id, user.role);
              Navigator.pop(context);
            },
            child: Text(
              'Delete permanently',
              style: AdminStyle.button.copyWith(color: AdminStyle.error),
            ),
          ),
        ],
      ),
    );
  }
}
