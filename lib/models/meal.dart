// models/meal.dart
import 'package:get/get.dart';
import '../services/translation_service.dart';

class Meal {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;
  final String strInstructions;
  final List<String> ingredients;
  final String? strCategory;
  final String? strArea;
  final String? strYoutube;
  final List<String> measurements;
  
  // Thai translations (cached)
  String? _thaiMealName;
  List<String>? _thaiIngredients;
  String? _thaiInstructions;
  String? _thaiCategory;
  String? _thaiArea;

  Meal({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
    required this.strInstructions,
    required this.ingredients,
    this.strCategory,
    this.strArea,
    this.strYoutube,
    this.measurements = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    List<String> parsedIngredients = [];
    List<String> parsedMeasurements = [];
    
    // Parse ingredients และ measurements
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measurement = json['strMeasure$i'];
      
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        parsedIngredients.add(ingredient.toString().trim());
        
        if (measurement != null && measurement.toString().trim().isNotEmpty) {
          parsedMeasurements.add(measurement.toString().trim());
        } else {
          parsedMeasurements.add('');
        }
      }
    }
    
    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strInstructions: json['strInstructions'] ?? '',
      ingredients: parsedIngredients,
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strYoutube: json['strYoutube'],
      measurements: parsedMeasurements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strMealThumb': strMealThumb,
      'strInstructions': strInstructions,
      'ingredients': ingredients,
      'strCategory': strCategory,
      'strArea': strArea,
      'strYoutube': strYoutube,
      'measurements': measurements,
    };
  }

  /// Get meal name based on current locale
  Future<String> get localizedMealName async {
    if (Get.locale?.languageCode == 'th') {
      if (_thaiMealName == null) {
        _thaiMealName = await TranslationService.to.translateMealName(strMeal);
      }
      return _thaiMealName ?? strMeal;
    }
    return strMeal;
  }

  /// Get meal name synchronously (uses cache or returns original)
  String get displayMealName {
    if (Get.locale?.languageCode == 'th' && _thaiMealName != null) {
      return _thaiMealName!;
    }
    return strMeal;
  }

  /// Get ingredients based on current locale
  Future<List<String>> get localizedIngredients async {
    if (Get.locale?.languageCode == 'th') {
      if (_thaiIngredients == null) {
        _thaiIngredients = await TranslationService.to.translateIngredients(ingredients);
      }
      return _thaiIngredients ?? ingredients;
    }
    return ingredients;
  }

  /// Get ingredients synchronously (uses cache or returns original)
  List<String> get displayIngredients {
    if (Get.locale?.languageCode == 'th' && _thaiIngredients != null) {
      return _thaiIngredients!;
    }
    return ingredients;
  }

  /// Get instructions based on current locale
  Future<String> get localizedInstructions async {
    if (Get.locale?.languageCode == 'th') {
      if (_thaiInstructions == null) {
        _thaiInstructions = await TranslationService.to.translateInstructions(strInstructions);
      }
      return _thaiInstructions ?? strInstructions;
    }
    return strInstructions;
  }

  /// Get instructions synchronously (uses cache or returns original)
  String get displayInstructions {
    if (Get.locale?.languageCode == 'th' && _thaiInstructions != null) {
      return _thaiInstructions!;
    }
    return strInstructions;
  }

  /// Get category based on current locale
  String? get displayCategory {
    if (Get.locale?.languageCode == 'th' && strCategory != null) {
      return strCategory!.tr; // ใช้ GetX translation
    }
    return strCategory;
  }

  /// Get area based on current locale
  String? get displayArea {
    if (Get.locale?.languageCode == 'th' && strArea != null) {
      return strArea!.toLowerCase().tr; // ใช้ GetX translation
    }
    return strArea;
  }

  /// Initialize translations (call this after creating the meal object)
  Future<void> initializeTranslations() async {
    if (Get.locale?.languageCode == 'th') {
      // Pre-load translations
      _thaiMealName = await TranslationService.to.translateMealName(strMeal);
      _thaiIngredients = await TranslationService.to.translateIngredients(ingredients);
      _thaiInstructions = await TranslationService.to.translateInstructions(strInstructions);
    }
  }

  /// Get formatted ingredients with measurements
  Future<List<String>> get localizedFormattedIngredients async {
    final localIngredients = await localizedIngredients;
    List<String> formatted = [];
    for (int i = 0; i < localIngredients.length; i++) {
      final ingredient = localIngredients[i];
      final measurement = i < measurements.length && measurements[i].isNotEmpty 
          ? measurements[i] 
          : '';
      
      if (measurement.isNotEmpty) {
        formatted.add('$measurement $ingredient');
      } else {
        formatted.add(ingredient);
      }
    }
    return formatted;
  }

  /// Get formatted ingredients synchronously
  List<String> get displayFormattedIngredients {
    final localIngredients = displayIngredients;
    List<String> formatted = [];
    for (int i = 0; i < localIngredients.length; i++) {
      final ingredient = localIngredients[i];
      final measurement = i < measurements.length && measurements[i].isNotEmpty 
          ? measurements[i] 
          : '';
      
      if (measurement.isNotEmpty) {
        formatted.add('$measurement $ingredient');
      } else {
        formatted.add(ingredient);
      }
    }
    return formatted;
  }

  @override
  String toString() {
    return 'Meal{id: $idMeal, name: $strMeal, category: $strCategory, area: $strArea}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meal &&
          runtimeType == other.runtimeType &&
          idMeal == other.idMeal;

  @override
  int get hashCode => idMeal.hashCode;
}