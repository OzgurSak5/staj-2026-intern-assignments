import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/route/app_router.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../viewmodel/cubits/auth_cubit.dart';
import '../../viewmodel/cubits/register_cubit.dart';
import '../../viewmodel/mixins/auth_validation_mixin.dart';
import '../../viewmodel/mixins/register_mixin.dart';

import '../../../home/view/widgets/home_avatar.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_info_card.dart';
import '../widgets/auth_redirect_button.dart';
import '../widgets/auth_text_field.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.router.popForced(),
        ),
      ),
      body: AuthBackground(
        child: BlocConsumer<RegisterViewCubit, RegisterState>(
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // Glassmorphism Card
                    Padding(
                      padding: const EdgeInsets.only(top: 42.0), // Room for overlapping avatar
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 400),
                            padding: const EdgeInsets.fromLTRB(28.0, 56.0, 28.0, 28.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.7),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Form(
                              key: formKey,
                              autovalidateMode: state.autoValidateMode,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const AuthInfoCard(
                                    title: 'Kayıt Ol',
                                    subtitle: 'Aramıza katılmak için kaydolun',
                                  ),
                                  const SizedBox(height: 24),
                                  AuthTextField(
                                    controller: emailController,
                                    labelText: 'E-posta Adresi',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    enabled: !isLoading,
                                    validator: validateEmail,
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    controller: passwordController,
                                    labelText: 'Şifre',
                                    prefixIcon: Icons.lock_open_outlined,
                                    obscureText: obscurePassword,
                                    enabled: !isLoading,
                                    validator: validatePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFF505F76),
                                      ),
                                      onPressed: toggleObscurePassword,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    controller: confirmPasswordController,
                                    labelText: 'Şifre Tekrar',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    obscureText: obscurePassword,
                                    enabled: !isLoading,
                                    validator: (value) => validateConfirmPassword(
                                        value, passwordController.text),
                                  ),
                                  const SizedBox(height: 24),
                                  AuthButton(
                                    text: 'Kayıt Ol',
                                    isLoading: isLoading,
                                    onPressed: submitForm,
                                  ),
                                  const SizedBox(height: 12),
                                  AuthRedirectButton(
                                    text: 'Zaten hesabınız var mı?',
                                    actionText: 'Giriş Yapın',
                                    enabled: !isLoading,
                                    onPressed: () => context.router.popForced(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Overlapping top circular dark green avatar
                    const Positioned(
                      top: 0,
                      child: HomeAvatar(size: 84),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
