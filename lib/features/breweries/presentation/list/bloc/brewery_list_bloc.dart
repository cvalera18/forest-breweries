import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_breweries/core/error/app_exception.dart';
import 'package:forest_breweries/core/location/coordinates.dart';
import 'package:forest_breweries/core/location/location_service.dart';
import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';
import 'package:forest_breweries/features/breweries/domain/repositories/brewery_repository.dart';
import 'package:injectable/injectable.dart';

part 'brewery_list_event.dart';
part 'brewery_list_state.dart';

@injectable
class BreweryListBloc extends Bloc<BreweryListEvent, BreweryListState> {
  BreweryListBloc(this._repository, this._locationService)
    : super(const BreweryListInitial()) {
    on<BreweryListStarted>(_onStarted, transformer: droppable());
    on<BreweryListNextPageRequested>(
      _onNextPageRequested,
      transformer: droppable(),
    );
    on<BreweryListLocationRequested>(
      _onLocationRequested,
      transformer: droppable(),
    );
    on<BreweryListLocationSettingsRequested>(_onLocationSettingsRequested);
  }

  static const pageSize = 20;

  final BreweryRepository _repository;
  final LocationService _locationService;

  Coordinates? _origin;
  LocationUnavailableReason? _locationIssue;

  bool get _hasResolvedLocation => _origin != null || _locationIssue != null;

  Future<void> _onStarted(
    BreweryListStarted event,
    Emitter<BreweryListState> emit,
  ) async {
    emit(const BreweryListLoading());
    if (!_hasResolvedLocation) await _resolveLocation();
    await _loadFirstPage(emit);
  }

  Future<void> _onNextPageRequested(
    BreweryListNextPageRequested event,
    Emitter<BreweryListState> emit,
  ) async {
    final current = state;
    if (current is! BreweryListLoaded ||
        current.hasReachedMax ||
        current.isLocating) {
      return;
    }

    emit(_loaded(current.breweries, hasReachedMax: false, isLoadingMore: true));
    try {
      final nextPage = current.breweries.length ~/ pageSize + 1;
      final breweries = await _repository.getBreweries(
        page: nextPage,
        perPage: pageSize,
        near: _origin,
      );
      final allBreweries = [...current.breweries, ...breweries];
      emit(_loaded(allBreweries, hasReachedMax: breweries.length < pageSize));
    } on AppException catch (error) {
      emit(
        _loaded(current.breweries, hasReachedMax: false, nextPageError: error),
      );
    }
  }

  Future<void> _onLocationRequested(
    BreweryListLocationRequested event,
    Emitter<BreweryListState> emit,
  ) async {
    final current = state;
    if (current is! BreweryListLoaded) return;

    emit(
      BreweryListLoaded(
        breweries: current.breweries,
        hasReachedMax: current.hasReachedMax,
        nextPageError: current.nextPageError,
        origin: current.origin,
        locationIssue: current.locationIssue,
        isLocating: true,
      ),
    );
    await _resolveLocation();
    if (_origin == null) {
      emit(
        _loaded(
          current.breweries,
          hasReachedMax: current.hasReachedMax,
          nextPageError: current.nextPageError,
        ),
      );
      return;
    }
    emit(const BreweryListLoading());
    await _loadFirstPage(emit);
  }

  Future<void> _onLocationSettingsRequested(
    BreweryListLocationSettingsRequested event,
    Emitter<BreweryListState> emit,
  ) async {
    final issue = _locationIssue;
    if (issue != null) await _locationService.openSettings(issue);
  }

  Future<void> _resolveLocation() async {
    try {
      _origin = await _locationService.getCurrentPosition();
      _locationIssue = null;
    } on LocationUnavailableException catch (error) {
      _origin = null;
      _locationIssue = error.reason;
    }
  }

  Future<void> _loadFirstPage(Emitter<BreweryListState> emit) async {
    try {
      final breweries = await _repository.getBreweries(
        page: 1,
        perPage: pageSize,
        near: _origin,
      );
      emit(
        breweries.isEmpty
            ? const BreweryListEmpty()
            : _loaded(breweries, hasReachedMax: breweries.length < pageSize),
      );
    } on AppException catch (error) {
      emit(BreweryListFailure(error));
    }
  }

  BreweryListLoaded _loaded(
    List<Brewery> breweries, {
    required bool hasReachedMax,
    bool isLoadingMore = false,
    AppException? nextPageError,
  }) => BreweryListLoaded(
    breweries: breweries,
    hasReachedMax: hasReachedMax,
    isLoadingMore: isLoadingMore,
    nextPageError: nextPageError,
    origin: _origin,
    locationIssue: _locationIssue,
  );
}
