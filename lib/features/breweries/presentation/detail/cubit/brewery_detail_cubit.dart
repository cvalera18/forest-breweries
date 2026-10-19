import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_breweries/core/error/app_exception.dart';
import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';
import 'package:forest_breweries/features/breweries/domain/repositories/brewery_repository.dart';
import 'package:injectable/injectable.dart';

part 'brewery_detail_state.dart';

@injectable
class BreweryDetailCubit extends Cubit<BreweryDetailState> {
  BreweryDetailCubit(this._repository) : super(const BreweryDetailInitial());

  final BreweryRepository _repository;

  Future<void> load(String id) async {
    emit(const BreweryDetailLoading());
    try {
      final brewery = await _repository.getBrewery(id);
      emit(BreweryDetailLoaded(brewery));
    } on AppException catch (error) {
      emit(BreweryDetailFailure(error));
    }
  }
}
