import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repository/auth_repository.dart';

class RegisterState extends Equatable {
  final AutovalidateMode autoValidateMode;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final Map<String, dynamic>? user;

  const RegisterState({
    this.autoValidateMode = AutovalidateMode.disabled,
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.user,
  });

  RegisterState copyWith({
    AutovalidateMode? autoValidateMode,
    bool? isLoading,
    String? errorMessage,
    bool errorMessageIsNull = false,
    bool? isSuccess,
    Map<String, dynamic>? user,
  }) {
    return RegisterState(
      autoValidateMode: autoValidateMode ?? this.autoValidateMode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessageIsNull ? null : errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [autoValidateMode, isLoading, errorMessage, isSuccess, user];
}

class RegisterViewCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;

  RegisterViewCubit(this._authRepository) : super(const RegisterState());

  void submitForm({
    required GlobalKey<FormState> formKey,
    required String email,
    required String password,
  }) async {
    if (formKey.currentState?.validate() ?? false) {
      emit(state.copyWith(
        isLoading: true,
        autoValidateMode: AutovalidateMode.disabled,
        errorMessageIsNull: true,
        isSuccess: false,
      ));
      await _userSave(email, password);
    } else {
      emit(state.copyWith(
        autoValidateMode: AutovalidateMode.onUserInteraction,
      ));
    }
  }

  Future<void> _userSave(String email, String password) async {
    try {
      await _authRepository.register(email: email, password: password);
      final user = await _authRepository.login(email: email, password: password);
      emit(state.copyWith(isLoading: false, isSuccess: true, user: user));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
