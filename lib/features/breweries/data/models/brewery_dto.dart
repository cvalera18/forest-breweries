import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';

class BreweryDto {
  const BreweryDto({
    required this.id,
    required this.name,
    this.breweryType,
    this.address1,
    this.city,
    this.stateProvince,
    this.postalCode,
    this.country,
    this.phone,
    this.websiteUrl,
    this.latitude,
    this.longitude,
  });

  factory BreweryDto.fromJson(Map<String, dynamic> json) => BreweryDto(
    id: json['id'] as String,
    name: json['name'] as String,
    breweryType: json['brewery_type'] as String?,
    address1: json['address_1'] as String?,
    city: json['city'] as String?,
    stateProvince: json['state_province'] as String?,
    postalCode: json['postal_code'] as String?,
    country: json['country'] as String?,
    phone: json['phone'] as String?,
    websiteUrl: json['website_url'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );

  final String id;
  final String name;
  final String? breweryType;
  final String? address1;
  final String? city;
  final String? stateProvince;
  final String? postalCode;
  final String? country;
  final String? phone;
  final String? websiteUrl;
  final double? latitude;
  final double? longitude;

  Brewery toEntity() => Brewery(
    id: id,
    name: name,
    type: BreweryType.values.asNameMap()[breweryType] ?? BreweryType.unknown,
    street: address1,
    city: city,
    stateProvince: stateProvince,
    postalCode: postalCode,
    country: country,
    phone: phone,
    websiteUrl: websiteUrl,
    latitude: latitude,
    longitude: longitude,
  );
}
