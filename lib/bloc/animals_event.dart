import '../domain/entities/animal.dart';

sealed class AnimalsEvent {}

class AnimalsLoadRequested extends AnimalsEvent {}

class AnimalLikeToggled extends AnimalsEvent {
  final String animalId;

  AnimalLikeToggled(this.animalId);
}

class AnimalsFilterToggled extends AnimalsEvent {}

class AnimalAdded extends AnimalsEvent {
  final Animal animal;

  AnimalAdded(this.animal);
}