import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/animals_bloc.dart';
import '../../bloc/animals_event.dart';
import '../../bloc/animals_state.dart';
import '../../domain/entities/animal.dart';

class AnimalDetailsScreen extends StatelessWidget {
  final Animal animal;

  const AnimalDetailsScreen({
    super.key,
    required this.animal,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(animal.name),
      ),
      body: BlocBuilder<AnimalsBloc, AnimalsState>(
        builder: (context, state) {
          final isLiked = state is AnimalsLoadSuccess &&
              state.likedIds.contains(animal.id);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildCover(),
              const SizedBox(height: 20),
              Text(
                animal.name,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (animal.subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  animal.subtitle,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(
                    avatar: Icon(
                      _getCategoryIcon(animal.category),
                      size: 16,
                    ),
                    label: Text(animal.category.label),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      context
                          .read<AnimalsBloc>()
                          .add(AnimalLikeToggled(animal.id));
                    },
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                    ),
                    label: Text(
                      isLiked ? 'В избранном' : 'В избранное',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Описание',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                animal.description.isNotEmpty
                    ? animal.description
                    : 'Описание пока не добавлено.',
                style: textTheme.bodyLarge,
              ),
              if (animal.createdAt != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Добавлено: ${_formatDate(animal.createdAt!)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCover() {
    final color = _hexToColor(animal.color);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 220,
        color: color,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              animal.image,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
            Center(
              child: Text(
                animal.name.isNotEmpty ? animal.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}