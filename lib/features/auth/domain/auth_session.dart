import 'package:caritalent_mobile/features/auth/domain/app_user.dart';

class AuthSession {
  const AuthSession({required this.user, required this.token});

  final AppUser user;
  final String token;

  factory AuthSession.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return AuthSession(
      user: AppUser.fromJson(map['user']),
      token: (map['token'] ?? '').toString(),
    );
  }
}
