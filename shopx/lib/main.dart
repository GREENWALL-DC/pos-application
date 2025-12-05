import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopx/presentation/auth/selection/selection_screen.dart';
import 'package:shopx/presentation/cart/cart_success_screen.dart';
import 'package:shopx/presentation/products/add_product_screen.dart';

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
      home:  SelectionScreen()
      // home: AddProductScreen(),
    
    );
  }
}
/*
lib/
 ├── application/
 │     └── products/
 │           ├── product_notifier.dart
 │           └── product_state.dart
 │
 ├── domain/
 │     └── products/
 │           ├── product.dart
 │           └── i_product_repository.dart
 │
 ├── infrastructure/
 │     └── products/
 │           ├── product_api.dart
 │           └── product_repository.dart
 │
 └── presentation/
       └── products/
             ├── add_product/
             │      ├── add_product_screen.dart
             │      └── widgets/
             │             ├── product_form.dart
             │             └── product_image_picker.dart
             │
             ├── dashboard/
             │      ├── product_dashboard_screen.dart
             │      └── widgets/
             │             ├── product_grid_item.dart
             │             ├── product_list_item.dart
             │             └── product_search_bar.dart

*/