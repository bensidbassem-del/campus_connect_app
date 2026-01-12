import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ CORRECTION : Ajout des champs manquants dans la classe User
class User {
  final String id;
  final String name;
  final String email; // Champ ajouté
  final String role; // 'student', 'teacher', 'pending'
  final String? groupId; // Champ ajouté (optionnel)

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.groupId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'] ?? '', // Avec valeur par défaut
      role: json['role'],
      groupId: json['groupId'],
    );
  }
}

// Provider for user management
final usersProvider = AsyncNotifierProvider<UsersNotifier, List<User>>(() {
  return UsersNotifier();
});

class UsersNotifier extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    // État initial
    return [];
  }

  Future<void> fetchUsers() async {
    state = const AsyncLoading<List<User>>();
    try {
      // TODO: Backend - GET /api/admin/users
      await Future.delayed(const Duration(seconds: 1)); // Simulation
      final users = [
        User(
          id: '1',
          name: 'John Doe',
          email: 'john@example.com',
          role: 'student',
          groupId: 'G101',
        ),
        User(
          id: '2',
          name: 'Jane Smith',
          email: 'jane@example.com',
          role: 'teacher',
        ),
        User(
          id: '3',
          name: 'Bob Johnson',
          email: 'bob@example.com',
          role: 'pending',
        ),
      ];
      state = AsyncData<List<User>>(users);
    } catch (e, stackTrace) {
      state = AsyncError<List<User>>(e, stackTrace);
      debugPrint('Error fetching users: $e');
    }
  }

  Future<void> approveRegistration(String userId) async {
    try {
      // TODO: Backend - POST /api/admin/users/$userId/approve
      await Future.delayed(const Duration(seconds: 1));

      state.whenData((users) {
        final updatedUsers = users.map((user) {
          if (user.id == userId) {
            return User(
              id: user.id,
              name: user.name,
              email: user.email,
              role: 'student', // Changer de 'pending' à 'student'
              groupId: user.groupId,
            );
          }
          return user;
        }).toList();
        state = AsyncData<List<User>>(updatedUsers);
      });
    } catch (e, stackTrace) {
      state = AsyncError<List<User>>(e, stackTrace);
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      // TODO: Backend - DELETE /api/admin/users/$userId
      await Future.delayed(const Duration(seconds: 1));

      state.whenData((users) {
        final updatedUsers = users.where((user) => user.id != userId).toList();
        state = AsyncData<List<User>>(updatedUsers);
      });
    } catch (e, stackTrace) {
      state = AsyncError<List<User>>(e, stackTrace);
    }
  }

  Future<void> assignGroup(String userId, String groupId) async {
    try {
      // TODO: Backend - POST /api/admin/users/assign-group
      await Future.delayed(const Duration(seconds: 1));

      state.whenData((users) {
        final updatedUsers = users.map((user) {
          if (user.id == userId) {
            return User(
              id: user.id,
              name: user.name,
              email: user.email,
              role: user.role,
              groupId: groupId,
            );
          }
          return user;
        }).toList();
        state = AsyncData<List<User>>(updatedUsers);
      });
    } catch (e, stackTrace) {
      state = AsyncError<List<User>>(e, stackTrace);
    }
  }
}

class UserManagementTab extends ConsumerStatefulWidget {
  const UserManagementTab({super.key});

  @override
  ConsumerState<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends ConsumerState<UserManagementTab> {
  int _selectedTab = 0;
  final List<String> userTypes = ['All', 'Students', 'Teachers', 'Pending'];

  @override
  void initState() {
    super.initState();
    // Fetch users on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersProvider.notifier).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ CORRECTION : Utiliser AsyncValue au lieu de List<User> directement
    final usersAsync = ref.watch(usersProvider);

    return Column(
      children: [
        // Tabs for user types
        Container(
          color: Colors.white,
          child: Row(
            children: userTypes.asMap().entries.map((entry) {
              final index = entry.key;
              final type = entry.value;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedTab = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTab == index
                              ? Colors.cyan[400]!
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ), // ✅ CORRECTION : Virgule déplacée
                    child: Text(
                      type,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: _selectedTab == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedTab == index
                            ? Colors.cyan[800]
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // ✅ CORRECTION : Gestion des états asynchrones
        Expanded(
          child: usersAsync.when(
            data: (users) {
              // Filter users based on selected tab
              List<User> filteredUsers = users.where((user) {
                if (_selectedTab == 0) return true;
                if (_selectedTab == 1) return user.role == 'student';
                if (_selectedTab == 2) return user.role == 'teacher';
                if (_selectedTab == 3) return user.role == 'pending';
                return true;
              }).toList();

              if (filteredUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getUserColor(user.role),
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.email),
                          const SizedBox(height: 4),
                          Text(
                            user.role.toUpperCase(),
                            style: TextStyle(
                              color: _getRoleColor(user.role),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (user.groupId != null && user.groupId!.isNotEmpty)
                            Text(
                              'Group: ${user.groupId}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (user.role == 'pending')
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              onPressed: () => _approveUser(user.id),
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.cyan),
                            onPressed: () => _editUser(user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(user.id, user.name),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading users',
                    style: TextStyle(color: Colors.red[700], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(usersProvider.notifier).fetchUsers(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getUserColor(String role) {
    switch (role) {
      case 'student':
        return Colors.cyan[700]!;
      case 'teacher':
        return Colors.teal[700]!;
      case 'admin':
        return Colors.purple[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'student':
        return Colors.cyan;
      case 'teacher':
        return Colors.teal;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _approveUser(String userId) async {
    try {
      await ref.read(usersProvider.notifier).approveRegistration(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _editUser(User user) {
    final groupController = TextEditingController(text: user.groupId ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: groupController,
                decoration: const InputDecoration(
                  labelText: 'Group ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Assign to courses...'),
              // TODO: Add course assignment UI here
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            onPressed: () async {
              try {
                await ref
                    .read(usersProvider.notifier)
                    .assignGroup(user.id, groupController.text.trim());
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteUser(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await ref.read(usersProvider.notifier).deleteUser(userId);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$userName deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
