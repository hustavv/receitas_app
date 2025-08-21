// lib/router.dart
import 'package:go_router/go_router.dart';
import 'ui/pages/login_page.dart';
import 'ui/pages/register_page.dart';
import 'ui/pages/home_page.dart';
import 'ui/pages/favorites_page.dart';
import 'ui/pages/search_page.dart';
import 'ui/pages/recipe_detail_page.dart';
import 'ui/pages/recipe_create_page.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/favorites', builder: (_, __) => const FavoritesPage()),
    GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
    GoRoute(path: '/recipe/new', builder: (_, __) => const RecipeCreatePage()),
    GoRoute(path: '/recipe/:id', builder: (_, s) => RecipeDetailPage(id: s.pathParameters['id']!)),
  ],
);
