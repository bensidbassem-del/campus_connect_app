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

class AppUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'student', 'teacher', 'admin', 'pending'
  final String? groupId;
  final String? avatarUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.groupId,
    this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      groupId: json['group_id'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'group_id': groupId,
      'avatar_url': avatarUrl,
    };
  }
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
