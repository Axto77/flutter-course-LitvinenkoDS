import 'package:connectivity_plus/connectivity_plus.dart';

/// Проверяет, есть ли у устройства подключение к сети.
///
/// Нужен, чтобы показать состояние ошибки сразу, как только пропал
/// интернет: Firestore умеет отдавать данные из кэша и без сети,
/// поэтому сама по себе ошибка от него может не прийти.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> hasConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (_) {
      // Если проверить не удалось, не мешаем загрузке —
      // ошибку покажет сам Firestore.
      return true;
    }
  }
}
