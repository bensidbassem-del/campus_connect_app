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
  final String groupName;
  final String academicYear;

  CourseAssignment({
    required this.id,
    required this.teacherName,
    required this.courseName,
    required this.courseCode,
    required this.groupName,
    required this.academicYear,
  });

  factory CourseAssignment.fromJson(Map<String, dynamic> json) {
    return CourseAssignment(
      id: json['id'],
      teacherName: json['teacher_name'] ?? '',
      courseName: json['course_name'] ?? '',
      courseCode: json['course_code'] ?? '',
      groupName: json['group_name'] ?? '',
      academicYear: json['academic_year'] ?? '',
    );
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
}
