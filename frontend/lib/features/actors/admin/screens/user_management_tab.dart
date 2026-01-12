import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/models/user_model.dart';
import '../providers/admin_providers.dart';

class UserManagementTab extends ConsumerStatefulWidget {
  const UserManagementTab({super.key});

  @override
  ConsumerState<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends ConsumerState<UserManagementTab> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Approvals', 'Students', 'Teachers'];

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);
    const primaryBlue = Color(0xFF0066FF);

    return Column(
      children: [
        // Simple Filter Bar
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final active = _selectedFilter == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_filters[index]),
                  selected: active,
                  onSelected: (val) {
                    if (val) setState(() => _selectedFilter = index);
                  },
                  selectedColor: primaryBlue,
                  labelStyle: TextStyle(
                    color: active ? Colors.white : Colors.black,
                    fontSize: 13,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(
                      color: active ? primaryBlue : Colors.grey[300]!,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Expanded(
          child: usersAsync.when(
            data: (users) {
              final filtered = users.where((u) {
                if (_selectedFilter == 0) return true;
                if (_selectedFilter == 1)
                  return !u.isApproved && u.role == 'STUDENT';
                if (_selectedFilter == 2) return u.role == 'STUDENT';
                if (_selectedFilter == 3) return u.role == 'TEACHER';
                return true;
              }).toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    'No users found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey[100]),
                itemBuilder: (context, index) {
                  final user = filtered[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    title: Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (user.role == 'STUDENT')
                          Text(
                            '${user.program ?? "No Program"} • Semester ${user.semester ?? "?"}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: primaryBlue,
                            ),
                          ),
                      ],
                    ),
                    trailing: _buildTrailing(user),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: primaryBlue,
                strokeWidth: 2,
              ),
            ),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildTrailing(AppUser user) {
    if (!user.isApproved &&
        user.role == 'STUDENT' &&
        user.rejectionReason == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 20,
            ),
            onPressed: () =>
                ref.read(usersProvider.notifier).approveStudent(user.id),
          ),
          IconButton(
            icon: const Icon(
              Icons.cancel_outlined,
              color: Colors.red,
              size: 20,
            ),
            onPressed: () => _showRejectDialog(user.id),
          ),
        ],
      );
    }

    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.black26, size: 20),
      onPressed: () => _confirmDelete(user),
    );
  }

  void _showRejectDialog(String id) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(),
        title: const Text(
          'Reject Student',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Reason for rejection',
            border: OutlineInputBorder(borderRadius: BorderRadius.zero),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: const RoundedRectangleBorder(),
            ),
            onPressed: () {
              ref
                  .read(usersProvider.notifier)
                  .rejectStudent(id, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(),
        title: const Text('Delete User'),
        content: Text('Delete ${user.name}? This action is permanent.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              ref.read(usersProvider.notifier).deleteUser(user.id, user.role);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
