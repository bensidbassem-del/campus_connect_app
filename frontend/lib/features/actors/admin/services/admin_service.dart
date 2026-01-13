import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/models/user_model.dart';
import '../../../../shared/services/api_client.dart';

final adminServiceProvider = Provider((ref) => AdminService(ref));

class CourseAssignment {
  final int id;
  final String teacherName;
  final String courseName;
  final String courseCode;
  final String groupId;
  final String groupName;
  final String academicYear;
  final List<ScheduleSession> sessions;

  CourseAssignment({
    required this.id,
    required this.teacherName,
    required this.courseName,
    required this.courseCode,
    required this.groupId,
    required this.groupName,
    required this.academicYear,
    this.sessions = const [],
  });

  factory CourseAssignment.fromJson(Map<String, dynamic> json) {
    return CourseAssignment(
      id: json['id'],
      teacherName: json['teacher_name'] ?? '',
      courseName: json['course_name'] ?? '',
      courseCode: json['course_code'] ?? '',
      groupName: json['group_name'] ?? '',
      groupId: json['group_id']?.toString() ?? '',
      academicYear: json['academic_year'] ?? '',
      sessions: (json['sessions'] as List? ?? [])
          .map((s) => ScheduleSession.fromJson(s))
          .toList(),
    );
  }
}

class ScheduleSession {
  final int? id;
  final int? assignmentId;
  final String? courseCode;
  final String? courseName;
  final String? groupName;
  final String? teacherName;
  final String day;
  final String startTime;
  final String endTime;
  final String room;
  final String sessionType;

  ScheduleSession({
    this.id,
    this.assignmentId,
    this.courseCode,
    this.courseName,
    this.groupName,
    this.teacherName,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.sessionType,
  });

