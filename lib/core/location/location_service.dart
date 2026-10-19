import 'dart:async';

import 'package:forest_breweries/core/location/coordinates.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

enum LocationUnavailableReason {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
}

class LocationUnavailableException implements Exception {
  const LocationUnavailableException(this.reason);

  final LocationUnavailableReason reason;
}

@lazySingleton
class LocationService {
  static const _timeLimit = Duration(seconds: 10);
  static const _maxLastKnownAge = Duration(minutes: 5);

  /// Throws [LocationUnavailableException] when the position can't be read.
  Future<Coordinates> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationUnavailableException(
        LocationUnavailableReason.serviceDisabled,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.denied:
        throw const LocationUnavailableException(
          LocationUnavailableReason.permissionDenied,
        );
      case LocationPermission.deniedForever:
        throw const LocationUnavailableException(
          LocationUnavailableReason.permissionDeniedForever,
        );
      case LocationPermission.whileInUse ||
          LocationPermission.always ||
          LocationPermission.unableToDetermine:
        break;
    }

    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      final isRecent =
          lastKnown != null &&
          DateTime.now().difference(lastKnown.timestamp) < _maxLastKnownAge;
      final position = isRecent
          ? lastKnown
          : await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
                timeLimit: _timeLimit,
              ),
            );
      return Coordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on TimeoutException {
      throw const LocationUnavailableException(
        LocationUnavailableReason.timeout,
      );
    } on LocationServiceDisabledException {
      throw const LocationUnavailableException(
        LocationUnavailableReason.serviceDisabled,
      );
    }
  }

  Future<void> openSettings(LocationUnavailableReason reason) async {
    if (reason == LocationUnavailableReason.serviceDisabled) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }
}
