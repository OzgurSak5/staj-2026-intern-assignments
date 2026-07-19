import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/register_cubit.dart';
import '../../view/screens/register_view.dart';

 mixin RegisterMixin on State<RegisterView> {
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Obscure State
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
    confirmPasswordController.dispose();
    super.dispose();
  }

  void submitForm() {
    context.read<RegisterViewCubit>().submitForm(
      formKey: formKey,
      email: emailController.text.trim(),
      password: passwordController.text,
    );
  }
}
