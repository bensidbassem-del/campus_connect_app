class Course {
  final String id;
  final String name;
  final String code;
  final String? teacherId;
  final List<String> studentGroups;

  Course({
    required this.id,
    required this.name,
    required this.code,
    this.teacherId,
    required this.studentGroups,
  });
}

class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'student', 'teacher', 'admin', 'pending'
  final String? groupId;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.groupId,
    this.avatarUrl,
  });
}

class FileItem {
  final String id;
  final String name;
  final String url;
  final String category; // 'schedule', 'timetable', 'notice'
  final DateTime uploadedAt;

  FileItem({
    required this.id,
    required this.name,
    required this.url,
    required this.category,
    required this.uploadedAt,
  });
}
