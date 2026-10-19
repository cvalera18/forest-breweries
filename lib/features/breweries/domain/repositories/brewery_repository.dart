import 'package:forest_breweries/core/error/app_exception.dart';
import 'package:forest_breweries/core/location/coordinates.dart';
import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';

/// Throws an [AppException] subtype when a request fails.
abstract interface class BreweryRepository {
  Future<List<Brewery>> getBreweries({
    required int page,
    required int perPage,
    Coordinates? near,
  });

  Future<Brewery> getBrewery(String id);
}
