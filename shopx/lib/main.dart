import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopx/presentation/auth/login_screen.dart';

void main() {
  runApp(
    ProviderScope(
      child:  MyApp(),
      ),
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // back button + title color
          elevation: 0, // remove shadow
        ),
      ),
      home:  LoginScreen(),
    );
  }
}
