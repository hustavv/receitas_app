import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ViewedRepository {
  static const _key = 'viewed_recipe_ids';

  Future<List<String>> loadViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return <String>[];
    final List list = json.decode(jsonStr) as List;
    return list.map((e) => e.toString()).toList();
  }

  Future<void> addViewed(String id) async {
    final current = await loadViewed();
    if (!current.contains(id)) current.insert(0, id); // mais recente primeiro
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(current));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
