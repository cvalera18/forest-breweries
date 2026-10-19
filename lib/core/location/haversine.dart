import 'dart:math';

import 'package:forest_breweries/core/location/coordinates.dart';

const _earthRadiusKm = 6371.0;

/// Great-circle distance between two points, in kilometers.
double haversineDistanceKm(Coordinates from, Coordinates to) {
  final dLat = _toRadians(to.latitude - from.latitude);
  final dLon = _toRadians(to.longitude - from.longitude);
  final a =
      pow(sin(dLat / 2), 2) +
      cos(_toRadians(from.latitude)) *
          cos(_toRadians(to.latitude)) *
          pow(sin(dLon / 2), 2);
  return 2 * _earthRadiusKm * asin(sqrt(a));
}

double _toRadians(double degrees) => degrees * pi / 180;
