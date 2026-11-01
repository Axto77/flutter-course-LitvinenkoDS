import 'package:cloud_firestore/cloud_firestore.dart';

enum AnimalCategory {
  feline('Кошачьи'),
  canine('Псовые'),
  bear('Медвежьи'),
  bird('Ястребиные'),
  elephant('Слоновые'),
  giraffe('Жирафовые'),
  penguin('Пингвиновые');

  final String label;
  const AnimalCategory(this.label);
}

class Animal {
  final String id;
  final String name;
  final String subtitle;
  final AnimalCategory category;
  final String description;
  final String image;
  final String color;
  final DateTime? createdAt;

  const Animal({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.description,
    required this.image,
    required this.color,
    this.createdAt,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Без названия',
      subtitle: json['subtitle']?.toString() ?? '',
      category: _parseCategory(json['category']),
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? 'assets/images/placeholder.png',
      color: json['color']?.toString() ?? '9E9E9E',
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  factory Animal.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};

    return Animal(
      id: doc.id,
      name: data['name']?.toString() ?? 'Без названия',
      subtitle: data['subtitle']?.toString() ?? '',
      category: _parseCategory(data['category']),
      description: data['description']?.toString() ?? '',
      image: data['image']?.toString() ?? 'assets/images/placeholder.png',
      color: data['color']?.toString() ?? '9E9E9E',
      createdAt: _parseDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'category': category.name,
      'description': description,
      'image': image,
      'color': color,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'subtitle': subtitle,
      'category': category.name,
      'description': description,
      'image': image,
      'color': color,
    };
  }

  static AnimalCategory _parseCategory(Object? value) {
    if (value is AnimalCategory) return value;

    final raw = value?.toString();
    for (final category in AnimalCategory.values) {
      if (category.name == raw) return category;
    }
    return AnimalCategory.feline;
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}