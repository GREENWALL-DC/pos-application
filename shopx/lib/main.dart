import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopx/application/auth/auth_notifier.dart';
import 'package:shopx/application/auth/auth_state.dart';
import 'package:shopx/application/dashboard/admin_dashboard_notifier.dart';
import 'package:shopx/presentation/auth/selection/selection_screen.dart';
import 'package:shopx/presentation/dashboard/admin/admin_dashboard.dart';
import 'package:shopx/presentation/dashboard/user/user_dashboard.dart';
import 'package:shopx/presentation/splash/splash_screen.dart';
import 'package:shopx/widget/internet/no_internet_screen.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    Widget home;

    // if (authState.isInitializing) {
    //   home = const SplashScreen();
    // } else if (authState.isAuthenticated) {
    //   if (authState.user!.userType == "admin") {
    //     home = const AdminDashboard();
    //   } else {
    //     home = const UserDashboard();
    //   }
    // } else {
    //   home = const SelectionScreen();
    // }
    if (authState.isInitializing) {
      home = const SplashScreen();
    }
    // 🔥 NEW: No Internet case
    else if (authState.error != null && authState.user != null) {
      home = const NoInternetScreen();
    }
    // Normal authenticated flow
    else if (authState.isAuthenticated) {
      if (authState.user!.userType == "admin") {
        home = const AdminDashboard();
      } else {
        home = const UserDashboard();
      }
    }
    // Logged out
    else {
      home = const SelectionScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sellops',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
      ),

      // Register all named routes used in the app
      routes: {"/login": (_) => const SelectionScreen()},

      home: home,

      //     Builder(
      //   builder: (context) {
      //     return Consumer(
      //       builder: (context, ref, _) {
      //         final authState = ref.watch(authNotifierProvider);

      //         if (authState.isLoading) {
      //           return const Scaffold(
      //             body: Center(child: CircularProgressIndicator()),
      //           );
      //         }

      //         // If NOT logged in → show SelectionScreen
      //         if (authState.user == null && authState.token == null) {
      //           return const SelectionScreen();
      //         }

      //         final user = authState.user;

      //         if (user?.userType == "admin") {

      //           return const AdminDashboard();
      //         } else {
      //           return const UserDashboard();
      //         }
      //       },
      //     );

      //   },
      // ),
    );
  }
}
