import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'repositories/favorites_repository.dart';
import 'repositories/viewed_repository.dart';
import 'services/api_client.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/search_screen.dart';
import 'screens/viewed_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiClient(mockMode: true);
  runApp(MyApp(api: api));
}

class MyApp extends StatelessWidget {
  final ApiClient api;
  const MyApp({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(api: api, favoritesRepo: FavoritesRepository(), viewedRepo: ViewedRepository()),
      child: MaterialApp(
        title: 'Receitas',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF5C6BC0)),
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (_) => const LoginScreen(),
          '/home': (_) => const HomeScreen(),
          '/favorites': (_) => const FavoritesScreen(),
          '/search': (_) => const SearchScreen(),
          '/viewed': (_) => const ViewedScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}
