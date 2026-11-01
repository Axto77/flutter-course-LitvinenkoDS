import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/animals_repository.dart';
import '../data/connectivity_service.dart';
import 'animals_event.dart';
import 'animals_state.dart';

class AnimalsBloc extends Bloc<AnimalsEvent, AnimalsState> {
  final AnimalsRepository _repository;
  final ConnectivityService _connectivity;

  AnimalsBloc(this._repository, this._connectivity)
      : super(AnimalsLoadInProgress()) {
    on<AnimalsLoadRequested>(_onLoadRequested);
    on<AnimalLikeToggled>(_onLikeToggled);
    on<AnimalsFilterToggled>(_onFilterToggled);
    on<AnimalAdded>((event, emit) => _repository.addAnimal(event.animal));
  }

  Future<void> _onLoadRequested(
    AnimalsLoadRequested event,
    Emitter<AnimalsState> emit,
  ) async {
    emit(AnimalsLoadInProgress());

    final hasConnection = await _connectivity.hasConnection();
    if (isClosed) return;

    if (!hasConnection) {
      emit(AnimalsLoadFailure(
        'Нет подключения к интернету. Проверьте сеть и нажмите «Обновить».',
      ));
      return;
    }

    Set<String> likedIds;

    try {
      likedIds = await _repository.fetchLikedIds();
    } catch (error) {
      emit(AnimalsLoadFailure(
        'Не удалось загрузить каталог. Проверьте интернет и попробуйте ещё раз.',
      ));
      return;
    }

    await emit.forEach(
      _repository.watchAnimals(),
      onData: (animals) {
        final s = state;

        return s is AnimalsLoadSuccess
            ? s.copyWith(animals: animals)
            : AnimalsLoadSuccess(
                animals: animals,
                likedIds: likedIds,
              );
      },
      onError: (error, stackTrace) => AnimalsLoadFailure(
        'Не удалось загрузить каталог. Проверьте интернет и попробуйте ещё раз.',
      ),
    );
  }

  Future<void> _onLikeToggled(
    AnimalLikeToggled event,
    Emitter<AnimalsState> emit,
  ) async {
    final s = state;
    if (s is! AnimalsLoadSuccess) return;

    final wasLiked = s.likedIds.contains(event.animalId);
    final ids = {...s.likedIds};

    if (wasLiked) {
      ids.remove(event.animalId);
    } else {
      ids.add(event.animalId);
    }

    emit(s.copyWith(likedIds: ids));

    await _repository.toggleLike(event.animalId, wasLiked);
  }

  void _onFilterToggled(
    AnimalsFilterToggled event,
    Emitter<AnimalsState> emit,
  ) {
    final s = state;

    if (s is AnimalsLoadSuccess) {
      emit(s.copyWith(onlyFavorites: !s.onlyFavorites));
    }
  }
}