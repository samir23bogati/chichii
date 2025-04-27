import 'package:equatable/equatable.dart';

abstract class FavoriteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoriteEvent {}

class ToggleFavorite extends FavoriteEvent {
  final Map<String, dynamic> item;

  ToggleFavorite(this.item);

  @override
  List<Object?> get props => [item];
}
