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
  final String? program;
  final int? semester;
  final bool isApproved;
  final String? rejectionReason;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.groupId,
    this.avatarUrl,
    this.program,
    this.semester,
    this.isApproved = false,
    this.rejectionReason,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // Backend returns first_name and last_name, combine them for name
    final firstName = json['first_name'] ?? '';
    final lastName = json['last_name'] ?? '';
    final combinedName =
        json['name'] ??
        (firstName.isEmpty && lastName.isEmpty
            ? json['username'] ?? ''
            : '$firstName $lastName'.trim());

    return AppUser(
      id: json['id']?.toString() ?? '',
      name: combinedName,
      email: json['email'] ?? '',
      role: json['role'] ?? 'STUDENT',
      groupId: json['group_id']?.toString() ?? json['group']?.toString(),
      avatarUrl: json['profile_picture'], // Django uses profile_picture
      program: json['program'],
      semester: json['semester'] is int ? json['semester'] : null,
      isApproved: json['is_approved'] ?? false,
      rejectionReason: json['rejection_reason'],
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
      'program': program,
      'semester': semester,
      'is_approved': isApproved,
      'rejection_reason': rejectionReason,
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
