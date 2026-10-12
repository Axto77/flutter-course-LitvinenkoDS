import 'package:flutter/material.dart';

import '../../domain/entities/animal.dart';
import '../widgets/animal_card.dart';

/// Каталог животных.
const List<Animal> animals = [
  Animal(
    id: 1,
    name: 'Лев',
    subtitle: 'Panthera leo · Африка',
    category: AnimalCategory.feline,
    description: 'Социальный хищник, живёт прайдами.',
    categoryIcon: Icons.pets,
    image: 'assets/images/lion.jpg',
    color: Color(0xFFB8860B),
  ),
  Animal(
    id: 2,
    name: 'Тигр',
    subtitle: 'Panthera tigris · Азия',
    category: AnimalCategory.feline,
    categoryIcon: Icons.pets,
    image: 'assets/images/tiger.jpg',
    color: Color(0xFFCC5500),
  ),
  Animal(
    id: 3,
    name: 'Африканский слон',
    subtitle: 'Loxodonta africana · Африка',
    category: AnimalCategory.elephant,
    categoryIcon: Icons.forest,
    image: 'assets/images/elephant.jpg',
    color: Color(0xFF6A5ACD),
  ),
  Animal(
    id: 4,
    name: 'Жираф',
    subtitle: 'Giraffa camelopardalis · Африка',
    category: AnimalCategory.giraffe,
    categoryIcon: Icons.height,
    image: 'assets/images/giraffe.jpg',
    color: Color(0xFFDAA520),
  ),
  Animal(
    id: 5,
    name: 'Большая панда',
    subtitle: 'Ailuropoda melanoleuca · Китай',
    category: AnimalCategory.bear,
    categoryIcon: Icons.forest,
    image: 'assets/images/panda.jpg',
    color: Color(0xFF2F4F4F),
  ),
  Animal(
    id: 6,
    name: 'Серый волк',
    subtitle: 'Canis lupus · Евразия',
    category: AnimalCategory.canine,
    categoryIcon: Icons.pets,
    image: 'assets/images/wolf.jpg',
    color: Color(0xFF4A4A4A),
  ),
  Animal(
    id: 7,
    name: 'Обыкновенная лисица',
    subtitle: 'Vulpes vulpes · Евразия',
    category: AnimalCategory.canine,
    categoryIcon: Icons.pets,
    image: 'assets/images/fox.jpg',
    color: Color(0xFFC0392B),
  ),
  Animal(
    id: 8,
    name: 'Бурый медведь',
    subtitle: 'Ursus arctos · Евразия',
    category: AnimalCategory.bear,
    categoryIcon: Icons.forest,
    image: 'assets/images/bear.jpg',
    color: Color(0xFF5D4037),
  ),
  Animal(
    id: 9,
    name: 'Белоголовый орлан',
    subtitle: 'Haliaeetus leucocephalus · Сев. Америка',
    category: AnimalCategory.bird,
    categoryIcon: Icons.flutter_dash,
    image: 'assets/images/eagle.jpg',
    color: Color(0xFF2C3E50),
  ),
  Animal(
    id: 10,
    name: 'Императорский пингвин',
    subtitle: 'Aptenodytes forsteri · Антарктида',
    category: AnimalCategory.penguin,
    categoryIcon: Icons.ac_unit,
    image: 'assets/images/penguin.jpg',
    color: Color(0xFF1B3A5C),
  ),
];

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  /// id лайкнутых элементов.
  final Set<int> _likedIds = <int>{};

  /// Показывать только избранные.
  bool _onlyFavorites = false;

  void _toggleLike(int id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _onlyFavorites
        ? animals.where((a) => _likedIds.contains(a.id)).toList()
        : animals;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Каталог животных'),
            Text(
              'В избранном: ${_likedIds.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                selected: _onlyFavorites,
                onSelected: (value) {
                  setState(() => _onlyFavorites = value);
                },
                avatar: Icon(
                  _onlyFavorites
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: 16,
                ),
                label: const Text('Только избранные'),
              ),
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('Ничего не нашлось'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: visible.length,
                    itemBuilder: (_, i) {
                      final animal = visible[i];
                      return AnimalCard(
                        animal: animal,
                        isLiked: _likedIds.contains(animal.id),
                        onLikeTap: () => _toggleLike(animal.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}