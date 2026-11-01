import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/animal.dart'; 
import 'animals_event.dart';
import 'animals_state.dart';

class AnimalsBloc extends Bloc<AnimalsEvent, AnimalsState> {
  AnimalsBloc() : super(AnimalsLoadInProgress()) {
    on<AnimalsLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    AnimalsLoadRequested event, 
    Emitter<AnimalsState> emit,
  ) async {
    emit(AnimalsLoadInProgress());
    
    await emit.forEach(
      FirebaseFirestore.instance
          .collection('animals')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      onData: (snapshot) => AnimalsLoadSuccess(
        snapshot.docs.map(Animal.fromFirestore).toList(),
      ),
      onError: (error, stackTrace) => 
          AnimalsLoadFailure('Не удалось загрузить каталог'),
    );
  }
}