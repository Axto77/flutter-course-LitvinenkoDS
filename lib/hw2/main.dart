import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Каталог животных'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: animals.length,
          itemBuilder: (_, i) => animalCard(animals[i]),
        ),
      ),
    );
  }
}

class Animal {
  final String name;
  final String subtitle;
  final String category;
  final IconData categoryIcon;
  final String image;
  final Color color;
  final bool liked;

  const Animal({
    required this.name,
    required this.subtitle,
    required this.category,
    required this.categoryIcon,
    required this.image,
    required this.color,
    this.liked = false,
  });
}

const List<Animal> animals = [
  Animal(
    name: 'Лев',
    subtitle: 'Panthera leo · Африка',
    category: 'Кошачьи',
    categoryIcon: Icons.pets,
    image: 'assets/images/lion.jpg',
    color: Color(0xFFB8860B),
    liked: true,
  ),
  Animal(
    name: 'Тигр',
    subtitle: 'Panthera tigris · Азия',
    category: 'Кошачьи',
    categoryIcon: Icons.pets,
    image: 'assets/images/tiger.jpg',
    color: Color(0xFFCC5500),
  ),
  Animal(
    name: 'Африканский слон',
    subtitle: 'Loxodonta africana · Африка',
    category: 'Слоновые',
    categoryIcon: Icons.forest,
    image: 'assets/images/elephant.jpg',
    color: Color(0xFF6A5ACD),
  ),
  Animal(
    name: 'Жираф',
    subtitle: 'Giraffa camelopardalis · Африка',
    category: 'Жирафовые',
    categoryIcon: Icons.height,
    image: 'assets/images/giraffe.jpg',
    color: Color(0xFFDAA520),
    liked: true,
  ),
  Animal(
    name: 'Большая панда',
    subtitle: 'Ailuropoda melanoleuca · Китай',
    category: 'Медвежьи',
    categoryIcon: Icons.forest,
    image: 'assets/images/panda.jpg',
    color: Color(0xFF2F4F4F),
  ),
  Animal(
    name: 'Серый волк',
    subtitle: 'Canis lupus · Евразия',
    category: 'Псовые',
    categoryIcon: Icons.pets,
    image: 'assets/images/wolf.jpg',
    color: Color(0xFF4A4A4A),
  ),
  Animal(
    name: 'Обыкновенная лисица',
    subtitle: 'Vulpes vulpes · Евразия',
    category: 'Псовые',
    categoryIcon: Icons.pets,
    image: 'assets/images/fox.jpg',
    color: Color(0xFFC0392B),
    liked: true,
  ),
  Animal(
    name: 'Бурый медведь',
    subtitle: 'Ursus arctos · Евразия',
    category: 'Медвежьи',
    categoryIcon: Icons.forest,
    image: 'assets/images/bear.jpg',
    color: Color(0xFF5D4037),
  ),
  Animal(
    name: 'Белоголовый орлан',
    subtitle: 'Haliaeetus leucocephalus · Сев. Америка',
    category: 'Ястребиные',
    categoryIcon: Icons.flutter_dash,
    image: 'assets/images/eagle.jpg',
    color: Color(0xFF2C3E50),
  ),
  Animal(
    name: 'Императорский пингвин',
    subtitle: 'Aptenodytes forsteri · Антарктида',
    category: 'Пингвиновые',
    categoryIcon: Icons.ac_unit,
    image: 'assets/images/penguin.jpg',
    color: Color(0xFF1B3A5C),
  ),
];

// Карточка: Row — обложка слева, Expanded с Column справа.
Widget animalCard(Animal animal) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cover(animal),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Название
              Text(
                animal.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              // Подпись
              Text(
                animal.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              // Иконка категории + название категории
              Row(
                children: [
                  Icon(animal.categoryIcon, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      animal.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Обложка — Stack из трёх слоёв.
Widget cover(Animal animal) {
  return SizedBox(
    width: 72,
    height: 72,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        // Слой 1: Container с цветом (внутрь опционально фото).
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: animal.color,
              child: Image.asset(
                animal.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        // Слой 2: первая буква названия по центру.
        Center(
          child: Text(
            animal.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Слой 3: иконка лайка в правом верхнем углу поверх остальных.
        Positioned(
          top: 4,
          right: 4,
          child: Icon(
            animal.liked ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}