import 'package:equatable/equatable.dart';

class FavoritesState extends Equatable {
  final List<Map<String, String>> favorites;

  const FavoritesState(this.favorites);

  @override
  List<Object> get props => [favorites];
}
