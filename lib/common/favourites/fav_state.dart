import 'package:equatable/equatable.dart';

abstract class FavoriteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FavoriteInitialState extends FavoriteState {}

class FavoriteUpdatedState extends FavoriteState {
  final List<Map<String, dynamic>> favorites;

  FavoriteUpdatedState(this.favorites);

  @override
  List<Object?> get props => [favorites];
}
