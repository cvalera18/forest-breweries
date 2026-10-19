import 'package:flutter/material.dart';
import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';
import 'package:forest_breweries/features/breweries/presentation/brewery_type_label.dart';

class BreweryTypeBadge extends StatelessWidget {
  const BreweryTypeBadge({required this.type, this.large = false, super.key});

  final BreweryType type;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = large
        ? theme.textTheme.titleSmall
        : theme.textTheme.labelMedium;
    return Container(
      padding: large
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type.label,
        style: textStyle?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
