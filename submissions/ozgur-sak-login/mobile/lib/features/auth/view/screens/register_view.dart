import '../../viewmodel/mixins/auth_validation_mixin.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../viewmodel/cubits/register_cubit.dart';
import '../../viewmodel/mixins/register_mixin.dart';
import '../../../../core/route/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../viewmodel/cubits/auth_cubit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../widgets/auth_button.dart';

@RoutePage()
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with AuthValidationMixin, RegisterMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: BlocConsumer<RegisterViewCubit, RegisterState>(
        listener: (context, state) {
          if (state.isSuccess) {
            context.read<AuthCubit>().checkAuthStatus();
            context.router.replaceAll([const HomeRoute()]);
          } else if (state.errorMessage != null) {
            AppDialogs.showError(
              context: context,
              title: 'Kayıt Başarısız',
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
                    const SizedBox(height: 32),
                    _buildEmailField(isLoading),
                    const SizedBox(height: 16),
                    _buildPasswordField(isLoading),
                    const SizedBox(height: 16),
                    _buildConfirmPasswordField(isLoading),
                    const SizedBox(height: 24),
                    _buildSubmitButton(isLoading),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleObscurePassword,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validatePassword,
    );
  }

  Widget _buildConfirmPasswordField(bool isLoading) {
    return TextFormField(
      controller: confirmPasswordController,
      obscureText: obscurePassword,
      enabled: !isLoading,
      decoration: InputDecoration(
        labelText: 'Şifre Tekrar',
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) =>
          validateConfirmPassword(value, passwordController.text),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return AuthButton(
      text: 'Kayıt Ol ve Giriş Yap',
      isLoading: isLoading,
      onPressed: submitForm,
    );
  }
}
