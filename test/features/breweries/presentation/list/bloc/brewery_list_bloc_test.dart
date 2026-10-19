import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forest_breweries/core/error/app_exception.dart';
import 'package:forest_breweries/core/location/coordinates.dart';
import 'package:forest_breweries/core/location/location_service.dart';
import 'package:forest_breweries/features/breweries/domain/entities/brewery.dart';
import 'package:forest_breweries/features/breweries/domain/repositories/brewery_repository.dart';
import 'package:forest_breweries/features/breweries/presentation/list/bloc/brewery_list_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockBreweryRepository extends Mock implements BreweryRepository {}

class _MockLocationService extends Mock implements LocationService {}

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
  const london = Coordinates(latitude: 51.5074, longitude: -0.1278);
  final firstPage = _breweries(pageSize);

  late _MockBreweryRepository repository;
  late _MockLocationService locationService;

  setUp(() {
    repository = _MockBreweryRepository();
    locationService = _MockLocationService();
    when(
      () => locationService.getCurrentPosition(),
    ).thenAnswer((_) async => london);
  });

  BreweryListBloc buildBloc() => BreweryListBloc(repository, locationService);

  group('BreweryListStarted', () {
    blocTest<BreweryListBloc, BreweryListState>(
      'emits [Loading, Loaded] sorted by distance to the user',
      setUp: () {
        when(
          () =>
              repository.getBreweries(page: 1, perPage: pageSize, near: london),
        ).thenAnswer((_) async => firstPage);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const BreweryListStarted()),
      expect: () => [
        const BreweryListLoading(),
        BreweryListLoaded(
          breweries: firstPage,
          hasReachedMax: false,
          origin: london,
        ),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'falls back to the default order when location is unavailable',
      setUp: () {
        when(() => locationService.getCurrentPosition()).thenThrow(
          const LocationUnavailableException(
            LocationUnavailableReason.permissionDenied,
          ),
        );
        when(
          () => repository.getBreweries(page: 1, perPage: pageSize),
        ).thenAnswer((_) async => firstPage);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const BreweryListStarted()),
      expect: () => [
        const BreweryListLoading(),
        BreweryListLoaded(
          breweries: firstPage,
          hasReachedMax: false,
          locationIssue: LocationUnavailableReason.permissionDenied,
        ),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'emits [Loading, Failure] when the request fails',
      setUp: () {
        when(
          () =>
              repository.getBreweries(page: 1, perPage: pageSize, near: london),
        ).thenThrow(const NetworkException());
      },
      build: buildBloc,
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
          () =>
              repository.getBreweries(page: 1, perPage: pageSize, near: london),
        ).thenAnswer((_) async => []);
      },
      build: buildBloc,
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
      build: buildBloc,
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
      build: buildBloc,
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
