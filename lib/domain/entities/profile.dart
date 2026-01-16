class Profile {
  final String id;
  final String? fullName;
  final String role;
  final String? avatarUrl;
  final String? bio;
  final String? phone;
  final String? gender;
  final DateTime updatedAt;

  Profile({
    required this.id,
    this.fullName,
    required this.role,
    this.avatarUrl,
    this.bio,
    this.phone,
    this.gender,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  String toString() {
    return 'Profile(\n'
        '  id: $id,\n'
        '  fullName: $fullName,\n'
        '  role: $role,\n'
        '  avatarUrl: $avatarUrl,\n'
        '  bio: $bio,\n'
        '  phone: $phone,\n'
        '  gender: $gender,\n'
        '  updatedAt: ${updatedAt.toIso8601String()},\n'
        ')';
  }
}
