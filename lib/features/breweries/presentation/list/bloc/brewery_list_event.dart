part of 'brewery_list_bloc.dart';

sealed class BreweryListEvent {
  const BreweryListEvent();
}

final class BreweryListStarted extends BreweryListEvent {
  const BreweryListStarted();
}

final class BreweryListNextPageRequested extends BreweryListEvent {
  const BreweryListNextPageRequested();
}

final class BreweryListLocationRequested extends BreweryListEvent {
  const BreweryListLocationRequested();
}

final class BreweryListLocationSettingsRequested extends BreweryListEvent {
  const BreweryListLocationSettingsRequested();
}
