import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class FavoritesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ToggleFavorite extends FavoritesEvent {
  final Map<String, String> item;
  ToggleFavorite(this.item);

  @override
  List<Object> get props => [item];
}

class LoadFavorites extends FavoritesEvent {}

// State
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitialState extends FavoritesState {}

class FavoritesUpdatedState extends FavoritesState {
  final List<Map<String, String>> favorites;

  const FavoritesUpdatedState({required this.favorites});

  @override
  List<Object?> get props => [favorites];
}


// Bloc
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(FavoritesInitialState());
   @override
 Stream<FavoritesState> mapEventToState(FavoritesEvent event) async* {
    if (event is LoadFavorites) {
      final favorites = await _loadFavorites();
      yield FavoritesUpdatedState(favorites: favorites);
    } else if (event is ToggleFavorite) {
      final currentState = state;
      if (currentState is FavoritesUpdatedState) {
        final updatedFavorites = List<Map<String, String>>.from(currentState.favorites);
        final existingIndex = updatedFavorites.indexWhere((i) => i['id'] == event.item['id']);
        if (existingIndex != -1) {
          updatedFavorites.removeAt(existingIndex); // Remove if already a favorite
        } else {
          updatedFavorites.add(event.item); // Add if not a favorite
        }
        await _saveFavorites(updatedFavorites);
        yield FavoritesUpdatedState(favorites: updatedFavorites);
      }
    }
  }

  // Load favorites from SharedPreferences
  Future<List<Map<String, String>>> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedItems = prefs.getStringList('favorites');
    if (storedItems != null) {
      return storedItems.map((item) => Map<String, String>.from(jsonDecode(item))).toList();
    }
    return [];
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites(List<Map<String, String>> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedFavorites = favorites.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('favorites', encodedFavorites);
  }
}