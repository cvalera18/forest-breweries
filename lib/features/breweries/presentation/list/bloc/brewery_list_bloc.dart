import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_breweries/core/error/app_exception.dart';
import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';
import 'package:forest_breweries/features/breweries/domain/repositories/brewery_repository.dart';
import 'package:injectable/injectable.dart';

part 'brewery_list_event.dart';
part 'brewery_list_state.dart';

@injectable
class BreweryListBloc extends Bloc<BreweryListEvent, BreweryListState> {
  BreweryListBloc(this._repository) : super(const BreweryListInitial()) {
    on<BreweryListStarted>(_onStarted, transformer: droppable());
    on<BreweryListNextPageRequested>(
      _onNextPageRequested,
      transformer: droppable(),
    );
  }

  static const pageSize = 20;

  final BreweryRepository _repository;

  Future<void> _onStarted(
    BreweryListStarted event,
    Emitter<BreweryListState> emit,
  ) async {
    emit(const BreweryListLoading());
    try {
      final breweries = await _repository.getBreweries(
        page: 1,
        perPage: pageSize,
      );
      emit(
        breweries.isEmpty
            ? const BreweryListEmpty()
            : BreweryListLoaded(
                breweries: breweries,
                hasReachedMax: breweries.length < pageSize,
              ),
      );
    } on AppException catch (error) {
      emit(BreweryListFailure(error));
    }
  }

  Future<void> _onNextPageRequested(
    BreweryListNextPageRequested event,
    Emitter<BreweryListState> emit,
  ) async {
    final current = state;
    if (current is! BreweryListLoaded || current.hasReachedMax) return;

    emit(
      BreweryListLoaded(
        breweries: current.breweries,
        hasReachedMax: false,
        isLoadingMore: true,
      ),
    );
    try {
      final nextPage = current.breweries.length ~/ pageSize + 1;
      final breweries = await _repository.getBreweries(
        page: nextPage,
        perPage: pageSize,
      );
      emit(
        BreweryListLoaded(
          breweries: [...current.breweries, ...breweries],
          hasReachedMax: breweries.length < pageSize,
        ),
      );
    } on AppException catch (error) {
      emit(
        BreweryListLoaded(
          breweries: current.breweries,
          hasReachedMax: false,
          nextPageError: error,
        ),
      );
    }
  }
}
