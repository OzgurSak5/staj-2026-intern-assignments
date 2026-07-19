import 'package:flutter_bloc/flutter_bloc.dart';
import '../../view/screens/login_view.dart';
import 'package:flutter/material.dart';
import '../cubits/login_cubit.dart';

mixin LoginMixin on State<LoginView> {
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Obscure Password State
  bool obscurePassword = true;

  void toggleObscurePassword() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void submitForm() {
    context.read<LoginViewCubit>().submitForm(
      formKey: formKey,
      email: emailController.text.trim(),
      password: passwordController.text,
    );
  }
}
