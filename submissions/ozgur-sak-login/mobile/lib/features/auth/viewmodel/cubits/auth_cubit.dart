import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repository/auth_repository.dart';

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final Map<String, dynamic> user;
  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    final token = await _authRepository.getAccessToken();
    if (token == null) {
      emit(const Unauthenticated());
      return;
    }

    try {
      final user = await _authRepository.getMe();
      emit(Authenticated(user));
    } catch (_) {
      emit(const AuthLoading());
      await _authRepository.logout();
      emit(const Unauthenticated());
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    await _authRepository.logout();
    emit(const Unauthenticated());
  }
}
