import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/route/app_router.dart';
import '../../../auth/viewmodel/cubits/auth_cubit.dart';

import '../widgets/home_background.dart';
import '../widgets/home_avatar.dart';
import '../widgets/home_info_card.dart';
import '../widgets/home_logout_button.dart';

@RoutePage()
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeBackground(
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.router.replaceAll([const LoginRoute()]);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (state is Authenticated) {
            final user = state.user;
            final email = user['email'] ?? '';

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // Center square-ish translucent glass card with thin white border
                    Padding(
                      padding: const EdgeInsets.only(top: 42.0), // Room for overlapping avatar
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 400),
                            padding: const EdgeInsets.fromLTRB(28.0, 56.0, 28.0, 32.0),
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Prominent email info card
                                HomeInfoCard(email: email),
                                const SizedBox(height: 28),
                                // Full-width dark green/black LOGOUT button
                                HomeLogoutButton(
                                  onPressed: () async {
                                    await context.read<AuthCubit>().logout();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Circular dark green avatar overlapping top edge of the card
                    const Positioned(
                      top: 0,
                      child: HomeAvatar(size: 84),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: Text(
              'Bilinmeyen bir hata oluştu.',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
