import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/animal.dart';
import '../widgets/animal_card.dart';
import '../../bloc/animals_bloc.dart';
import '../../bloc/animals_event.dart';
import '../../bloc/animals_state.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool _onlyFavorites = false;
  bool _showForm = false;
  final TextEditingController _titleController = TextEditingController();

  final Stream<Set<String>> _favoritesStream = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('favorites')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _addAnimal() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите название животного')),
      );
      return;
    }

    try {
      final newAnimalMap = {
        'name': title,
        'subtitle': 'Добавлено пользователем',
        'category': AnimalCategory.canine.name,
        'description': '',
        'image': 'assets/images/placeholder.png',
        'color': '9E9E9E',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('animals').add(newAnimalMap);

      setState(() {
        _titleController.clear();
        _showForm = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Успешно добавлено!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка отправки: $e')),
        );
      }
    }
  }

  Future<void> _toggleLike(String id, bool isLiked) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(id);

    try {
      if (isLiked) {
        await favRef.delete();
      } else {
        await favRef.set({'liked': true});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка обновления лайка: $e')),
        );
      }
    }
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название животного',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _addAnimal,
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Set<String>>(
      stream: _favoritesStream,
      builder: (context, favSnapshot) {
        final likedIds = favSnapshot.data ?? <String>{};

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Каталог животных'),
                Text(
                  'В избранном: ${likedIds.length}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => FirebaseAuth.instance.signOut(),
                tooltip: 'Выйти',
              ),
              IconButton(
                icon: Icon(_showForm ? Icons.close : Icons.add),
                onPressed: () => setState(() => _showForm = !_showForm),
              ),
            ],
          ),
          body: Column(
            children: [
              if (_showForm) _buildForm(),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    selected: _onlyFavorites,
                    showCheckmark: false,
                    onSelected: (value) {
                      setState(() => _onlyFavorites = value);
                    },
                    avatar: Icon(
                      _onlyFavorites ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: 16,
                    ),
                    label: const Text('Только избранные'),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<AnimalsBloc, AnimalsState>(
                  builder: (context, state) {
                    if (state is AnimalsLoadInProgress) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is AnimalsLoadFailure) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.message),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<AnimalsBloc>()
                                  .add(AnimalsLoadRequested()),
                              child: const Text('Обновить'),
                            ),
                          ],
                        ),
                      );
                    }

                    final s = state as AnimalsLoadSuccess;
                    final animals = s.animals;

                    final visible = _onlyFavorites
                        ? animals.where((a) => likedIds.contains(a.id)).toList()
                        : animals;

                    if (visible.isEmpty) {
                      return Center(
                        child: Text(_onlyFavorites ? 'Нет избранных' : 'Ничего не нашлось'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: visible.length,
                      itemBuilder: (_, i) {
                        final animal = visible[i];
                        final isLiked = likedIds.contains(animal.id);
                        return AnimalCard(
                          animal: animal,
                          isLiked: isLiked,
                          onLikeTap: () => _toggleLike(animal.id, isLiked),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}