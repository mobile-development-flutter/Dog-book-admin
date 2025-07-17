// routers/router.dart

import 'package:admin/admin_auth/login_page.dart';
import 'package:admin/admin_auth/register_page.dart';
import 'package:admin/pages/notifications.dart';
import 'package:admin/pages/profile.dart';
import 'package:admin/pages/shop.dart';
import 'package:go_router/go_router.dart';
import 'package:admin/pages/landing.dart';
import 'package:admin/pages/adminHome.dart';
// import other admin pages as needed

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/landing',
    routes: [
      GoRoute(path: '/landing', builder: (context, state) => const Landing()),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminLoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const AdminRegisterPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const AdminHome()),
      GoRoute(path: '/shops', builder: (context, state) => const Shops()),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const Notifications(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const AdminProfilePage(),
      ),
    ],
  );
}
