import 'package:flutter/material.dart';
import 'package:forest_breweries/app/app.dart';
import 'package:forest_breweries/core/di/injection.dart';

void main() {
  configureDependencies();
  runApp(const App());
}
