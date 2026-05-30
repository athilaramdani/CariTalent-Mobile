import 'package:caritalent_mobile/core/network/api_exception.dart';
import 'package:caritalent_mobile/features/auth/data/auth_repository.dart';
import 'package:caritalent_mobile/features/auth/domain/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:caritalent_mobile/core/network/api_client.dart';
import 'package:caritalent_mobile/core/storage/secure_storage_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
  );
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref.watch(authRepositoryProvider));
  },
);

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.isBootstrapping = true,
    this.errorMessage,
  });

  final AppUser? user;
  final bool isLoading;
  final bool isBootstrapping;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool clearUser = false,
    bool? isLoading,
    bool? isBootstrapping,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState()) {
    bootstrap();
  }

  final AuthRepository _repository;

  Future<void> bootstrap() async {
    try {
      final user = await _repository.getCurrentUser();
      state = state.copyWith(
        user: user,
        isBootstrapping: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(clearUser: true, isBootstrapping: false);
    }
  }

  Future<void> login(String email, String password) async {
    await _run(() async {
      // Dummy Login Implementation
      if (email == 'eo@dummy.com') {
        state = state.copyWith(
          user: const AppUser(id: 1, name: 'Bill Stephen', email: 'eo@dummy.com', role: 'eo', phone: '081234560002'),
          isLoading: false,
          clearError: true,
        );
        return;
      }
      if (email == 'talent@dummy.com') {
        state = state.copyWith(
          user: const AppUser(id: 2, name: 'Rizky Maulana', email: 'talent@dummy.com', role: 'talent', phone: '081234560001'),
          isLoading: false,
          clearError: true,
        );
        return;
      }
      
      final session = await _repository.login(email: email, password: password);
      state = state.copyWith(
        user: session.user,
        isLoading: false,
        clearError: true,
      );
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String role,
    String? stageName,
  }) async {
    await _run(() async {
      final session = await _repository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
        role: role,
        stageName: stageName,
      );
      state = state.copyWith(
        user: session.user,
        isLoading: false,
        clearError: true,
      );
    });
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _repository.logout();
    state = state.copyWith(clearUser: true, isLoading: false);
  }

  Future<void> _run(Future<void> Function() action) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await action();
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      rethrow;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan. Coba lagi sebentar.',
      );
      rethrow;
    }
  }
}
