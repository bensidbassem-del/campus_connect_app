import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model User
class User {
  final String id;
  final String name;
  final String role; // 'student', 'teacher', 'pending'

  User({required this.id, required this.name, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'], role: json['role']);
  }
}

// Provider for user management - CORRIGÉ
final usersProvider = AsyncNotifierProvider<UsersNotifier, List<User>>(() {
  return UsersNotifier();
});

class UsersNotifier extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    // État initial - retourner une liste vide ou charger les données
    return [];
  }

  Future<void> fetchUsers() async {
    state = const AsyncLoading<List<User>>();
    try {
      // TODO: Backend - GET /api/admin/users
      await Future.delayed(const Duration(seconds: 1)); // Simulation
      // Exemple de données mockées
      final users = [
        User(id: '1', name: 'John Doe', role: 'student'),
        User(id: '2', name: 'Jane Smith', role: 'teacher'),
        User(id: '3', name: 'Bob Johnson', role: 'pending'),
        User(id: '4', name: 'Alice Brown', role: 'student'),
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

      // Mettre à jour l'état local
      state.whenData((users) {
        final updatedUsers = users.map((user) {
          if (user.id == userId) {
            return User(id: user.id, name: user.name, role: 'student');
          }
          return user;
        }).toList();
        state = AsyncData<List<User>>(updatedUsers);
      });
    } catch (e) {
      throw Exception('Error approving registration: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      // TODO: Backend - DELETE /api/admin/users/$userId
      await Future.delayed(const Duration(seconds: 1));

      // Mettre à jour l'état local
      state.whenData((users) {
        final updatedUsers = users.where((user) => user.id != userId).toList();
        state = AsyncData<List<User>>(updatedUsers);
      });
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  Future<void> assignGroup(String userId, String groupId) async {
    // TODO: Backend - POST /api/admin/users/assign-group
    // Body: {userId: string, groupId: string}
    await Future.delayed(const Duration(seconds: 1));
  }
}

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Stats Grid - Géré avec AsyncValue
          usersAsync.when(
            data: (users) {
              // ✅ CORRECTION : Utiliser la méthode where() correctement
              final totalStudents = users
                  .where((u) => u.role == 'student')
                  .length;
              final totalTeachers = users
                  .where((u) => u.role == 'teacher')
                  .length;
              final pendingRegistrations = users
                  .where((u) => u.role == 'pending')
                  .length;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Total Students',
                    totalStudents,
                    Icons.people,
                    Colors.cyan,
                  ),
                  _buildStatCard(
                    'Total Teachers',
                    totalTeachers,
                    Icons.school,
                    Colors.cyan[700]!,
                  ),
                  _buildStatCard(
                    'Pending Registrations',
                    pendingRegistrations,
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                  _buildStatCard('Active Courses', 12, Icons.book, Colors.teal),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    'Error loading data',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  Text(error.toString(), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recent Activities
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Activities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan[800],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.cyan),
                        onPressed: () =>
                            ref.read(usersProvider.notifier).fetchUsers(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  usersAsync.when(
                    data: (users) {
                      // Afficher les derniers utilisateurs en attente
                      final pendingUsers = users
                          .where((u) => u.role == 'pending')
                          .take(3)
                          .toList();

                      if (pendingUsers.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No pending registrations'),
                        );
                      }

                      return Column(
                        children: pendingUsers
                            .map(
                              (user) => ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange[100],
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.orange[800],
                                  ),
                                ),
                                title: Text(user.name),
                                subtitle: const Text('Pending registration'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      ),
                                      onPressed: () =>
                                          _approveUser(context, ref, user.id),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _deleteUser(context, ref, user.id),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => const SizedBox(),
                  ),

                  // Activités statiques (optionnel)
                  const Divider(),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.cyan[100],
                      child: Icon(Icons.file_upload, color: Colors.cyan[800]),
                    ),
                    title: Text('Timetable uploaded'),
                    subtitle: Text('5 hours ago'),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.cyan[100],
                      child: Icon(Icons.assignment, color: Colors.cyan[800]),
                    ),
                    title: Text('Course assignment updated'),
                    subtitle: Text('1 day ago'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.cyan[800],
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveUser(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    try {
      await ref.read(usersProvider.notifier).approveRegistration(userId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration approved'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteUser(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    try {
      await ref.read(usersProvider.notifier).deleteUser(userId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
