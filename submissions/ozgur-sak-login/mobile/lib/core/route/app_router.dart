import '../../features/auth/view/screens/register_view.dart';
import '../../features/auth/view/screens/login_view.dart';
import '../storage/secure_storage_manager.dart';
import '../../features/home/home_view.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'View,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page,
      path: '/',
      initial: true,
      guards: [AuthGuard()],
    ),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: RegisterRoute.page, path: '/register'),
  ];
}

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final token = await SecureStorageManager.instance.getAccessToken();
    if (token != null) {
      resolver.next(true);
    } else {
      router.push(const LoginRoute());
    }
  }
}
