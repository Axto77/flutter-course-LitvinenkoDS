import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/animals_bloc.dart';
import '../../bloc/animals_event.dart';
import '../../bloc/animals_state.dart';
import '../../data/auth_repository.dart';
import '../../domain/entities/animal.dart';
import '../widgets/add_animal_sheet.dart';
import '../widgets/animal_card.dart';
import '../widgets/theme_toggle_button.dart';
import 'animal_details_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final AuthRepository _authRepository = AuthRepository();

  Future<void> _signOut() async {
    try {
      await _authRepository.signOut();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось выйти. Попробуйте ещё раз.'),
        ),
      );
    }
  }

  Future<void> _openAddSheet() async {
    final animal = await showModalBottomSheet<Animal>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddAnimalSheet(),
    );

    if (!mounted || animal == null) return;

    context.read<AnimalsBloc>().add(AnimalAdded(animal));
  }

  void _openDetails(Animal animal) {
    final animalsBloc = context.read<AnimalsBloc>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: animalsBloc,
          child: AnimalDetailsScreen(animal: animal),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnimalsBloc, AnimalsState>(
      listenWhen: (previous, current) =>
          current is AnimalsLoadFailure &&
          previous is! AnimalsLoadFailure,
      listener: (context, state) {
        if (state is! AnimalsLoadFailure) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Каталог животных'),
          actions: [
            const ThemeToggleButton(),
            IconButton(
              tooltip: 'Выйти',
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: BlocBuilder<AnimalsBloc, AnimalsState>(
          builder: (context, state) {
            if (state is AnimalsLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AnimalsLoadFailure) {
              return _ErrorView(message: state.message);
            }

            final success = state as AnimalsLoadSuccess;
            final visibleAnimals = success.visibleAnimals;
            final theme = Theme.of(context);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FilterChip(
                            selected: success.onlyFavorites,
                            avatar: Icon(
                              success.onlyFavorites
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 16,
                              color: Colors.red,
                            ),
                            label: const Text('Только избранные'),
                            onSelected: (_) {
                              context
                                  .read<AnimalsBloc>()
                                  .add(AnimalsFilterToggled());
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Всего: ${success.animals.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: visibleAnimals.isEmpty
                      ? _EmptyView(
                          onlyFavorites: success.onlyFavorites,
                          onAdd: _openAddSheet,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                          itemCount: visibleAnimals.length,
                          itemBuilder: (context, index) {
                            final animal = visibleAnimals[index];

                            return AnimalCard(
                              animal: animal,
                              isLiked: success.likedIds.contains(animal.id),
                              onLikeTap: () {
                                context
                                    .read<AnimalsBloc>()
                                    .add(AnimalLikeToggled(animal.id));
                              },
                              onTap: () => _openDetails(animal),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: BlocBuilder<AnimalsBloc, AnimalsState>(
          builder: (context, state) {
            if (state is! AnimalsLoadSuccess) {
              return const SizedBox.shrink();
            }

            return FloatingActionButton.extended(
              onPressed: _openAddSheet,
              icon: const Icon(Icons.add),
              label: const Text('Добавить'),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                context.read<AnimalsBloc>().add(AnimalsLoadRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Обновить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool onlyFavorites;
  final VoidCallback onAdd;

  const _EmptyView({
    required this.onlyFavorites,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              onlyFavorites ? Icons.favorite_border : Icons.pets,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              onlyFavorites ? 'В избранном пока пусто' : 'Каталог пуст',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              onlyFavorites
                  ? 'Нажмите на сердечко у животного, чтобы добавить его в избранное.'
                  : 'Добавьте первое животное — оно сразу появится в каталоге.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (!onlyFavorites) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Добавить животное'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}