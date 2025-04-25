import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/common/favourites/fav_event.dart';
import 'package:padshala/common/favourites/fav_state.dart';


class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(FavoritesInitialState());

  List<Map<String, dynamic>> _favorites = [];

  @override
  Stream<FavoritesState> mapEventToState(FavoritesEvent event) async* {
    if (event is LoadFavorites) {
      // Load favorites from a local source (like SharedPreferences)
      yield FavoritesUpdatedState(_favorites);
    } else if (event is ToggleFavorite) {
      // Toggle favorite (add/remove item from favorites list)
      if (_favorites.contains(event.item)) {
        _favorites.remove(event.item);
      } else {
        _favorites.add(event.item);
      }
      yield FavoritesUpdatedState(_favorites);
    }
  }
}