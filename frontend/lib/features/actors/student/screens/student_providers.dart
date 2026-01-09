import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ==================== Models ====================
class StudentProfile {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String program;
  final String group;
  final int semester;
  final String phone;
  final String address;
  final DateTime? birthDate;
  final String? profileImage;
  final List<EmergencyContact> emergencyContacts;

  StudentProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    required this.program,
    required this.group,
    required this.semester,
    required this.phone,
    required this.address,
    this.birthDate,
    this.profileImage,
    this.emergencyContacts = const [],
  });

  StudentProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
    List<EmergencyContact>? emergencyContacts,
  }) {
    return StudentProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      studentId: studentId,
      program: program,
      group: group,
      semester: semester,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      birthDate: birthDate,
      profileImage: profileImage ?? this.profileImage,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }
}

class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;

  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
  });
}

class ScheduleEvent {
  final String id;
  final String courseName;
  final String courseCode;
  final String teacher;
  final String room;
  final DateTime startTime;
  final DateTime endTime;
  final String day;
  final String type; // 'lecture', 'lab', 'tutorial'

  ScheduleEvent({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.teacher,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.day,
    required this.type,
  });
}

class CourseMark {
  final String courseId;
  final String courseName;
  final String courseCode;
  final Map<String, double> assessments; // assessment name -> score
  final double totalScore;
  final String grade;
  final double classAverage;
  final int rank;

  CourseMark({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.assessments,
    required this.totalScore,
    required this.grade,
    required this.classAverage,
    required this.rank,
  });
}

class AttendanceRecord {
  final String courseId;
  final String courseName;
  final int present;
  final int absent;
  final int late;
  final int total;
  final double percentage;

  AttendanceRecord({
    required this.courseId,
    required this.courseName,
    required this.present,
    required this.absent,
    required this.late,
    required this.total,
    required this.percentage,
  });
}

// ==================== Riverpod Providers ====================

// Provider for student profile
final studentProfileProvider = AsyncNotifierProvider<StudentProfileNotifier, StudentProfile?>(
      () => StudentProfileNotifier(),
);

class StudentProfileNotifier extends AsyncNotifier<StudentProfile?> {
  @override
  Future<StudentProfile?> build() async {
    return await _fetchProfile();
  }

  Future<StudentProfile> _fetchProfile() async {
    // TODO: Backend - GET /api/student/profile
    await Future.delayed(const Duration(seconds: 1));
    return StudentProfile(
      id: 'STU001',
      name: 'John Doe',
      email: 'john.doe@university.edu',
      studentId: '20230001',
      program: 'Computer Science',
      group: 'CS-101-A',
      semester: 3,
      phone: '+1 (555) 123-4567',
      address: '123 University Ave, Campus City',
      birthDate: DateTime(2001, 5, 15),
      profileImage: null,
      emergencyContacts: [
        EmergencyContact(
          name: 'Jane Doe',
          relationship: 'Mother',
          phone: '+1 (555) 987-6543',
        ),
        EmergencyContact(
          name: 'Robert Doe',
          relationship: 'Father',
          phone: '+1 (555) 456-7890',
        ),
      ],
    );
  }

  Future<void> updateProfile(StudentProfile updatedProfile) async {
    state = const AsyncLoading<StudentProfile?>();
    try {
      // TODO: Backend - PUT /api/student/profile
      await Future.delayed(const Duration(seconds: 1));
      state = AsyncData<StudentProfile?>(updatedProfile);

      // Show success message (handled in UI)
    } catch (e, stackTrace) {
      state = AsyncError<StudentProfile?>(e, stackTrace);
    }
  }
}

// Provider for student schedule
final studentScheduleProvider = AsyncNotifierProvider<StudentScheduleNotifier, List<ScheduleEvent>>(
      () => StudentScheduleNotifier(),
);

class StudentScheduleNotifier extends AsyncNotifier<List<ScheduleEvent>> {
  @override
  Future<List<ScheduleEvent>> build() async {
    return await _fetchSchedule();
  }

