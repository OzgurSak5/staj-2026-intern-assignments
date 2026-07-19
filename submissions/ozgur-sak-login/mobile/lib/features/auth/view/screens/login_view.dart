import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/route/app_router.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../viewmodel/cubits/auth_cubit.dart';
import '../../viewmodel/cubits/login_cubit.dart';
import '../../viewmodel/mixins/auth_validation_mixin.dart';
import '../../viewmodel/mixins/login_mixin.dart';
import '../widgets/auth_button.dart';

@RoutePage()
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with AuthValidationMixin, LoginMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LoginViewCubit, LoginState>(
        listener: (context, state) {
          if (state.isSuccess) {
            context.read<AuthCubit>().checkAuthStatus();
            context.router.replaceAll([const HomeRoute()]);
          } else if (state.errorMessage != null) {
            AppDialogs.showError(
              context: context,
              title: 'Giriş Başarısız',
              message: state.errorMessage!,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.isLoading;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: formKey,
                autovalidateMode: state.autoValidateMode,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildEmailField(isLoading),
                    const SizedBox(height: 16),
                    _buildPasswordField(isLoading),
                    const SizedBox(height: 24),
                    _buildSubmitButton(isLoading),
                    const SizedBox(height: 16),
                    _buildForgotPasswordButton(isLoading),
                    _buildRegisterButton(isLoading),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(
          Icons.lock_outline_rounded,
          size: 80,
          color: Colors.deepPurple,
        ),
        const SizedBox(height: 16),
        Text(
          'Hoş Geldiniz',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Devam etmek için giriş yapın',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildEmailField(bool isLoading) {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      enabled: !isLoading,
      decoration: InputDecoration(
        labelText: 'E-posta',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validateEmail,
    );
  }

  Widget _buildPasswordField(bool isLoading) {
    return TextFormField(
      controller: passwordController,
      obscureText: obscurePassword,
      enabled: !isLoading,
      decoration: InputDecoration(
        labelText: 'Şifre',
        prefixIcon: const Icon(Icons.lock_open_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: toggleObscurePassword,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validatePassword,
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return AuthButton(
      text: 'Giriş Yap',
      isLoading: isLoading,
      onPressed: submitForm,
    );
  }

  Widget _buildForgotPasswordButton(bool isLoading) {
    return TextButton(
      onPressed: isLoading
          ? null
          : () => context.router.push(const ForgotPasswordRoute()),
      child: const Text('Şifremi Unuttum'),
    );
  }

  Widget _buildRegisterButton(bool isLoading) {
    return TextButton(
      onPressed: isLoading
          ? null
          : () => context.router.push(const RegisterRoute()),
      child: const Text('Hesabınız yok mu? Kayıt Olun'),
    );
  }
}
