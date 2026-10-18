import 'package:dio/dio.dart';
import 'package:forest_breweries/features/breweries/data/models/brewery_dto.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class BreweryRemoteDataSource {
  BreweryRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<BreweryDto>> fetchBreweries({
    required int page,
    required int perPage,
  }) async {
    final response = await _dio.get<Object?>(
      '/breweries',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final items = response.data as List<dynamic>;
    return items
        .map((item) => BreweryDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BreweryDto> fetchBrewery(String id) async {
    final response = await _dio.get<Object?>('/breweries/$id');
    return BreweryDto.fromJson(response.data as Map<String, dynamic>);
  }
}
