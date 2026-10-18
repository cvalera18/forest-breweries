import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';

extension BreweryTypeLabel on BreweryType {
  String get label => switch (this) {
    BreweryType.micro => 'Micro',
    BreweryType.nano => 'Nano',
    BreweryType.regional => 'Regional',
    BreweryType.brewpub => 'Brewpub',
    BreweryType.large => 'Large',
    BreweryType.planning => 'Planning',
    BreweryType.bar => 'Bar',
    BreweryType.contract => 'Contract',
    BreweryType.proprietor => 'Proprietor',
    BreweryType.closed => 'Closed',
    BreweryType.taproom => 'Taproom',
    BreweryType.cidery => 'Cidery',
    BreweryType.beergarden => 'Beer garden',
    BreweryType.unknown => 'Unknown',
  };
}
