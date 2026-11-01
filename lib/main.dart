import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/animals_bloc.dart';
import 'bloc/animals_event.dart';
import 'bloc/theme_cubit.dart';
import 'data/animals_repository.dart';
import 'data/auth_repository.dart';
import 'data/connectivity_service.dart';
import 'data/theme_repository.dart';
import 'firebase_options.dart';
import 'ui/screens/catalog_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final preferences = await SharedPreferences.getInstance();
  final themeCubit = ThemeCubit(ThemeRepository(preferences));

  runApp(MyApp(themeCubit: themeCubit));
}

class MyApp extends StatelessWidget {
  final ThemeCubit themeCubit;

  const MyApp({super.key, required this.themeCubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: themeCubit,
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Каталог животных',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            locale: const Locale('ru'),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [
              Locale('ru'),
              Locale('en'),
            ],
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthRepository _authRepository = AuthRepository();
  late final Stream<String?> _authStateChanges;

  @override
  void initState() {
    super.initState();
    _authStateChanges = _authRepository.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return const LoginScreen();
        }

        return BlocProvider(
          create: (_) => AnimalsBloc(
            AnimalsRepository(),
            ConnectivityService(),
          )..add(AnimalsLoadRequested()),
          child: const CatalogScreen(),
        );
      },
    );
  }
}