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
  Future<void> searchMeals(List<String> ingredients, List<String> excludeIngredients) async {
    await _performSearch(ingredients, excludeIngredients);
  }

  /// ค้นหาอาหารด้วยชื่อเมนู พร้อมกรองอาหารแพ้
  Future<void> searchMealsByName(String name, List<String> excludeIngredients) async {
    loading.value = true;

    try {
      if (name.isEmpty) {
        meals.value = [];
        return;
      }

      // เรียกใช้ API service เพื่อค้นหาด้วยชื่อ
      final searchResults = await _apiService.searchMealsByName(name);

      if (excludeIngredients.isEmpty) {
        meals.value = searchResults;
        return;
      }

      // กรองอาหารแพ้
      final excludeLower = excludeIngredients.map((e) => e.toLowerCase().trim()).toList();
      
      final filteredMeals = searchResults.where((meal) {
        return !meal.ingredients.any(
          (ing) => excludeLower.any((ex) => ing.toLowerCase().trim().contains(ex)),
        );
      }).toList();

      meals.value = filteredMeals;
    } catch (e) {
      meals.value = [];
      Get.snackbar(
        'Error',
        'ไม่สามารถค้นหาเมนูได้: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
      print('Error searching meals by name: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> _performSearch(
    List<String> ingredients,
    List<String> excludeIngredients,
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

      meals.value = intersectMeals;
    } catch (e) {
      meals.value = [];
      Get.snackbar(
        'Error',
        'ไม่สามารถค้นหาเมนูได้: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
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
      Get.snackbar(
        'Error',
        'ไม่สามารถโหลดเมนูสุ่มได้: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
      print('Error loading random meal: $e');
    } finally {
      loading.value = false;
    }
  }

  /// สุ่มเมนูอาหารหลายรายการ (ไม่ซ้ำ) พร้อมกรองอาหารแพ้
  Future<void> loadMultipleRandomMeals({
    int count = 5,
    List<String>? excludeIngredients,
  }) async {
    loading.value = true;
    meals.clear();

    try {
      final List<Meal> randomMeals = [];
      final Set<String> usedMealIds = {};

      for (int i = 0; i < count;) {
        final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php'));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final mealsData = data['meals'] as List?;

          if (mealsData != null && mealsData.isNotEmpty) {
            final meal = Meal.fromJson(mealsData[0]);

            if (!usedMealIds.contains(meal.idMeal)) {
              bool hasAllergen = false;
              if (excludeIngredients != null && excludeIngredients.isNotEmpty) {
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

        // ป้องกันลูปไม่รู้จบ
        if (i > count * 5) break;
      }

      meals.addAll(randomMeals);
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

  /// ค้นหาเมนูตาม category และ area (สำหรับใช้กับ filter)
  Future<void> searchMealsByFilter({
    String? category,
    String? area,
    List<String>? excludeIngredients,
  }) async {
    loading.value = true;

    try {
      List<Meal> filteredMeals = [];

      // ค้นหาตาม category
      if (category != null && category != 'All') {
        final categoryMeals = await _apiService.searchMealsByCategory(category);
        filteredMeals.addAll(categoryMeals);
      }

      // ค้นหาตาม area
      if (area != null && area != 'All') {
        final areaMeals = await _apiService.searchMealsByArea(area);
        if (filteredMeals.isEmpty) {
          filteredMeals.addAll(areaMeals);
        } else {
          // หา intersection ระหว่าง category และ area
          filteredMeals = filteredMeals
              .where((meal) => areaMeals.any((m) => m.idMeal == meal.idMeal))
              .toList();
        }
      }

      // ถ้าไม่ได้เลือก filter ใดเลย ให้โหลดเมนูสุ่มแทน
      if (filteredMeals.isEmpty && 
          (category == null || category == 'All') && 
          (area == null || area == 'All')) {
        await loadMultipleRandomMeals(
          count: 10,
          excludeIngredients: excludeIngredients,
        );
        return;
      }

      // กรองอาหารแพ้
      if (excludeIngredients != null && excludeIngredients.isNotEmpty) {
        final excludeLower = excludeIngredients.map((e) => e.toLowerCase().trim()).toList();
        
        filteredMeals = filteredMeals.where((meal) {
          return !meal.ingredients.any(
            (ing) => excludeLower.any((ex) => ing.toLowerCase().trim().contains(ex)),
          );
        }).toList();
      }

      meals.value = filteredMeals;
    } catch (e) {
      meals.value = [];
      Get.snackbar(
        'Error',
        'ไม่สามารถใช้ตัวกรองได้: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
      print('Error filtering meals: $e');
    } finally {
      loading.value = false;
    }
  }

  void clearMeals() {
    meals.value = [];
  }
}