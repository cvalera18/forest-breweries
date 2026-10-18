// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:forest_breweries/core/di/network_module.dart' as _i3;
import 'package:forest_breweries/features/breweries/data/datasources/brewery_remote_data_source.dart'
    as _i755;
import 'package:forest_breweries/features/breweries/data/repositories/brewery_repository_impl.dart'
    as _i1051;
import 'package:forest_breweries/features/breweries/domain/repositories/brewery_repository.dart'
    as _i592;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i755.BreweryRemoteDataSource>(
      () => _i755.BreweryRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i592.BreweryRepository>(
      () => _i1051.BreweryRepositoryImpl(gh<_i755.BreweryRemoteDataSource>()),
    );
    return this;
  }
}

class _$NetworkModule extends _i3.NetworkModule {}
