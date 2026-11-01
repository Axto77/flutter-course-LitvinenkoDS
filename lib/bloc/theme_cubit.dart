import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/theme_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemeRepository _repository;

  ThemeCubit(ThemeRepository repository)
      : _repository = repository,
        super(repository.loadThemeMode());

  bool get isDark => state == ThemeMode.dark;

  Future<void> toggle() async {
    final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
    emit(nextMode);
    await _repository.saveThemeMode(nextMode);
  }
}