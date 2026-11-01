import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<String?> authStateChanges() {
    return _auth.authStateChanges().map((user) => user?.uid);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageForCode(error.code));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageForCode(error.code));
    }
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  String _messageForCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Такая почта уже зарегистрирована. Войдите или используйте другую.';
      case 'weak-password':
        return 'Пароль слишком короткий: нужно минимум 6 символов.';
      case 'invalid-email':
        return 'Почта записана с ошибкой. Пример: test1@test.com';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Неверная почта или пароль.';
      case 'operation-not-allowed':
        return 'Вход по email и паролю не включён в Firebase.';
      case 'network-request-failed':
        return 'Нет интернета. Проверьте подключение и попробуйте снова.';
      case 'too-many-requests':
        return 'Слишком много попыток. Подождите немного и попробуйте снова.';
      default:
        return 'Не удалось выполнить вход. Код ошибки: $code';
    }
  }
}