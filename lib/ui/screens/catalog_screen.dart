import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/animal.dart';
import '../widgets/animal_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool _onlyFavorites = false;
  bool _showForm = false;
  final TextEditingController _titleController = TextEditingController();

  // Поток для получения всех животных
  final Stream<QuerySnapshot<Map<String, dynamic>>> _animalsStream =
      FirebaseFirestore.instance
          .collection('animals')
          .orderBy('createdAt', descending: true)
          .snapshots();

  // Поток для получения избранного (лайков) текущего пользователя
  // Мы сразу преобразуем его в Set<String> для удобства
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
    
    // Рекомендация преподавателя
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

  // Обновленный метод лайка: теперь он пишет в Firebase
  Future<void> _toggleLike(String id, bool isLiked) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(id);

    try {
      if (isLiked) {
        await favRef.delete(); // Убираем лайк
      } else {
        await favRef.set({'liked': true}); // Ставим лайк
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
    // Внешний StreamBuilder слушает лайки (избранное)
    return StreamBuilder<Set<String>>(
      stream: _favoritesStream,
      builder: (context, favSnapshot) {
        // Если данные о лайках еще грузятся, используем пустое множество
        final likedIds = favSnapshot.data ?? <String>{};

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Каталог животных'),
                Text(
                  'В избранном: ${likedIds.length}', // Счетчик теперь берет данные из Firebase
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
                // Внутренний StreamBuilder слушает животных
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _animalsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Ошибка: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;
                    final animals = docs.map((doc) => Animal.fromFirestore(doc)).toList();

                    // Фильтруем на основе локального флага и данных из Firebase
                    final visible = _onlyFavorites
                        ? animals.where((a) => likedIds.contains(a.id)).toList()
                        : animals;

                    if (visible.isEmpty) {
                      return const Center(child: Text('Ничего не нашлось'));
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