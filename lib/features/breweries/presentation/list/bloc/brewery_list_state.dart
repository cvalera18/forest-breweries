part of 'brewery_list_bloc.dart';

sealed class BreweryListState extends Equatable {
  const BreweryListState();

  @override
  List<Object?> get props => [];
}

final class BreweryListInitial extends BreweryListState {
  const BreweryListInitial();
}

final class BreweryListLoading extends BreweryListState {
  const BreweryListLoading();
}

final class BreweryListEmpty extends BreweryListState {
  const BreweryListEmpty();
}

final class BreweryListFailure extends BreweryListState {
  const BreweryListFailure(this.error);

  final AppException error;

  @override
  List<Object?> get props => [error];
}

final class BreweryListLoaded extends BreweryListState {
  const BreweryListLoaded({
    required this.breweries,
    required this.hasReachedMax,
    this.isLoadingMore = false,
    this.nextPageError,
  });

  final List<Brewery> breweries;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final AppException? nextPageError;

  bool get canLoadMore =>
      !hasReachedMax && !isLoadingMore && nextPageError == null;

  @override
  List<Object?> get props => [
    breweries,
    hasReachedMax,
    isLoadingMore,
    nextPageError,
  ];
}
