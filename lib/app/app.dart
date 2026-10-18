import 'package:flutter/material.dart';
import 'package:forest_breweries/app/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  static const _seedColor = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breweries',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: _seedColor),
      darkTheme: ThemeData(
        colorSchemeSeed: _seedColor,
        brightness: Brightness.dark,
      ),
      home: AppRouter.breweryList(),
    );
  }
}
