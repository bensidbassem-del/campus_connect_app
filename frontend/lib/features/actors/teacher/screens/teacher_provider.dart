import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

// ==================== Models ====================
class TeacherCourse {
  final String id;
  final String name;
  final String code;
  final String groupId;
  final List<Student> students;
  final int totalWeeks;

  TeacherCourse({
    required this.id,
    required this.name,
    required this.code,
    required this.groupId,
    required this.students,
    required this.totalWeeks,
  });
}

class Student {
  final String id;
  final String name;
  final String studentId;
  final String? avatarUrl;
  final String email;

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    this.avatarUrl,
    required this.email,
  });
}

class AttendanceRecord {
  final String studentId;
  final String studentName;
  final Map<DateTime, String> attendance; // date -> status

  AttendanceRecord({
    required this.studentId,
    required this.studentName,
    required this.attendance,
  });
}

class Mark {
  final String studentId;
  final String studentName;
  final Map<String, double> assessments; // assessment name -> score
  final double totalScore;

  Mark({
    required this.studentId,
    required this.studentName,
    required this.assessments,
    required this.totalScore,
  });
}

class TeacherFile {
  final String id;
  final String name;
  final String url;
  final String type; // 'lecture', 'assignment', 'resource'
  final DateTime uploadedAt;
  final String courseId;

  TeacherFile({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.uploadedAt,
    required this.courseId,
  });
}

// ==================== Riverpod Providers ====================

// ✅ CORRECTION : Utiliser AsyncNotifierProvider pour Riverpod 3.x
final teacherCoursesProvider =
    AsyncNotifierProvider<TeacherCoursesNotifier, List<TeacherCourse>>(() {
      return TeacherCoursesNotifier();
    });

class TeacherCoursesNotifier extends AsyncNotifier<List<TeacherCourse>> {
  @override
  Future<List<TeacherCourse>> build() async {
    return [];
  }

  Future<void> fetchTeacherCourses(String teacherId) async {
    state = const AsyncLoading<List<TeacherCourse>>();
    try {
      // TODO: Backend - GET /api/teacher/$teacherId/courses
      await Future.delayed(const Duration(seconds: 1));
      final courses = [
        TeacherCourse(
          id: '1',
          name: 'Programming Basics',
          code: 'CS101',
          groupId: 'G101',
          students: [],
          totalWeeks: 15,
        ),
        TeacherCourse(
          id: '2',
          name: 'Calculus',
          code: 'MATH201',
          groupId: 'G201',
          students: [],
          totalWeeks: 12,
        ),
      ];
      state = AsyncData<List<TeacherCourse>>(courses);
    } catch (e, stackTrace) {
      state = AsyncError<List<TeacherCourse>>(e, stackTrace);
      // log('Error fetching teacher courses: $e');
    }
  }
}

// ✅ CORRECTION : Pour l'attendance
final attendanceProvider =
    AsyncNotifierProvider<
      AttendanceNotifier,
      Map<String, List<AttendanceRecord>>
    >(() {
      return AttendanceNotifier();
    });

class AttendanceNotifier
    extends AsyncNotifier<Map<String, List<AttendanceRecord>>> {
  @override
  Future<Map<String, List<AttendanceRecord>>> build() async {
    return {};
  }

  Future<void> fetchAttendance(String courseId, DateTime week) async {
    state = const AsyncLoading<Map<String, List<AttendanceRecord>>>();
    try {
      // TODO: Backend - GET /api/teacher/courses/$courseId/attendance
      await Future.delayed(const Duration(seconds: 1));

      // Données simulées
      final records = List.generate(
        4,
        (index) => AttendanceRecord(
          studentId: 'STU00${index + 1}',
          studentName: 'Student ${index + 1}',
          attendance: {
            DateTime.now(): 'present',
            DateTime.now().subtract(const Duration(days: 1)): 'absent',
          },
        ),
      );

      state = AsyncData<Map<String, List<AttendanceRecord>>>({
        courseId: records,
      });
    } catch (e, stackTrace) {
      state = AsyncError<Map<String, List<AttendanceRecord>>>(e, stackTrace);
      // log('Error fetching attendance: $e');
    }
  }

  Future<void> markAttendance(
    String courseId,
    String studentId,
    DateTime date,
    String status,
  ) async {
    try {
      // TODO: Backend - POST /api/teacher/courses/$courseId/attendance
      await Future.delayed(const Duration(seconds: 1));

      state.whenData((data) {
        if (data.containsKey(courseId)) {
          final updatedRecords = data[courseId]!.map((record) {
            if (record.studentId == studentId) {
              final updatedAttendance = Map<DateTime, String>.from(
                record.attendance,
              );
              updatedAttendance[date] = status;
              return AttendanceRecord(
                studentId: record.studentId,
                studentName: record.studentName,
                attendance: updatedAttendance,
              );
            }
            return record;
          }).toList();

          final updatedData = Map<String, List<AttendanceRecord>>.from(data);
          updatedData[courseId] = updatedRecords;
          state = AsyncData<Map<String, List<AttendanceRecord>>>(updatedData);
        }
      });
    } catch (e, stackTrace) {
      state = AsyncError<Map<String, List<AttendanceRecord>>>(e, stackTrace);
    }
  }
}

