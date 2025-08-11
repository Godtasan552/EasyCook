import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/meal.dart';
import '../services/api_service.dart';

class MealController extends GetxController {
  final ApiService _apiService = ApiService();

  var meals = <Meal>[].obs;
  var loading = false.obs;

  /// ค้นหาอาหารที่มีส่วนผสมทุกตัวใน ingredients และกรอง excludeIngredients
  Future<void> searchMealsByIngredients(
    List<String> ingredients, 
    List<String> excludeIngredients,
    {String? category}
  ) async {
    await _performSearch(ingredients, excludeIngredients, category: category);
  }

  /// ค้นหาอาหารด้วยชื่อ
  Future<void> searchMealsByName(
    String name,
    List<String> excludeIngredients,
    {String? category}
  ) async {
    loading.value = true;
    
    try {
      List<Meal> searchResults = await _apiService.searchMealsByName(name);
      
      // กรองอาหารแพ้
      if (excludeIngredients.isNotEmpty) {
        final excludeLower = excludeIngredients.map((e) => e.toLowerCase().trim()).toList();
        
        searchResults = searchResults.where((meal) {
          return !meal.ingredients.any(
            (ing) => excludeLower.any((ex) => ing.toLowerCase().trim().contains(ex)),
          );
        }).toList();
      }
      
      // กรองตามหมวดหมู่
      if (category != null && category != 'all') {
        searchResults = searchResults.where((meal) {
          return meal.strCategory?.toLowerCase() == category.toLowerCase();
        }).toList();
      }
      
      meals.value = searchResults;
    } catch (e) {
      meals.value = [];
      Get.snackbar(
        'Error',
        'ไม่สามารถค้นหาเมนูได้: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    } finally {
      loading.value = false;
    }
  }

  Future<void> _performSearch(
    List<String> ingredients,
    List<String> excludeIngredients,
    {String? category}
  ) async {
    loading.value = true;

    try {
      if (ingredients.isEmpty) {
        meals.value = [];
        return;
      }

      List<List<Meal>> mealsPerIngredient = [];

      // ค้นหาอาหารทีละส่วนผสม
      for (var ingredient in ingredients) {
        final mealsByIngredient = await _apiService.searchMealsByIngredient(
          ingredient,
          excludeIngredients: excludeIngredients.isEmpty ? null : excludeIngredients,
        );
        mealsPerIngredient.add(mealsByIngredient);
      }

      if (mealsPerIngredient.isEmpty) {
        meals.value = [];
        return;
      }

      // หาเมนูที่อยู่ในทุกชุด (intersection)
      List<Meal> intersectMeals = mealsPerIngredient.first;

      for (var mealList in mealsPerIngredient.skip(1)) {
        intersectMeals = intersectMeals
            .where((meal) => mealList.any((m) => m.idMeal == meal.idMeal))
            .toList();
      }

      // กรองอาหารแพ้อีกที (กรณีที่ excludeIngredients มี และไม่ถูกกรองใน api)
      if (excludeIngredients.isNotEmpty) {
        final excludeLower = excludeIngredients.map((e) => e.toLowerCase().trim()).toList();

        intersectMeals = intersectMeals.where((meal) {
          return !meal.ingredients.any(
            (ing) => excludeLower.any((ex) => ing.toLowerCase().trim().contains(ex)),
          );
        }).toList();
      }

      // กรองตามหมวดหมู่
      if (category != null && category != 'all') {
        intersectMeals = intersectMeals.where((meal) {
          return meal.strCategory?.toLowerCase() == category.toLowerCase();
        }).toList();
      }

      meals.value = intersectMeals;
    } catch (e) {
      meals.value = [];
      print('Error searching meals: $e');
    } finally {
      loading.value = false;
    }
  }

  /// สุ่มเมนูอาหารโดยกรองอาหารแพ้
  Future<void> loadRandomMeal({required List<String> excludeIngredients}) async {
    await _performRandomSearch(excludeIngredients);
  }

  Future<void> _performRandomSearch(List<String> excludeIngredients) async {
    loading.value = true;
    try {
      final meal = await _apiService.fetchRandomMeal(
        excludeIngredients: excludeIngredients.isEmpty ? null : excludeIngredients,
      );
      meals.value = meal != null ? [meal] : [];
    } catch (e) {
      meals.value = [];
      print('Error loading random meal: $e');
    } finally {
      loading.value = false;
    }
  }

  /// สุ่มเมนูอาหารหลายรายการ (ไม่ซ้ำ) พร้อมกรองอาหารแพ้และหมวดหมู่
  Future<void> loadMultipleRandomMeals({
    int count = 5,
    List<String>? excludeIngredients,
    String? category,
  }) async {
    loading.value = true;
    meals.clear();

    try {
      if (category != null && category != 'all') {
        // ถ้าเลือกหมวดหมู่ ใช้วิธีค้นหาจากหมวดหมู่แล้วสุ่ม
        await _loadRandomMealsByCategory(
          category: category,
          count: count,
          excludeIngredients: excludeIngredients ?? [],
        );
      } else {
        // ถ้าเป็น "ทั้งหมด" ใช้วิธีสุ่มทั่วไป
        await _loadRandomMealsGeneral(
          count: count,
          excludeIngredients: excludeIngredients ?? [],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'ไม่สามารถโหลดเมนูสุ่มได้: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    } finally {
      loading.value = false;
    }
  }

  /// สุ่มเมนูจากหมวดหมู่เฉพาะ
  Future<void> _loadRandomMealsByCategory({
    required String category,
    required int count,
    required List<String> excludeIngredients,
  }) async {
    try {
      // ดึงรายการอาหารจากหมวดหมู่
      List<Meal> categoryMeals = await _apiService.searchMealsByCategory(category);
      
      if (categoryMeals.isEmpty) {
        meals.value = [];
        return;
      }
      
      // กรองอาหารแพ้
      if (excludeIngredients.isNotEmpty) {
        final excludeLower = excludeIngredients.map((e) => e.toLowerCase().trim()).toList();
        
        categoryMeals = categoryMeals.where((meal) {
          return !meal.ingredients.any(
            (ing) => excludeLower.any((ex) => ing.toLowerCase().trim().contains(ex)),
          );
        }).toList();
      }
      
      // สุ่มเลือก
      categoryMeals.shuffle();
      final selectedMeals = categoryMeals.take(count).toList();
      
      meals.addAll(selectedMeals);
    } catch (e) {
      print('Error loading random meals by category: $e');
      // ถ้าเกิดข้อผิดพลาด ลองใช้วิธีสุ่มทั่วไป
      await _loadRandomMealsGeneral(
        count: count,
        excludeIngredients: excludeIngredients,
      );
    }
  }

  /// สุ่มเมนูแบบทั่วไป
  Future<void> _loadRandomMealsGeneral({
    required int count,
    required List<String> excludeIngredients,
  }) async {
    final List<Meal> randomMeals = [];
    final Set<String> usedMealIds = {};
    int attempts = 0;
    final maxAttempts = count * 10; // จำกัดจำนวนครั้งที่พยายาม

    for (int i = 0; i < count && attempts < maxAttempts;) {
      attempts++;
      
      try {
        final response = await http.get(
          Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php')
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final mealsData = data['meals'] as List?;

          if (mealsData != null && mealsData.isNotEmpty) {
            final meal = Meal.fromJson(mealsData[0]);

            if (!usedMealIds.contains(meal.idMeal)) {
              bool hasAllergen = false;
              if (excludeIngredients.isNotEmpty) {
                for (String allergen in excludeIngredients) {
                  if (meal.ingredients.any(
                    (ingredient) => ingredient.toLowerCase().contains(allergen.toLowerCase()),
                  )) {
                    hasAllergen = true;
                    break;
                  }
                }
              }

              if (!hasAllergen) {
                randomMeals.add(meal);
                usedMealIds.add(meal.idMeal);
                i++; // นับเฉพาะเมนูที่ผ่านกรอง
              }
            }
          }
        }
      } catch (e) {
        print('Error fetching random meal: $e');
      }
    }

    meals.addAll(randomMeals);
  }

  void clearMeals() {
    meals.value = [];
  }
}