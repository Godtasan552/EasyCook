import 'package:flutter/material.dart';
import '../models/meal_detail.dart';
import '../services/api_service.dart';

class MealController extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<MealDetail> meals = [];
  bool loading = false;

  Future<void> loadRandomList(int count) async {
    loading = true;
    notifyListeners();
    meals = [];
    for (int i = 0; i < count; i++) {
      final m = await _api.randomMeal();
      if (m != null) meals.add(m);
    }
    loading = false;
    notifyListeners();
  }

  Future<void> searchByIngredient(String ingredient, {Set<String>? excludeIngredients}) async {
    loading = true;
    notifyListeners();
    final results = await _api.searchByIngredient(ingredient);
    if (excludeIngredients != null && excludeIngredients.isNotEmpty) {
      meals = results.where((meal) {
        for (var ing in meal.strIngredients) {
          if (ing == null) continue;
          final low = ing.toLowerCase();
          for (var ex in excludeIngredients) {
            if (low.contains(ex.toLowerCase())) return false;
          }
        }
        return true;
      }).toList();
    } else {
      meals = results;
    }
    loading = false;
    notifyListeners();
  }

  Future<MealDetail?> randomMealFiltered({Set<String>? excludeIngredients}) async {
    final m = await _api.randomMeal();
    if (m == null) return null;
    if (excludeIngredients != null && excludeIngredients.isNotEmpty) {
      for (var ing in m.strIngredients) {
        if (ing == null) continue;
        final low = ing.toLowerCase();
        for (var ex in excludeIngredients) {
          if (low.contains(ex.toLowerCase())) return null;
        }
      }
    }
    return m;
  }
}
