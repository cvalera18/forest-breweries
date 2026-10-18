import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forest_breweries/core/error/app_exception.dart';
import 'package:forest_breweries/features/breweries/data/datasources/brewery_remote_data_source.dart';
import 'package:forest_breweries/features/breweries/data/models/brewery_dto.dart';
import 'package:forest_breweries/features/breweries/data/repositories/brewery_repository_impl.dart';
import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/brewery_fixtures.dart';

class _MockRemoteDataSource extends Mock implements BreweryRemoteDataSource {}

final _request = RequestOptions(path: '/breweries');

DioException _timeout() => DioException(
  requestOptions: _request,
  type: DioExceptionType.connectionTimeout,
);

DioException _httpError(int statusCode) => DioException(
  requestOptions: _request,
  type: DioExceptionType.badResponse,
  response: Response<Object?>(requestOptions: _request, statusCode: statusCode),
);

void main() {
  late _MockRemoteDataSource remoteDataSource;
  late BreweryRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _MockRemoteDataSource();
    repository = BreweryRepositoryImpl(remoteDataSource);
  });

  group('getBreweries', () {
    Future<List<Brewery>> getFirstPage() =>
        repository.getBreweries(page: 1, perPage: 20);

    test('returns entities mapped from DTOs', () async {
      when(
        () => remoteDataSource.fetchBreweries(page: 1, perPage: 20),
      ).thenAnswer((_) async => [BreweryDto.fromJson(breweryJson)]);

      final breweries = await getFirstPage();

      expect(breweries, [BreweryDto.fromJson(breweryJson).toEntity()]);
    });

    test('throws NetworkException on timeout', () {
      when(
        () => remoteDataSource.fetchBreweries(page: 1, perPage: 20),
      ).thenThrow(_timeout());

      expect(getFirstPage(), throwsA(isA<NetworkException>()));
    });

    test('throws ServerException with the status code on 5xx', () {
      when(
        () => remoteDataSource.fetchBreweries(page: 1, perPage: 20),
      ).thenThrow(_httpError(503));

      expect(
        getFirstPage(),
        throwsA(
          isA<ServerException>().having((e) => e.statusCode, 'statusCode', 503),
        ),
      );
    });

    test('throws UnexpectedException on a malformed payload', () {
      when(
        () => remoteDataSource.fetchBreweries(page: 1, perPage: 20),
      ).thenThrow(TypeError());

      expect(getFirstPage(), throwsA(isA<UnexpectedException>()));
    });
  });

  group('getBrewery', () {
    test('returns the mapped entity', () async {
      when(
        () => remoteDataSource.fetchBrewery('id'),
      ).thenAnswer((_) async => BreweryDto.fromJson(breweryJson));

      final brewery = await repository.getBrewery('id');

      expect(brewery.name, 'Antla Brewery');
    });

    test('throws NotFoundException on 404', () {
      when(
        () => remoteDataSource.fetchBrewery('missing'),
      ).thenThrow(_httpError(404));

      expect(
        repository.getBrewery('missing'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
