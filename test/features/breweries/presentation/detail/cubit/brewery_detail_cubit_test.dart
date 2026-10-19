import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forest_breweries/core/error/app_exception.dart';
import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';
import 'package:forest_breweries/features/breweries/domain/repositories/brewery_repository.dart';
import 'package:forest_breweries/features/breweries/presentation/detail/cubit/brewery_detail_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockBreweryRepository extends Mock implements BreweryRepository {}

void main() {
  const brewery = Brewery(
    id: 'brewery-1',
    name: 'Antla Brewery',
    type: BreweryType.brewpub,
    phone: '+49 9261 628000',
  );

  late _MockBreweryRepository repository;

  setUp(() {
    repository = _MockBreweryRepository();
  });

  blocTest<BreweryDetailCubit, BreweryDetailState>(
    'emits [Loading, Loaded] when the brewery loads',
    setUp: () {
      when(
        () => repository.getBrewery('brewery-1'),
      ).thenAnswer((_) async => brewery);
    },
    build: () => BreweryDetailCubit(repository),
    act: (cubit) => cubit.load('brewery-1'),
    expect: () => const [BreweryDetailLoading(), BreweryDetailLoaded(brewery)],
  );

  blocTest<BreweryDetailCubit, BreweryDetailState>(
    'emits [Loading, Failure] when the brewery does not exist',
    setUp: () {
      when(
        () => repository.getBrewery('missing'),
      ).thenThrow(const NotFoundException());
    },
    build: () => BreweryDetailCubit(repository),
    act: (cubit) => cubit.load('missing'),
    expect: () => const [
      BreweryDetailLoading(),
      BreweryDetailFailure(NotFoundException()),
    ],
  );
}
