import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/animal.dart';
import '../widgets/animal_card.dart';

const String baseUrl = 'https://6ad5c93448476c0785d9c1a2.mockapi.io';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final Set<String> _likedIds = <String>{};
  bool _onlyFavorites = false;

  List<Animal> _animals = [];
  bool _isLoading = true;
  String? _error;

  bool _showForm = false;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadAnimals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/animals'));
      if (response.statusCode != 200) {
        throw Exception('Статус ${response.statusCode}');
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      final animals = decoded.map((e) => Animal.fromJson(e)).toList();

      setState(() {
        _animals = animals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addAnimal() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    try {
      final newAnimal = Animal(
        id: '',
        name: title,
        subtitle: 'Добавлено пользователем',
        category: AnimalCategory.canine,
        description: '',
        image: 'assets/images/placeholder.png',
        color: '9E9E9E',
      );

      final response = await http.post(
        Uri.parse('$baseUrl/animals'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(newAnimal.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Статус ${response.statusCode}');
      }

      final created = Animal.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));

      setState(() {
        _animals.insert(0, created);
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

  void _toggleLike(String id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
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
    final visible = _onlyFavorites
        ? _animals.where((a) => _likedIds.contains(a.id)).toList()
        : _animals;

    Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadAnimals,
              child: const Text('Обновить'),
            ),
          ],
        ),
      );
    } else if (visible.isEmpty) {
      body = const Center(child: Text('Ничего не нашлось'));
    } else {
      body = ListView.builder(
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
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Каталог животных'),
            Text(
              'В избранном: ${_likedIds.length}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
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
          Expanded(child: body),
        ],
      ),
    );
  }
}