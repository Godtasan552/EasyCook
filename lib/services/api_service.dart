import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_detail.dart';

class ApiService {
  static const String base = 'https://www.themealdb.com/api/json/v1/1';

  Future<MealDetail?> randomMeal() async {
    final r = await http.get(Uri.parse('$base/random.php'));
    if (r.statusCode == 200) {
      final j = json.decode(r.body);
      final m = (j['meals'] ?? [])[0];
      return MealDetail.fromJson(m);
    }
    return null;
  }

  Future<List<MealDetail>> searchByIngredient(String ingredient) async {
    final r = await http.get(Uri.parse('$base/filter.php?i=${Uri.encodeComponent(ingredient)}'));
    if (r.statusCode != 200) return [];
    final j = json.decode(r.body);
    final meals = j['meals'] ?? [];
    final out = <MealDetail>[];
    for (var m in meals.take(30)) {
      final id = m['idMeal'];
      final det = await mealById(id);
      if (det != null) out.add(det);
    }
    return out;
  }

  Future<MealDetail?> mealById(String id) async {
    final r = await http.get(Uri.parse('$base/lookup.php?i=$id'));
    if (r.statusCode == 200) {
      final j = json.decode(r.body);
      final m = (j['meals'] ?? [])[0];
      return MealDetail.fromJson(m);
    }
    return null;
  }
}
