import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesRepository {
  static const _key = 'favorite_recipe_ids';

  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return <String>{};
    final List list = json.decode(jsonStr) as List;
    return list.map((e) => e.toString()).toSet();
  }

  Future<void> saveFavorites(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(ids.toList()));
  }

  Future<void> toggle(String id) async {
    final set = await loadFavorites();
    if (set.contains(id)) {
      set.remove(id);
    } else {
      set.add(id);
    }
    await saveFavorites(set);
  }
}
