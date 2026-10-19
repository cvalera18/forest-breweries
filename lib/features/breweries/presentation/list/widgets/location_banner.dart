import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_breweries/core/location/location_service.dart';
import 'package:forest_breweries/features/breweries/presentation/list/bloc/brewery_list_bloc.dart';

class LocationBanner extends StatelessWidget {
  const LocationBanner({
    required this.reason,
    required this.isLocating,
    super.key,
  });

  final LocationUnavailableReason reason;
  final bool isLocating;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BreweryListBloc>();
    final (message, action) = switch (reason) {
      LocationUnavailableReason.serviceDisabled => (
        'Turn on location to see the closest breweries first.',
        'Settings',
      ),
      LocationUnavailableReason.permissionDenied => (
        'Allow location access to see the closest breweries first.',
        'Allow',
      ),
      LocationUnavailableReason.permissionDeniedForever => (
        'Location access is blocked. Enable it in Settings to see the '
            'closest breweries first.',
        'Settings',
      ),
      LocationUnavailableReason.timeout => (
        "We couldn't get your location.",
        'Try again',
      ),
    };
    final opensSettings =
        reason == LocationUnavailableReason.serviceDisabled ||
        reason == LocationUnavailableReason.permissionDeniedForever;

    return MaterialBanner(
      leading: const Icon(Icons.location_off_outlined),
      content: Text(message),
      actions: [
        if (isLocating)
          const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          TextButton(
            onPressed: () => bloc.add(
              opensSettings
                  ? const BreweryListLocationSettingsRequested()
                  : const BreweryListLocationRequested(),
            ),
            child: Text(action),
          ),
      ],
    );
  }
}
