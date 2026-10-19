import 'package:flutter_test/flutter_test.dart';
import 'package:forest_breweries/core/location/coordinates.dart';
import 'package:forest_breweries/core/location/haversine.dart';

void main() {
  const london = Coordinates(latitude: 51.5074, longitude: -0.1278);
  const paris = Coordinates(latitude: 48.8566, longitude: 2.3522);

  test('returns the great-circle distance between two cities', () {
    expect(haversineDistanceKm(london, paris), closeTo(343.5, 1));
  });

  test('returns zero for the same point', () {
    expect(haversineDistanceKm(london, london), 0);
  });
}
