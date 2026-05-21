import 'package:caritalent_mobile/core/constants/api_endpoints.dart';
import 'package:caritalent_mobile/core/constants/user_roles.dart';
import 'package:caritalent_mobile/core/network/api_client.dart';
import 'package:caritalent_mobile/core/network/api_exception.dart';
import 'package:caritalent_mobile/core/storage/secure_storage_service.dart';
import 'package:caritalent_mobile/features/auth/domain/app_user.dart';
import 'package:caritalent_mobile/features/auth/domain/auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
  );
});

class AuthRepository {
  const AuthRepository(this._api, this._storage);

  final ApiClient _api;
  final SecureStorageService _storage;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _api.post<AuthSession>(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
      parser: AuthSession.fromJson,
    );
    _ensureMobileRole(session.user.role);
    await _storage.saveToken(session.token);
    return session;
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String role,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'phone': phone,
      'role': role,
    };

    final session = await _api.post<AuthSession>(
      ApiEndpoints.authRegister,
      data: payload,
      parser: AuthSession.fromJson,
    );
    _ensureMobileRole(session.user.role);
    await _storage.saveToken(session.token);
    return session;
  }

  Future<AppUser?> getCurrentUser() async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) return null;
    final user = await _api.get<AppUser>(
      ApiEndpoints.authMe,
      parser: AppUser.fromJson,
    );
    if (!UserRoles.isMobileRole(user.role)) {
      await _storage.clearToken();
      return null;
    }
    return user;
  }

  Future<void> logout() async {
    try {
      await _api.post<void>(ApiEndpoints.authLogout, parser: (_) {});
    } finally {
      await _storage.clearToken();
    }
  }

  void _ensureMobileRole(String role) {
    if (!UserRoles.isMobileRole(role)) {
      throw const ApiException(
        'Aplikasi mobile hanya tersedia untuk Talent dan EO.',
      );
    }
  }
}
