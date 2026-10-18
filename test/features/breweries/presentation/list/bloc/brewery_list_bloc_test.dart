import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forest_breweries/core/error/app_exception.dart';
import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';
import 'package:forest_breweries/features/breweries/domain/repositories/brewery_repository.dart';
import 'package:forest_breweries/features/breweries/presentation/list/bloc/brewery_list_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockBreweryRepository extends Mock implements BreweryRepository {}

List<Brewery> _breweries(int count, {int offset = 0}) => List.generate(
  count,
  (index) => Brewery(
    id: '${offset + index}',
    name: 'Brewery ${offset + index}',
    type: BreweryType.micro,
  ),
);

void main() {
  const pageSize = BreweryListBloc.pageSize;
  final firstPage = _breweries(pageSize);

  late _MockBreweryRepository repository;

  setUp(() {
    repository = _MockBreweryRepository();
  });

  group('BreweryListStarted', () {
    blocTest<BreweryListBloc, BreweryListState>(
      'emits [Loading, Loaded] when the first page loads',
      setUp: () {
        when(
          () => repository.getBreweries(page: 1, perPage: pageSize),
        ).thenAnswer((_) async => firstPage);
      },
      build: () => BreweryListBloc(repository),
      act: (bloc) => bloc.add(const BreweryListStarted()),
      expect: () => [
        const BreweryListLoading(),
        BreweryListLoaded(breweries: firstPage, hasReachedMax: false),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'emits [Loading, Failure] when the request fails',
      setUp: () {
        when(
          () => repository.getBreweries(page: 1, perPage: pageSize),
        ).thenThrow(const NetworkException());
      },
      build: () => BreweryListBloc(repository),
      act: (bloc) => bloc.add(const BreweryListStarted()),
      expect: () => const [
        BreweryListLoading(),
        BreweryListFailure(NetworkException()),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'emits [Loading, Empty] when there are no breweries',
      setUp: () {
        when(
          () => repository.getBreweries(page: 1, perPage: pageSize),
        ).thenAnswer((_) async => []);
      },
      build: () => BreweryListBloc(repository),
      act: (bloc) => bloc.add(const BreweryListStarted()),
      expect: () => const [BreweryListLoading(), BreweryListEmpty()],
    );
  });

  group('BreweryListNextPageRequested', () {
    blocTest<BreweryListBloc, BreweryListState>(
      'appends the next page to the loaded breweries',
      setUp: () {
        when(
          () => repository.getBreweries(page: 2, perPage: pageSize),
        ).thenAnswer((_) async => _breweries(pageSize, offset: pageSize));
      },
      build: () => BreweryListBloc(repository),
      seed: () => BreweryListLoaded(breweries: firstPage, hasReachedMax: false),
      act: (bloc) => bloc.add(const BreweryListNextPageRequested()),
      expect: () => [
        BreweryListLoaded(
          breweries: firstPage,
          hasReachedMax: false,
          isLoadingMore: true,
        ),
        BreweryListLoaded(
          breweries: _breweries(pageSize * 2),
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'keeps the loaded breweries when the next page fails',
      setUp: () {
        when(
          () => repository.getBreweries(page: 2, perPage: pageSize),
        ).thenThrow(const NetworkException());
      },
      build: () => BreweryListBloc(repository),
      seed: () => BreweryListLoaded(breweries: firstPage, hasReachedMax: false),
      act: (bloc) => bloc.add(const BreweryListNextPageRequested()),
      skip: 1,
      expect: () => [
        BreweryListLoaded(
          breweries: firstPage,
          hasReachedMax: false,
          nextPageError: const NetworkException(),
        ),
      ],
    );
  });
}
