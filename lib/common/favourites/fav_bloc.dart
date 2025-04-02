import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class FavoritesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ToggleFavorite extends FavoritesEvent {
  final String itemId;
  ToggleFavorite(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class LoadFavorites extends FavoritesEvent {} // Event to load favorites

// State
class FavoritesState extends Equatable {
  final Set<String> favorites;

  const FavoritesState(this.favorites);

  @override
  List<Object> get props => [favorites];
}

// Bloc
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(const FavoritesState({})) {
    _loadFavorites(); // Load favorites when Bloc is created
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList('favorites') ?? [];
    add(LoadFavorites()); // Dispatch event to update UI
    emit(FavoritesState(favList.toSet())); // Convert List to Set
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favorites.toList());
  }

  @override
  Stream<FavoritesState> mapEventToState(FavoritesEvent event) async* {
    if (event is LoadFavorites) {
      yield state; // Just re-emit the loaded favorites
    } else if (event is ToggleFavorite) {
      final updatedFavorites = Set<String>.from(state.favorites);
      if (updatedFavorites.contains(event.itemId)) {
        updatedFavorites.remove(event.itemId);
      } else {
        updatedFavorites.add(event.itemId);
      }
      await _saveFavorites(updatedFavorites); // Save to SharedPreferences
      yield FavoritesState(updatedFavorites);
    }
  }
}
