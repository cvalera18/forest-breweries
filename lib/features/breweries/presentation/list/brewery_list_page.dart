import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_breweries/core/error/app_exception.dart';
import 'package:forest_breweries/core/widgets/error_view.dart';
import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';
import 'package:forest_breweries/features/breweries/presentation/brewery_type_label.dart';
import 'package:forest_breweries/features/breweries/presentation/list/bloc/brewery_list_bloc.dart';

class BreweryListPage extends StatelessWidget {
  const BreweryListPage({super.key});

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
          BreweryListLoaded() => _BreweryListView(state: state),
        },
      ),
    );
  }
}

class _BreweryListView extends StatefulWidget {
  const _BreweryListView({required this.state});

  final BreweryListLoaded state;

  @override
  State<_BreweryListView> createState() => _BreweryListViewState();
}

class _BreweryListViewState extends State<_BreweryListView> {
  static const _loadMoreThreshold = 300.0;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: breweries.length + (widget.state.hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) => index < breweries.length
          ? _BreweryTile(brewery: breweries[index])
          : _NextPageFooter(error: widget.state.nextPageError),
    );
  }
}

class _BreweryTile extends StatelessWidget {
  const _BreweryTile({required this.brewery});

  final Brewery brewery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.onSurfaceVariant;
    final city = brewery.city;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                _TypeBadge(label: brewery.type.label),
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
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
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
