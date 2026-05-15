class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;

  factory AppUser.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return AppUser(
      id: map['id'] as int,
      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      role: (map['role'] ?? '').toString(),
      phone: map['phone']?.toString(),
    );
  }
}
