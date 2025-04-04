import 'package:equatable/equatable.dart';

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
