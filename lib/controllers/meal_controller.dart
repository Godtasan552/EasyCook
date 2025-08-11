import 'package:get/get.dart';
import '../models/meal.dart';
import '../services/api_service.dart';

class MealController extends GetxController {
  final ApiService _apiService = ApiService();

  var meals = <Meal>[].obs;
  var loading = false.obs;

  Future<void> searchMeals(String ingredient, {List<String>? excludeIngredients}) async {
    loading.value = true;
    try {
      meals.value = await _apiService.searchMealsByIngredient(ingredient, excludeIngredients: excludeIngredients);
    } catch (e) {
      meals.value = [];
      print('Error searching meals: $e');
    }
    loading.value = false;
  }

  Future<void> loadRandomMeal({List<String>? excludeIngredients}) async {
    loading.value = true;
    try {
      final meal = await _apiService.fetchRandomMeal(excludeIngredients: excludeIngredients);
      meals.value = meal != null ? [meal] : [];
    } catch (e) {
      meals.value = [];
      print('Error loading random meal: $e');
    }
    loading.value = false;
  }
}
