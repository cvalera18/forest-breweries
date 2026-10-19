import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_breweries/core/widgets/error_view.dart';
import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';
import 'package:forest_breweries/features/breweries/presentation/detail/cubit/brewery_detail_cubit.dart';
import 'package:forest_breweries/features/breweries/presentation/widgets/brewery_type_badge.dart';

class BreweryDetailPage extends StatelessWidget {
  const BreweryDetailPage({
    required this.breweryId,
    required this.breweryName,
    super.key,
  });

  final String breweryId;
  final String breweryName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(breweryName)),
      body: BlocBuilder<BreweryDetailCubit, BreweryDetailState>(
        builder: (context, state) => switch (state) {
          BreweryDetailInitial() || BreweryDetailLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          BreweryDetailFailure(:final error) => ErrorView(
            error: error,
            onRetry: () => context.read<BreweryDetailCubit>().load(breweryId),
          ),
          BreweryDetailLoaded(:final brewery) => _BreweryDetails(
            brewery: brewery,
          ),
        },
      ),
    );
  }
}

class _BreweryDetails extends StatelessWidget {
  const _BreweryDetails({required this.brewery});

  final Brewery brewery;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: BreweryTypeBadge(type: brewery.type, large: true),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: _formatAddress(brewery),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: brewery.phone,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoTile(
                icon: Icons.language,
                label: 'Website',
                value: brewery.websiteUrl,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Joins the available address parts into lines, or null if none exist.
  static String? _formatAddress(Brewery brewery) {
    final locality = [
      brewery.city,
      brewery.stateProvince,
      brewery.postalCode,
    ].nonNulls.join(', ');
    final lines = [
      brewery.street,
      locality,
      brewery.country,
    ].nonNulls.where((line) => line.isNotEmpty);
    return lines.isEmpty ? null : lines.join('\n');
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, this.value});

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value ?? 'Not available'),
    );
  }
}
