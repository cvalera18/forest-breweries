import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_breweries/core/error/app_exception.dart';
import 'package:forest_breweries/core/location/coordinates.dart';
import 'package:forest_breweries/core/location/haversine.dart';
import 'package:forest_breweries/core/location/location_service.dart';
import 'package:forest_breweries/core/widgets/error_view.dart';
import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';
import 'package:forest_breweries/features/breweries/presentation/list/bloc/brewery_list_bloc.dart';
import 'package:forest_breweries/features/breweries/presentation/list/widgets/location_banner.dart';
import 'package:forest_breweries/features/breweries/presentation/widgets/brewery_type_badge.dart';

class BreweryListPage extends StatelessWidget {
  const BreweryListPage({required this.onBreweryTap, super.key});

  final ValueChanged<Brewery> onBreweryTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breweries')),
      body: BlocBuilder<BreweryListBloc, BreweryListState>(
        builder: (context, state) => switch (state) {
          BreweryListInitial() || BreweryListLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          BreweryListEmpty() => const Center(
            child: Text('No breweries found.'),
          ),
          BreweryListFailure(:final error) => ErrorView(
            error: error,
            onRetry: () =>
                context.read<BreweryListBloc>().add(const BreweryListStarted()),
          ),
          BreweryListLoaded() => _BreweryListView(
            state: state,
            onBreweryTap: onBreweryTap,
          ),
        },
      ),
    );
  }
}

class _BreweryListView extends StatefulWidget {
  const _BreweryListView({required this.state, required this.onBreweryTap});

  final BreweryListLoaded state;
  final ValueChanged<Brewery> onBreweryTap;

  @override
  State<_BreweryListView> createState() => _BreweryListViewState();
}

class _BreweryListViewState extends State<_BreweryListView> {
  static const _loadMoreThreshold = 300.0;

  final _scrollController = ScrollController();
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _lifecycleListener = AppLifecycleListener(onResume: _onResume);
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Re-checks location when returning from the system settings.
  void _onResume() {
    final issue = widget.state.locationIssue;
    if (issue == LocationUnavailableReason.serviceDisabled ||
        issue == LocationUnavailableReason.permissionDeniedForever) {
      context.read<BreweryListBloc>().add(const BreweryListLocationRequested());
    }
  }

  void _onScroll() {
    final position = _scrollController.position;
    final isNearBottom =
        position.pixels >= position.maxScrollExtent - _loadMoreThreshold;
    if (isNearBottom && widget.state.canLoadMore) {
      context.read<BreweryListBloc>().add(const BreweryListNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final breweries = widget.state.breweries;
    final locationIssue = widget.state.locationIssue;
    return Column(
      children: [
        if (locationIssue != null)
          LocationBanner(
            reason: locationIssue,
            isLocating: widget.state.isLocating,
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: breweries.length + (widget.state.hasReachedMax ? 0 : 1),
            itemBuilder: (context, index) => index < breweries.length
                ? _BreweryTile(
                    brewery: breweries[index],
                    origin: widget.state.origin,
                    onTap: () => widget.onBreweryTap(breweries[index]),
                  )
                : _NextPageFooter(error: widget.state.nextPageError),
          ),
        ),
      ],
    );
  }
}

class _BreweryTile extends StatelessWidget {
  const _BreweryTile({required this.brewery, required this.onTap, this.origin});

  final Brewery brewery;
  final VoidCallback onTap;
  final Coordinates? origin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.onSurfaceVariant;
    final city = brewery.city;
    final distance = _distanceLabel();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brewery.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        BreweryTypeBadge(type: brewery.type),
                        if (city != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: secondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              city,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: secondaryColor,
                              ),
                            ),
                          ),
                        ] else
                          const Spacer(),
                        if (distance != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            distance,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: secondaryColor),
            ],
          ),
        ),
      ),
    );
  }

  /// Distance from [origin], or null when either point is unknown.
  String? _distanceLabel() {
    final origin = this.origin;
    final coordinates = brewery.coordinates;
    if (origin == null || coordinates == null) return null;
    final km = haversineDistanceKm(origin, coordinates);
    if (km < 1) return '${(km * 1000).round()} m';
    return km < 100 ? '${km.toStringAsFixed(1)} km' : '${km.round()} km';
  }
}

class _NextPageFooter extends StatelessWidget {
  const _NextPageFooter({required this.error});

  final AppException? error;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: error == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Text(error.userMessage, textAlign: TextAlign.center),
                TextButton(
                  onPressed: () => context.read<BreweryListBloc>().add(
                    const BreweryListNextPageRequested(),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
    );
  }
}
