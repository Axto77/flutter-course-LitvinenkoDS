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

  const Animal({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.description,
    required this.image,
    required this.color,
  });


  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Без названия',
      subtitle: json['subtitle'] as String? ?? '',
      category: AnimalCategory.values.byName(json['category'] as String? ?? 'feline'),
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? 'assets/images/placeholder.png',
      color: json['color'] as String? ?? '9E9E9E',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'subtitle': subtitle,
      'category': category.name,
      'description': description,
      'image': image,
      'color': color,
    };
  }
}