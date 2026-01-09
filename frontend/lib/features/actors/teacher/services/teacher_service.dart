import 'dart:convert';
import '../../../../shared//services/api_client.dart';

class TeacherService {
  final ApiClient _api = ApiClient();
  
  // GET MY COURSES - Connects to: GET /api/courses/my-courses/
  Future<List<dynamic>> getMyCourses() async {
    try {
      final response = await _api.get('/courses/my-courses/');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // GET COURSE STUDENTS WITH GRADES
  // Connects to: GET /api/grades/course/{courseId}/students/
  Future<List<dynamic>> getCourseStudents(int courseId) async {
    try {
      final response = await _api.get('/grades/course/$courseId/students/');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // UPDATE GRADE - Connects to: PUT /api/grades/{gradeId}/
  Future<bool> updateGrade(
    int gradeId, {
    double? tdMark,
    double? tpMark,
    double? examMark,
    String? comments,
  }) async {
    try {
      final response = await _api.put('/grades/$gradeId/', {
        if (tdMark != null) 'td_mark': tdMark,
        if (tpMark != null) 'tp_mark': tpMark,
        if (examMark != null) 'exam_mark': examMark,
        if (comments != null) 'comments': comments,
      });
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // MARK ATTENDANCE - Connects to: POST /api/attendance/
  Future<bool> markAttendance({
    required int studentId,
    required int courseId,
    required String date,
    required int weekNumber,
    required String status,
  }) async {
    try {
      final response = await _api.post('/attendance/', {
        'student': studentId,
        'course': courseId,
        'date': date,
        'week_number': weekNumber,
        'status': status,
      });
      
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}