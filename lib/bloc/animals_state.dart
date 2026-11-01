import '../domain/entities/animal.dart';

sealed class AnimalsState {}

class AnimalsLoadInProgress extends AnimalsState {}

class AnimalsLoadSuccess extends AnimalsState {
  final List<Animal> animals;
  final Set<String> likedIds;
  final bool onlyFavorites;

  AnimalsLoadSuccess({
    required this.animals,
    this.likedIds = const <String>{},
    this.onlyFavorites = false,
  });

  AnimalsLoadSuccess copyWith({
    List<Animal>? animals,
    Set<String>? likedIds,
    bool? onlyFavorites,
  }) {
    return AnimalsLoadSuccess(
      animals: animals ?? this.animals,
      likedIds: likedIds ?? this.likedIds,
      onlyFavorites: onlyFavorites ?? this.onlyFavorites,
    );
  }

  List<Animal> get visibleAnimals => onlyFavorites
      ? animals.where((animal) => likedIds.contains(animal.id)).toList()
      : animals;
}

class AnimalsLoadFailure extends AnimalsState {
  final String message;

  AnimalsLoadFailure(this.message);
}