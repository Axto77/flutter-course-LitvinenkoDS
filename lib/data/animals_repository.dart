import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/entities/animal.dart';

class AnimalsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Пользователь не вошёл');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _favorites {
    return _db.collection('users').doc(_uid).collection('favorites');
  }

  Stream<List<Animal>> watchAnimals() {
    return _db
        .collection('animals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Animal.fromFirestore).toList());
  }

  Future<Set<String>> fetchLikedIds() async {
    final snapshot = await _favorites.get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  Future<void> toggleLike(String animalId, bool isLiked) async {
    final ref = _favorites.doc(animalId);

    if (isLiked) {
      await ref.delete();
    } else {
      await ref.set({'createdAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> addAnimal(Animal animal) async {
    await _db.collection('animals').add({
      ...animal.toFirestore(),
      'userId': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}