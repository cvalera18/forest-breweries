import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_breweries/core/di/injection.dart';
import 'package:forest_breweries/features/breweries/presentation/detail/brewery_detail_page.dart';
import 'package:forest_breweries/features/breweries/presentation/detail/cubit/brewery_detail_cubit.dart';
import 'package:forest_breweries/features/breweries/presentation/list/bloc/brewery_list_bloc.dart';
import 'package:forest_breweries/features/breweries/presentation/list/brewery_list_page.dart';

/// Builds each screen with its Bloc
abstract final class AppRouter {
  static Widget breweryList() => BlocProvider(
    create: (_) => getIt<BreweryListBloc>()..add(const BreweryListStarted()),
    child: Builder(
      builder: (context) => BreweryListPage(
        onBreweryTap: (brewery) => Navigator.of(
          context,
        ).push(breweryDetail(id: brewery.id, name: brewery.name)),
      ),
    ),
  );

  static Route<void> breweryDetail({
    required String id,
    required String name,
  }) => MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => getIt<BreweryDetailCubit>()..load(id),
      child: BreweryDetailPage(breweryId: id, breweryName: name),
    ),
  );
}
