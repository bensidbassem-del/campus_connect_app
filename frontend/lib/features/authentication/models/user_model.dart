class AppUser {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? studentId;
  final String? birthDate;
  final String? phone;
  final String? address;
  final String role;
  final bool isApproved;

  AppUser({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isApproved,
    this.studentId,
    this.birthDate,
    this.phone,
    this.address,
  });

  /// 🔗 THIS IS THE LINK
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      studentId: json['student_id'],
      birthDate: json['birth_date'],
      phone: json['phone'],
      address: json['address'],
      role: json['role'],
      isApproved: json['is_approved'],
    );
  }
}
