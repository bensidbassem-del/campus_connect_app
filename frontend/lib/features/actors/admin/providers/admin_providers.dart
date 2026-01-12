import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/models/user_model.dart';
import '../services/admin_service.dart';

// --- Users Provider ---

final usersProvider = AsyncNotifierProvider<UsersNotifier, List<AppUser>>(() {
  return UsersNotifier();
});

class UsersNotifier extends AsyncNotifier<List<AppUser>> {
  @override
  Future<List<AppUser>> build() async {
    return _fetch();
  }

  Future<List<AppUser>> _fetch() async {
    final students = await ref.read(adminServiceProvider).getUsers();
    final teachers = await ref.read(adminServiceProvider).getTeachers();
    return [...students, ...teachers];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> approveStudent(String id) async {
    await ref.read(adminServiceProvider).approveStudent(id);
    await refresh();
  }

  Future<void> rejectStudent(String id, String reason) async {
    await ref.read(adminServiceProvider).rejectStudent(id, reason);
    await refresh();
  }

  Future<void> deleteUser(String id, String role) async {
    await ref.read(adminServiceProvider).deleteUser(id, role);
    await refresh();
  }
}

// --- Courses Provider ---

final adminCoursesProvider =
    AsyncNotifierProvider<AdminCoursesNotifier, List<Course>>(() {
      return AdminCoursesNotifier();
    });

class AdminCoursesNotifier extends AsyncNotifier<List<Course>> {
  @override
  Future<List<Course>> build() async {
    return _fetch();
  }

  Future<List<Course>> _fetch() async {
    return await ref.read(adminServiceProvider).getCourses();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> addCourse(String code, String name, int credits) async {
    await ref.read(adminServiceProvider).createCourse(code, name, credits);
    await refresh();
  }
}

// --- Groups Provider ---

final adminGroupsProvider =
    AsyncNotifierProvider<AdminGroupsNotifier, List<AcademicGroup>>(() {
      return AdminGroupsNotifier();
    });

class AdminGroupsNotifier extends AsyncNotifier<List<AcademicGroup>> {
  @override
  Future<List<AcademicGroup>> build() async {
    return await ref.read(adminServiceProvider).getGroups();
  }
}
