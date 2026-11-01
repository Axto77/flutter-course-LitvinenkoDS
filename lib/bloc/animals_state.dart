import '../domain/entities/animal.dart';

sealed class AnimalsState {}

class AnimalsLoadInProgress extends AnimalsState {}

class AnimalsLoadSuccess extends AnimalsState {
  final List<Animal> animals;
  AnimalsLoadSuccess(this.animals);
}

class AnimalsLoadFailure extends AnimalsState {
  final String message;
  AnimalsLoadFailure(this.message);
}