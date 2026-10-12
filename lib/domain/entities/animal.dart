import 'package:flutter/material.dart';

/// Категория животного.
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

/// Модель одного элемента каталога.
class Animal {
  final int id;
  final String name;
  final String subtitle;
  final AnimalCategory category;
  final String? description;
  final IconData categoryIcon;
  final String image;
  final Color color;

  const Animal({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    this.description,
    required this.categoryIcon,
    required this.image,
    required this.color,
  });
}