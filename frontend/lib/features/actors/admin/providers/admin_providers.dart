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

  Future<void> createTeacher({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    await ref
        .read(adminServiceProvider)
        .createTeacher(
          username: username,
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        );
    await refresh();
  }

  Future<void> assignToGroup(String studentId, String groupId) async {
    await ref
        .read(adminServiceProvider)
        .assignStudentToGroup(studentId, groupId);
    await refresh();
  }

  Future<void> sendMessage(String receiverId, String content) async {
    await ref.read(adminServiceProvider).sendMessage(receiverId, content);
    // No refresh needed for user list after sending a message
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

  Future<void> deleteCourse(String id) async {
    await ref.read(adminServiceProvider).deleteCourse(id);
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
    return _fetch();
  }

  Future<List<AcademicGroup>> _fetch() async {
    return await ref.read(adminServiceProvider).getGroups();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> addGroup(String name, String academicYear) async {
    await ref.read(adminServiceProvider).createGroup(name, academicYear);
    await refresh();
  }
}

// --- Assignments Provider ---

final adminAssignmentsProvider =
    AsyncNotifierProvider<AdminAssignmentsNotifier, List<CourseAssignment>>(() {
      return AdminAssignmentsNotifier();
    });

class AdminAssignmentsNotifier extends AsyncNotifier<List<CourseAssignment>> {
  @override
  Future<List<CourseAssignment>> build() async {
    return _fetch();
  }

  Future<List<CourseAssignment>> _fetch({String? groupId}) async {
    return await ref
        .read(adminServiceProvider)
        .getAssignments(groupId: groupId);
  }

  Future<void> refresh({String? groupId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(groupId: groupId));
  }
}

// --- Timetables Provider ---

final adminTimetablesProvider =
    AsyncNotifierProvider<AdminTimetablesNotifier, List<dynamic>>(() {
      return AdminTimetablesNotifier();
    });

class AdminTimetablesNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    return _fetch();
  }

  Future<List<dynamic>> _fetch() async {
    return await ref.read(adminServiceProvider).getTimetables();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> uploadTimetable({
    required String groupId,
    required String title,
    required String filePath,
    required String semester,
    required String academicYear,
  }) async {
    await ref
        .read(adminServiceProvider)
        .uploadTimetable(
          groupId: groupId,
          title: title,
          filePath: filePath,
          semester: semester,
          academicYear: academicYear,
        );
    await refresh();
  }
}

// --- Dynamic Schedule Provider ---

final adminScheduleProvider =
    AsyncNotifierProvider<AdminScheduleNotifier, List<ScheduleSession>>(() {
      return AdminScheduleNotifier();
    });

class AdminScheduleNotifier extends AsyncNotifier<List<ScheduleSession>> {
  @override
  Future<List<ScheduleSession>> build() async {
    return _fetch();
  }

  Future<List<ScheduleSession>> _fetch({String? groupId}) async {
    return await ref.read(adminServiceProvider).getSchedule(groupId: groupId);
  }

  Future<void> refresh({String? groupId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(groupId: groupId));
  }

  Future<void> addSession(ScheduleSession session) async {
    await ref.read(adminServiceProvider).createScheduleSession(session);
    await refresh();
  }

  Future<void> removeSession(int id) async {
    await ref.read(adminServiceProvider).deleteScheduleSession(id);
    await refresh();
  }
}

// --- Settings Provider ---

class AdminSettings {
  final bool pushNotifications;
  final bool cloudSync;
  final bool newStudentAlerts;

  AdminSettings({
    this.pushNotifications = true,
    this.cloudSync = false,
    this.newStudentAlerts = true,
  });

  AdminSettings copyWith({
    bool? pushNotifications,
    bool? cloudSync,
    bool? newStudentAlerts,
  }) {
    return AdminSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      cloudSync: cloudSync ?? this.cloudSync,
      newStudentAlerts: newStudentAlerts ?? this.newStudentAlerts,
    );
  }
}

final adminSettingsProvider =
    StateNotifierProvider<AdminSettingsNotifier, AdminSettings>((ref) {
      return AdminSettingsNotifier();
    });

class AdminSettingsNotifier extends StateNotifier<AdminSettings> {
  AdminSettingsNotifier() : super(AdminSettings());

  void togglePushNotifications() {
    state = state.copyWith(pushNotifications: !state.pushNotifications);
  }

  void toggleCloudSync() {
    state = state.copyWith(cloudSync: !state.cloudSync);
  }

  void toggleNewStudentAlerts() {
    state = state.copyWith(newStudentAlerts: !state.newStudentAlerts);
  }
}

// --- Navigation Provider ---

final adminTabProvider = StateProvider<int>((ref) => 0);
