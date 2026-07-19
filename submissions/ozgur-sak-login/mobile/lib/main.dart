import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/dio_client.dart';
import 'core/route/app_router.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/auth/viewmodel/cubits/auth_cubit.dart';
import 'features/auth/viewmodel/cubits/register_cubit.dart';
import 'features/auth/viewmodel/cubits/login_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(AuthService(DioClient())),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) =>
                AuthCubit(context.read<AuthRepository>())..checkAuthStatus(),
          ),
          BlocProvider<RegisterViewCubit>(
            create: (context) =>
                RegisterViewCubit(context.read<AuthRepository>()),
          ),
          BlocProvider<LoginViewCubit>(
            create: (context) => LoginViewCubit(context.read<AuthRepository>()),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Login App',
          routerConfig: _appRouter.config(),
        ),
      ),
    );
  }
}
