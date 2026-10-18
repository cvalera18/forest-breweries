import 'package:flutter_test/flutter_test.dart';
import 'package:forest_breweries/features/breweries/data/models/brewery_dto.dart';
import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';

import '../../../../fixtures/brewery_fixtures.dart';

void main() {
  group('BreweryDto', () {
    test('maps a complete payload to an entity', () {
      final brewery = BreweryDto.fromJson(breweryJson).toEntity();

      expect(
        brewery,
        const Brewery(
          id: 'ae7b3174-8be8-4d53-a3a5-9b8240970eea',
          name: 'Antla Brewery',
          type: BreweryType.brewpub,
          street: 'Friesener Straße 1',
          city: 'Kronach',
          stateProvince: 'Bayern',
          postalCode: '96317',
          country: 'Germany',
          phone: '+49 9261 628000',
          websiteUrl: 'http://www.antla.de',
          latitude: 50.241246,
          longitude: 11.327765,
        ),
      );
    });

    test('keeps missing fields as null and falls back to unknown type', () {
      final brewery = BreweryDto.fromJson(sparseBreweryJson).toEntity();

      expect(brewery.type, BreweryType.unknown);
      expect(brewery.street, isNull);
      expect(brewery.phone, isNull);
      expect(brewery.websiteUrl, isNull);
      expect(brewery.latitude, isNull);
      expect(brewery.longitude, isNull);
    });
  });
}
