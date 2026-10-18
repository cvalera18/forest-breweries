import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_breweries/core/di/injection.dart';
import 'package:forest_breweries/features/breweries/presentation/list/bloc/brewery_list_bloc.dart';
import 'package:forest_breweries/features/breweries/presentation/list/brewery_list_page.dart';

/// Builds each screen with its Bloc
abstract final class AppRouter {
  static Widget breweryList() => BlocProvider(
    create: (_) => getIt<BreweryListBloc>()..add(const BreweryListStarted()),
    child: const BreweryListPage(),
  );
}
