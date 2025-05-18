import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/common/favourites/fav_event.dart';
import 'package:padshala/common/favourites/fav_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  List<Map<String, dynamic>> _favorites = [];

  FavoriteBloc() : super(FavoriteInitialState()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  void _onLoadFavorites(LoadFavorites event, Emitter<FavoriteState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final savedTitles = prefs.getStringList('favoriteItems') ?? [];

    // Here you would ideally load menu data and match titles.
    // For now, we just keep the existing _favorites.
    emit(FavoriteUpdatedState(_favorites));
  }

  void _onToggleFavorite(ToggleFavorite event, Emitter<FavoriteState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final favTitles = prefs.getStringList('favoriteItems') ?? [];

    final existingIndex = _favorites.indexWhere((item) => item['title'] == event.item['title']);
    final isFav = existingIndex != -1;

    if (isFav) {
      _favorites.removeAt(existingIndex);
      favTitles.remove(event.item['title']);
    } else {
      _favorites.add(event.item);
      favTitles.add(event.item['title']);
    }

    await prefs.setStringList('favoriteItems', favTitles);

    emit(FavoriteUpdatedState(List.from(_favorites)));
  }
}