// ✅ CORRECTION : Pour les notes
final marksProvider =
    AsyncNotifierProvider<MarksNotifier, Map<String, List<Mark>>>(() {
      return MarksNotifier();
    });

class MarksNotifier extends AsyncNotifier<Map<String, List<Mark>>> {
  @override
  Future<Map<String, List<Mark>>> build() async {
    return {};
  }

  Future<void> fetchMarks(String courseId) async {
    state = const AsyncLoading<Map<String, List<Mark>>>();
    try {
      // TODO: Backend - GET /api/teacher/courses/$courseId/marks
      await Future.delayed(const Duration(seconds: 1));

      // Données simulées
      final marks = List.generate(
        12,
        (index) => Mark(
          studentId: 'STU00${index + 1}',
          studentName: 'Student ${index + 1}',
          assessments: {'Quiz 1': 15.0, 'Midterm': 18.0, 'Assignment 1': 17.5},
          totalScore: 75.0 + (index % 20),
        ),
      );

      state = AsyncData<Map<String, List<Mark>>>({courseId: marks});
    } catch (e, stackTrace) {
      state = AsyncError<Map<String, List<Mark>>>(e, stackTrace);
      // log('Error fetching marks: $e');
    }
  }

  Future<void> updateMark(
    String courseId,
    String studentId,
    String assessment,
    double score,
  ) async {
    try {
      // TODO: Backend - PUT /api/teacher/courses/$courseId/marks
      await Future.delayed(const Duration(seconds: 1));

      state.whenData((data) {
        if (data.containsKey(courseId)) {
          final updatedMarks = data[courseId]!.map((mark) {
            if (mark.studentId == studentId) {
              final updatedAssessments = Map<String, double>.from(
                mark.assessments,
              );
              updatedAssessments[assessment] = score;

              // Recalculer le total
              final totalScore = updatedAssessments.values.reduce(
                (a, b) => a + b,
              );

              return Mark(
                studentId: mark.studentId,
                studentName: mark.studentName,
                assessments: updatedAssessments,
                totalScore: totalScore,
              );
            }
            return mark;
          }).toList();

          final updatedData = Map<String, List<Mark>>.from(data);
          updatedData[courseId] = updatedMarks;
          state = AsyncData<Map<String, List<Mark>>>(updatedData);
        }
      });
    } catch (e, stackTrace) {
      state = AsyncError<Map<String, List<Mark>>>(e, stackTrace);
    }
  }
}

// ✅ CORRECTION : Pour les fichiers du teacher
final teacherFilesProvider =
    AsyncNotifierProvider<TeacherFilesNotifier, List<TeacherFile>>(() {
      return TeacherFilesNotifier();
    });

class TeacherFilesNotifier extends AsyncNotifier<List<TeacherFile>> {
  @override
  Future<List<TeacherFile>> build() async {
    return [];
  }

  Future<void> uploadFile(
    String courseId,
    File file,
    String fileName,
    String fileType,
  ) async {
    try {
      // TODO: Backend - POST /api/teacher/courses/$courseId/files/upload
      await Future.delayed(const Duration(seconds: 2));

      final newFile = TeacherFile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: fileName,
        url: 'url_from_backend',
        type: fileType,
        uploadedAt: DateTime.now(),
        courseId: courseId,
      );

      state = AsyncData<List<TeacherFile>>([...state.value ?? [], newFile]);
    } catch (e, stackTrace) {
      state = AsyncError<List<TeacherFile>>(e, stackTrace);
    }
  }

  Future<void> fetchCourseFiles(String courseId) async {
    state = const AsyncLoading<List<TeacherFile>>();
    try {
      // TODO: Backend - GET /api/teacher/courses/$courseId/files
      await Future.delayed(const Duration(seconds: 1));

      final files = List.generate(
        5,
        (index) => TeacherFile(
          id: index.toString(),
          name: 'Lecture_${index + 1}.pdf',
          url: 'url_$index',
          type: 'lecture',
          uploadedAt: DateTime.now().subtract(Duration(days: index)),
          courseId: courseId,
        ),
      );

      state = AsyncData<List<TeacherFile>>(files);
    } catch (e, stackTrace) {
      state = AsyncError<List<TeacherFile>>(e, stackTrace);
    }
  }
}
