import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class ApiService {
  static const _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Meal>> searchMealsByIngredient(String ingredient, {List<String>? excludeIngredients}) async {
    final response = await http.get(Uri.parse('$_baseUrl/filter.php?i=$ingredient'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['meals'] == null) return [];

      List mealsBrief = data['meals'];

      // ดึงข้อมูล detail แต่ละเมนู เพื่อเช็คส่วนผสมและรายละเอียด
      List<Meal> fullMeals = [];
      for (var mealBrief in mealsBrief) {
        final detail = await fetchMealDetail(mealBrief['idMeal']);
        if (detail != null) {
          // ตรวจสอบส่วนผสมแพ้
          bool hasExcluded = false;
          if (excludeIngredients != null) {
            for (var ing in detail.ingredients) {
              if (excludeIngredients.any((e) => ing.toLowerCase().contains(e.toLowerCase()))) {
                hasExcluded = true;
                break;
              }
            }
          }
          if (!hasExcluded) fullMeals.add(detail);
        }
      }
      return fullMeals;
    }
    throw Exception('Failed to load meals');
  }

  Future<Meal?> fetchMealDetail(String idMeal) async {
    final response = await http.get(Uri.parse('$_baseUrl/lookup.php?i=$idMeal'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['meals'] != null) {
        return Meal.fromJson(data['meals'][0]);
      }
    }
    return null;
  }

  Future<Meal?> fetchRandomMeal({List<String>? excludeIngredients}) async {
    for (int i = 0; i < 10; i++) { // พยายามสุ่ม 10 ครั้ง
      final response = await http.get(Uri.parse('$_baseUrl/random.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] != null) {
          final meal = Meal.fromJson(data['meals'][0]);
          if (excludeIngredients != null) {
            bool hasExcluded = meal.ingredients.any((ing) =>
                excludeIngredients.any((ex) => ing.toLowerCase().contains(ex.toLowerCase())));
            if (!hasExcluded) return meal;
          } else {
            return meal;
          }
        }
      }
    }
    return null;
  }
}
