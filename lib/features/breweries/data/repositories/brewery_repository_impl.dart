import 'package:dio/dio.dart';
import 'package:forest_breweries/core/error/app_exception.dart';
import 'package:forest_breweries/core/network/dio_exception_mapper.dart';
import 'package:forest_breweries/features/breweries/data/datasources/brewery_remote_data_source.dart';
import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';
import 'package:forest_breweries/features/breweries/domain/repositories/brewery_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BreweryRepository)
class BreweryRepositoryImpl implements BreweryRepository {
  BreweryRepositoryImpl(this._remoteDataSource);

  final BreweryRemoteDataSource _remoteDataSource;

  @override
  Future<List<Brewery>> getBreweries({
    required int page,
    required int perPage,
  }) => _guard(() async {
    final dtos = await _remoteDataSource.fetchBreweries(
      page: page,
      perPage: perPage,
    );
    return dtos.map((dto) => dto.toEntity()).toList();
  });

  @override
  Future<Brewery> getBrewery(String id) => _guard(() async {
    final dto = await _remoteDataSource.fetchBrewery(id);
    return dto.toEntity();
  });

  /// Converts transport and parsing failures into [AppException] subtypes.
  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw e.toAppException();
    } on TypeError catch (e) {
      throw UnexpectedException(e);
    }
  }
}
