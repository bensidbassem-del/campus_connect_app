import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../shared/services/api_client.dart';

class StudentService {
  final ApiClient _api = ApiClient();

  // GET MY GRADES - Connects to: GET /api/grades/my-grades/
  Future<List<dynamic>> getMyGrades() async {
    try {
      final response = await _api.get('/grades/my-grades/');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching grades: $e');
      return [];
    }
  }

  // GET MY COURSES - Connects to: GET /api/courses/student-courses/
  Future<List<dynamic>> getMyCourses() async {
    try {
      final response = await _api.get('/courses/student-courses/');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      return [];
    }
  }

  // GET MY TIMETABLE - Connects to: GET /api/timetables/my-timetable/
  Future<Map<String, dynamic>?> getMyTimetable() async {
    try {
      final response = await _api.get('/timetables/my-timetable/');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching timetable: $e');
      return null;
    }
  }

  // GET COURSE FILES - Connects to: GET /api/files/?course_id=1
  Future<List<dynamic>> getCourseFiles(int courseId) async {
    try {
      final response = await _api.get('/files/?course_id=$courseId');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching files: $e');
      return [];
    }
  }
}