  Future<List<ScheduleEvent>> _fetchSchedule() async {
    // TODO: Backend - GET /api/student/schedule
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      ScheduleEvent(
        id: '1',
        courseName: 'Data Structures',
        courseCode: 'CS201',
        teacher: 'Dr. Smith',
        room: 'Room 301',
        startTime: today.add(const Duration(hours: 9)),
        endTime: today.add(const Duration(hours: 10, minutes: 30)),
        day: 'Monday',
        type: 'lecture',
      ),
      ScheduleEvent(
        id: '2',
        courseName: 'Algorithms',
        courseCode: 'CS202',
        teacher: 'Dr. Johnson',
        room: 'Lab 105',
        startTime: today.add(const Duration(hours: 11)),
        endTime: today.add(const Duration(hours: 12, minutes: 30)),
        day: 'Monday',
        type: 'lab',
      ),
      ScheduleEvent(
        id: '3',
        courseName: 'Database Systems',
        courseCode: 'CS203',
        teacher: 'Dr. Williams',
        room: 'Room 205',
        startTime: today.add(const Duration(hours: 14)),
        endTime: today.add(const Duration(hours: 15, minutes: 30)),
        day: 'Tuesday',
        type: 'lecture',
      ),
      ScheduleEvent(
        id: '4',
        courseName: 'Software Engineering',
        courseCode: 'CS204',
        teacher: 'Dr. Brown',
        room: 'Room 302',
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 11, minutes: 30)),
        day: 'Wednesday',
        type: 'lecture',
      ),
      ScheduleEvent(
        id: '5',
        courseName: 'Computer Networks',
        courseCode: 'CS205',
        teacher: 'Dr. Davis',
        room: 'Lab 110',
        startTime: today.add(const Duration(hours: 13)),
        endTime: today.add(const Duration(hours: 15)),
        day: 'Thursday',
        type: 'lab',
      ),
    ];
  }

  Future<List<ScheduleEvent>> getTodaySchedule() async {
    final schedule = state.value ?? [];
    final today = DateTime.now();
    final dayName = DateFormat('EEEE').format(today);

    return schedule.where((event) => event.day == dayName).toList();
  }

  Future<List<ScheduleEvent>> getWeekSchedule() async {
    final schedule = state.value ?? [];
    return schedule;
  }
}

// Provider for student marks
final studentMarksProvider = AsyncNotifierProvider<StudentMarksNotifier, List<CourseMark>>(
      () => StudentMarksNotifier(),
);

class StudentMarksNotifier extends AsyncNotifier<List<CourseMark>> {
  @override
  Future<List<CourseMark>> build() async {
    return await _fetchMarks();
  }

  Future<List<CourseMark>> _fetchMarks() async {
    // TODO: Backend - GET /api/student/marks
    await Future.delayed(const Duration(seconds: 1));

    return [
      CourseMark(
        courseId: '1',
        courseName: 'Data Structures',
        courseCode: 'CS201',
        assessments: {
          'Quiz 1': 18.0,
          'Midterm': 85.0,
          'Assignment 1': 90.0,
          'Quiz 2': 20.0,
          'Final': 88.0,
        },
        totalScore: 87.5,
        grade: 'A',
        classAverage: 78.3,
        rank: 5,
      ),
      CourseMark(
        courseId: '2',
        courseName: 'Algorithms',
        courseCode: 'CS202',
        assessments: {
          'Quiz 1': 17.0,
          'Midterm': 82.0,
          'Assignment 1': 88.0,
          'Final': 85.0,
        },
        totalScore: 84.0,
        grade: 'B+',
        classAverage: 75.6,
        rank: 8,
      ),
      CourseMark(
        courseId: '3',
        courseName: 'Database Systems',
        courseCode: 'CS203',
        assessments: {
          'Quiz 1': 19.0,
          'Midterm': 90.0,
          'Project': 95.0,
          'Final': 92.0,
        },
        totalScore: 91.5,
        grade: 'A',
        classAverage: 82.1,
        rank: 2,
      ),
      CourseMark(
        courseId: '4',
        courseName: 'Software Engineering',
        courseCode: 'CS204',
        assessments: {
          'Midterm': 78.0,
          'Project': 85.0,
          'Final': 80.0,
        },
        totalScore: 81.0,
        grade: 'B',
        classAverage: 76.8,
        rank: 12,
      ),
    ];
  }
}

// Provider for student attendance
final studentAttendanceProvider = AsyncNotifierProvider<StudentAttendanceNotifier, List<AttendanceRecord>>(
      () => StudentAttendanceNotifier(),
);

class StudentAttendanceNotifier extends AsyncNotifier<List<AttendanceRecord>> {
  @override
  Future<List<AttendanceRecord>> build() async {
    return await _fetchAttendance();
  }

  Future<List<AttendanceRecord>> _fetchAttendance() async {
    // TODO: Backend - GET /api/student/attendance
    await Future.delayed(const Duration(seconds: 1));

    return [
      AttendanceRecord(
        courseId: '1',
        courseName: 'Data Structures',
        present: 28,
        absent: 2,
        late: 1,
        total: 31,
        percentage: 90.3,
      ),
      AttendanceRecord(
        courseId: '2',
        courseName: 'Algorithms',
        present: 30,
        absent: 0,
        late: 1,
        total: 31,
        percentage: 96.8,
      ),
      AttendanceRecord(
        courseId: '3',
        courseName: 'Database Systems',
        present: 29,
        absent: 1,
        late: 1,
        total: 31,
        percentage: 93.5,
      ),
      AttendanceRecord(
        courseId: '4',
        courseName: 'Software Engineering',
        present: 27,
        absent: 3,
        late: 1,
        total: 31,
        percentage: 87.1,
      ),
    ];
  }
}