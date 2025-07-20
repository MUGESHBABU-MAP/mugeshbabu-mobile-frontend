import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/cable_tv_screen.dart';
import '../screens/internet_screen.dart';
import '../screens/bill_payment_screen.dart';
import '../screens/support_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/services_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      // Check if user wants to skip login
      final prefs = await SharedPreferences.getInstance();
      final skipLogin = prefs.getBool('skip_login') ?? false;
      
      if (state.fullPath == '/') {
        return skipLogin ? '/home' : '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) async {
          final prefs = await SharedPreferences.getInstance();
          final skipLogin = prefs.getBool('skip_login') ?? false;
          return skipLogin ? '/home' : '/login';
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'cable-tv',
            name: 'cable-tv',
            builder: (context, state) => const CableTvScreen(),
          ),
          GoRoute(
            path: 'internet',
            name: 'internet',
            builder: (context, state) => const InternetScreen(),
          ),
          GoRoute(
            path: 'bill-payment',
            name: 'bill-payment',
            builder: (context, state) => const BillPaymentScreen(),
          ),
          GoRoute(
            path: 'support',
            name: 'support',
            builder: (context, state) => const SupportScreen(),
          ),
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'services',
            name: 'services',
            builder: (context, state) => const ServicesScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
