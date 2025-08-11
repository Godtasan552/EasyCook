import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class ApiService {
  static const _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// ค้นหาจากส่วนผสม + กรองแพ้
  Future<List<Meal>> searchMealsByIngredient(
    String ingredient, {
    List<String>? excludeIngredients,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/filter.php?i=${Uri.encodeComponent(ingredient)}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] == null) return [];

        List mealsBrief = data['meals'];
        List<Meal> fullMeals = [];

        for (var mealBrief in mealsBrief) {
          try {
            final detail = await fetchMealDetail(mealBrief['idMeal']);
            if (detail != null) {
              // ตรวจสอบว่ามีส่วนผสมแพ้หรือไม่
              bool hasExcluded = false;
              if (excludeIngredients != null && excludeIngredients.isNotEmpty) {
                final excludeLower = excludeIngredients
                    .map((e) => e.toLowerCase().trim())
                    .toList();
                
                for (var ing in detail.ingredients) {
                  if (excludeLower.any(
                    (ex) => ing.toLowerCase().trim().contains(ex),
                  )) {
                    hasExcluded = true;
                    break;
                  }
                }
              }
              
              if (!hasExcluded) {
                fullMeals.add(detail);
              }
            }
          } catch (e) {
            print('Error fetching meal detail for ${mealBrief['idMeal']}: $e');
            continue;
          }
        }
        return fullMeals;
      }
      throw Exception('Failed to load meals: ${response.statusCode}');
    } catch (e) {
      print('Error searching meals by ingredient: $e');
      throw Exception('Failed to search meals: $e');
    }
  }

  /// ดึงข้อมูลเมนูโดยใช้ id
  Future<Meal?> fetchMealDetail(String idMeal) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lookup.php?i=${Uri.encodeComponent(idMeal)}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return Meal.fromJson(data['meals'][0]);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching meal detail: $e');
      return null;
    }
  }

  /// สุ่มเมนู + กรองแพ้
  Future<Meal?> fetchRandomMeal({List<String>? excludeIngredients}) async {
    const int maxAttempts = 10;
    
    for (int i = 0; i < maxAttempts; i++) {
      try {
        final response = await http.get(Uri.parse('$_baseUrl/random.php'));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['meals'] != null && data['meals'].isNotEmpty) {
            final meal = Meal.fromJson(data['meals'][0]);

            // ตรวจสอบส่วนผสมแพ้
            if (excludeIngredients != null && excludeIngredients.isNotEmpty) {
              final excludeLower = excludeIngredients
                  .map((e) => e.trim().toLowerCase())
                  .toList();
              
              bool hasExcluded = meal.ingredients.any(
                (ing) => excludeLower.any(
                  (ex) => ing.trim().toLowerCase().contains(ex),
                ),
              );
              
              if (!hasExcluded) {
                return meal;
              }
            } else {
              return meal;
            }
          }
        }
      } catch (e) {
        print('Error fetching random meal (attempt ${i + 1}): $e');
      }
    }
    
    // ถ้าไม่พบเมนูที่เหมาะสมหลังจากพยายาม maxAttempts ครั้ง
    return null;
  }

  /// ค้นหาเมนูด้วยชื่อ
  Future<List<Meal>> searchMealsByName(String name) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search.php?s=${Uri.encodeComponent(name)}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] == null) return [];

        List mealsList = data['meals'];
        return mealsList.map((json) => Meal.fromJson(json)).toList();
      }
      throw Exception('Failed to search meals by name: ${response.statusCode}');
    } catch (e) {
      print('Error searching meals by name: $e');
      throw Exception('Failed to search meals: $e');
    }
  }

  /// ค้นหาเมนูตาม category
  Future<List<Meal>> searchMealsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/filter.php?c=${Uri.encodeComponent(category)}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] == null) return [];

        List mealsBrief = data['meals'];
        List<Meal> fullMeals = [];

        // เนื่องจาก API filter ให้เฉพาะข้อมูลพื้นฐาน เราจึงต้องดึงรายละเอียดแต่ละเมนู
        // แต่เพื่อประสิทธิภาพ เราจำกัดจำนวน
        final limitedMeals = mealsBrief.take(20).toList();
        
        for (var mealBrief in limitedMeals) {
          try {
            final detail = await fetchMealDetail(mealBrief['idMeal']);
            if (detail != null) {
              fullMeals.add(detail);
            }
          } catch (e) {
            print('Error fetching meal detail for ${mealBrief['idMeal']}: $e');
            continue;
          }
        }
        return fullMeals;
      }
      throw Exception('Failed to search meals by category: ${response.statusCode}');
    } catch (e) {
      print('Error searching meals by category: $e');
      throw Exception('Failed to search meals: $e');
    }
  }

  /// ค้นหาเมนูตาม area (ประเทศ)
  Future<List<Meal>> searchMealsByArea(String area) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/filter.php?a=${Uri.encodeComponent(area)}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] == null) return [];

        List mealsBrief = data['meals'];
        List<Meal> fullMeals = [];

        // จำกัดจำนวนเพื่อประสิทธิภาพ
        final limitedMeals = mealsBrief.take(20).toList();
        
        for (var mealBrief in limitedMeals) {
          try {
            final detail = await fetchMealDetail(mealBrief['idMeal']);
            if (detail != null) {
              fullMeals.add(detail);
            }
          } catch (e) {
            print('Error fetching meal detail for ${mealBrief['idMeal']}: $e');
            continue;
          }
        }
        return fullMeals;
      }
      throw Exception('Failed to search meals by area: ${response.statusCode}');
    } catch (e) {
      print('Error searching meals by area: $e');
      throw Exception('Failed to search meals: $e');
    }
  }

  /// ดึงรายการ categories ทั้งหมด
  Future<List<String>> getAllCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories.php'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['categories'] != null) {
          List categories = data['categories'];
          return categories
              .map<String>((cat) => cat['strCategory'] as String)
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  /// ดึงรายการ areas ทั้งหมด
  Future<List<String>> getAllAreas() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/list.php?a=list'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] != null) {
          List areas = data['meals'];
          return areas
              .map<String>((area) => area['strArea'] as String)
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching areas: $e');
      return [];
    }
  }
}