  factory ScheduleSession.fromJson(Map<String, dynamic> json) {
    return ScheduleSession(
      id: json['id'],
      assignmentId: json['assignment_id'],
      courseCode: json['course_code'],
      courseName: json['course_name'],
      groupName: json['group_name'],
      teacherName: json['teacher_name'],
      day: json['day'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      room: json['room'],
      sessionType: json['session_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (assignmentId != null) 'assignment_id': assignmentId,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'session_type': sessionType,
    };
  }
}

class AcademicGroup {
  final String id;
  final String name;
  final String academicYear;

  AcademicGroup({
    required this.id,
    required this.name,
    required this.academicYear,
  });

  factory AcademicGroup.fromJson(Map<String, dynamic> json) {
    return AcademicGroup(
      id: json['id'].toString(),
      name: json['name'],
      academicYear: json['academic_year'],
    );
  }
}

class AdminService {
  final Ref _ref;

  AdminService(this._ref);

  ApiClient get _api => _ref.read(apiClientProvider);

  // --- User Management ---

  Future<List<AppUser>> getUsers({
    String? role,
    bool? isApproved,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (role != null) queryParams['role'] = role;
    if (isApproved != null) queryParams['is_approved'] = isApproved.toString();
    if (search != null) queryParams['search'] = search;

    final response = await _api.get(
      'admin/students/',
      queryParams: queryParams,
    );
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> data = decoded is Map
          ? (decoded['results'] ?? [])
          : decoded;
      return data.map((json) => AppUser.fromJson(json)).toList();
    }
    throw Exception('Failed to load users');
  }

  Future<List<AppUser>> getTeachers({String? search}) async {
    final queryParams = <String, String>{};
    if (search != null) queryParams['search'] = search;

    final response = await _api.get(
      'admin/teachers/',
      queryParams: queryParams,
    );
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> data = decoded is Map
          ? (decoded['results'] ?? [])
          : decoded;
      return data.map((json) => AppUser.fromJson(json)).toList();
    }
    throw Exception('Failed to load teachers');
  }

  Future<void> approveStudent(String id) async {
    final response = await _api.post('admin/approve-student/$id/', {});
    if (response.statusCode != 200) {
      throw Exception('Failed to approve student');
    }
  }

  Future<void> rejectStudent(String id, String reason) async {
    final response = await _api.post('admin/reject-student/$id/', {
      'reason': reason,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to reject student');
    }
  }

  Future<void> deleteUser(String id, String role) async {
    final endpoint = role == 'TEACHER'
        ? 'admin/teachers/$id/'
        : 'admin/students/$id/';
    final response = await _api.delete(endpoint);
    if (response.statusCode != 24 &&
        response.statusCode != 204 &&
        response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  // --- Course & Assignment Management ---

  Future<List<Course>> getCourses({String? search}) async {
    final queryParams = <String, String>{};
    if (search != null) queryParams['search'] = search;

    final response = await _api.get('courses/', queryParams: queryParams);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> data = decoded is Map
          ? (decoded['results'] ?? [])
          : decoded;
      return data
          .map(
            (json) => Course(
              id: json['id'].toString(),
              name: json['name'],
              code: json['code'],
              studentGroups: [], // Populated elsewhere if needed
            ),
          )
          .toList();
    }
    throw Exception('Failed to load courses');
  }

  Future<void> createCourse(String code, String name, int credits) async {
    final response = await _api.post('courses/', {
      'code': code,
      'name': name,
      'credits': credits,
    });
    if (response.statusCode != 201) {
      throw Exception('Failed to create course');
    }
  }

  Future<List<CourseAssignment>> getAssignments({String? groupId}) async {
    final queryParams = <String, String>{};
    if (groupId != null) queryParams['group'] = groupId;

    final response = await _api.get(
      'admin/assignments/',
      queryParams: queryParams,
    );
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> data = decoded is Map
          ? (decoded['results'] ?? [])
          : decoded;
      return data.map((json) => CourseAssignment.fromJson(json)).toList();
    }
    throw Exception('Failed to load assignments');
  }

  Future<void> createAssignment(
    int teacherId,
    int courseId,
    int groupId,
    String academicYear,
  ) async {
    final response = await _api.post('admin/assignments/', {
      'teacher': teacherId,
      'course': courseId,
      'group': groupId,
      'academic_year': academicYear,
    });
    if (response.statusCode != 201) {
      throw Exception('Failed to create assignment');
    }
  }

  // --- Group Management ---

  Future<List<AcademicGroup>> getGroups() async {
    final response = await _api.get('groups/');
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> data = decoded is Map
          ? (decoded['results'] ?? [])
          : decoded;
      return data.map((json) => AcademicGroup.fromJson(json)).toList();
    }
    throw Exception('Failed to load groups');
  }

  Future<void> createGroup(String name, String academicYear) async {
    final response = await _api.post('groups/', {
      'name': name,
      'academic_year': academicYear,
    });
    if (response.statusCode != 201) {
      throw Exception('Failed to create group');
    }
  }

  Future<void> createTeacher({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    final response = await _api.post('admin/teachers/create/', {
      'username': username,
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
    });
    if (response.statusCode != 201) {
      throw Exception('Failed to create teacher');
    }
  }

  Future<void> assignStudentToGroup(String studentId, String groupId) async {
    final response = await _api.post('admin/assign-group/', {
      'student_id': studentId,
      'group_id': groupId,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to assign student to group');
    }
  }

  // --- Timetable Management ---

  Future<void> uploadTimetable({
    required String groupId,
    required String title,
    required String filePath,
    required String semester,
    required String academicYear,
  }) async {
    final streamResponse = await _api.uploadFile('timetables/', filePath, {
      'group': groupId,
      'title': title,
      'semester': semester,
      'academic_year': academicYear,
      'is_active': 'true',
    }, fileKey: 'image');
    if (streamResponse.statusCode != 201) {
      throw Exception('Failed to upload timetable');
    }
  }

  Future<List<dynamic>> getTimetables() async {
    final response = await _api.get('timetables/');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load timetables');
  }

  // --- Course Deletion ---

  Future<void> deleteCourse(String id) async {
    final response = await _api.delete('courses/$id/');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete course');
    }
  }

  // --- Messaging ---

  Future<void> sendMessage(String receiverId, String content) async {
    final response = await _api.post('messages/', {
      'receiver': receiverId,
      'content': content,
    });
    if (response.statusCode != 201) {
      throw Exception('Failed to send message');
    }
  }

  // --- Schedule Management ---

  Future<List<ScheduleSession>> getSchedule({
    String? groupId,
    String? day,
  }) async {
    final queryParams = <String, String>{};
    if (groupId != null) queryParams['assignment__group'] = groupId;
    if (day != null) queryParams['day'] = day;

    final response = await _api.get('schedule/', queryParams: queryParams);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> data = decoded is Map
          ? (decoded['results'] ?? [])
          : decoded;
      return data.map((json) => ScheduleSession.fromJson(json)).toList();
    }
    throw Exception('Failed to load schedule');
  }

  Future<void> createScheduleSession(ScheduleSession session) async {
    final response = await _api.post('schedule/', session.toJson());
    if (response.statusCode != 201) {
      throw Exception('Failed to create schedule session');
    }
  }

  Future<void> deleteScheduleSession(int id) async {
    final response = await _api.delete('schedule/$id/');
    if (response.statusCode != 24 &&
        response.statusCode != 204 &&
        response.statusCode != 200) {
      throw Exception('Failed to delete schedule session');
    }
  }
}
