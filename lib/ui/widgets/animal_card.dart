import 'package:flutter/material.dart';

import '../../domain/entities/animal.dart';

IconData _getCategoryIcon(AnimalCategory category) {
  switch (category) {
    case AnimalCategory.feline:
      return Icons.pets;
    case AnimalCategory.canine:
      return Icons.pets;
    case AnimalCategory.bear:
      return Icons.forest;
    case AnimalCategory.bird:
      return Icons.flutter_dash;
    case AnimalCategory.elephant:
      return Icons.forest;
    case AnimalCategory.giraffe:
      return Icons.height;
    case AnimalCategory.penguin:
      return Icons.ac_unit;
  }
}

Color _hexToColor(String hex) {
  final cleanHex = hex.replaceAll('#', '');
  final paddedHex = cleanHex.length == 6 ? 'FF$cleanHex' : cleanHex;
  return Color(int.tryParse(paddedHex, radix: 16) ?? 0xFF9E9E9E);
}

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback? onTap;

  const AnimalCard({
    super.key,
    required this.animal,
    required this.isLiked,
    required this.onLikeTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cover(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      animal.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(animal.category),
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            animal.category.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cover() {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: _hexToColor(animal.color),
                child: Image.asset(
                  animal.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              animal.name.isNotEmpty ? animal.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onLikeTap,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}