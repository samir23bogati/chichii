import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/common/favourites/fav_event.dart';
import 'package:padshala/common/favourites/fav_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  List<Map<String, dynamic>> _favorites = [];

  FavoriteBloc() : super(FavoriteInitialState()) {
    on<LoadFavorites>((event, emit) {
      emit(FavoriteUpdatedState(_favorites));
    });

    on<ToggleFavorite>((event, emit) {
      if (_favorites.contains(event.item)) {
        _favorites.remove(event.item);
      } else {
        _favorites.add(event.item);
      }
      emit(FavoriteUpdatedState(List.from(_favorites)));
    });
  }
}
