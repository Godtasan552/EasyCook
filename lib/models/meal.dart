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
      // ใช้ static dictionary แทนการเรียก API
      final categoryMap = {
        'Beef': 'เนื้อวัว',
        'Chicken': 'ไก่',
        'Dessert': 'ของหวาน',
        'Lamb': 'เนื้อแกะ',
        'Miscellaneous': 'อื่นๆ',
        'Pasta': 'พาสต้า',
        'Pork': 'หมู',
        'Seafood': 'อาหารทะเล',
        'Side': 'จานเคียง',
        'Starter': 'จานเปิด',
        'Vegan': 'เจ',
        'Vegetarian': 'มังสวิรัติ',
      };
      return categoryMap[strCategory] ?? strCategory;
    }
    return strCategory;
  }

  /// Get area based on current locale
  String? get displayArea {
    if (Get.locale?.languageCode == 'th' && strArea != null) {
      // ใช้ static dictionary แทนการเรียก API
      final areaMap = {
        'American': 'อเมริกัน',
        'British': 'อังกฤษ',
        'Canadian': 'แคนาดา',
        'Chinese': 'จีน',
        'Croatian': 'โครเอเชีย',
        'Dutch': 'เนเธอร์แลนด์',
        'Egyptian': 'อียิปต์',
        'French': 'ฝรั่งเศส',
        'Greek': 'กรีก',
        'Indian': 'อินเดีย',
        'Irish': 'ไอร์แลนด์',
        'Italian': 'อิตาลี',
        'Jamaican': 'จาเมกา',
        'Japanese': 'ญี่ปุ่น',
        'Kenyan': 'เคนยา',
        'Malaysian': 'มาเลเซีย',
        'Mexican': 'เม็กซิกัน',
        'Moroccan': 'โมร็อกโก',
        'Polish': 'โปแลนด์',
        'Portuguese': 'โปรตุเกส',
        'Russian': 'รัสเซีย',
        'Spanish': 'สเปน',
        'Thai': 'ไทย',
        'Tunisian': 'ตูนิเซีย',
        'Turkish': 'ตุรกี',
        'Ukrainian': 'ยูเครน',
        'Unknown': 'ไม่ระบุ',
        'Vietnamese': 'เวียดนาม',
      };
      return areaMap[strArea] ?? strArea;
    }
    return strArea;
  }

  /// Initialize translations (call this after creating the meal object)
  Future<void> initializeTranslations() async {
    if (Get.locale?.languageCode == 'th' && Get.isRegistered<TranslationService>()) {
      try {
        // Pre-load translations
        _thaiMealName = await TranslationService.to.translateMealName(strMeal);
        _thaiIngredients = await TranslationService.to.translateIngredients(ingredients);
        _thaiInstructions = await TranslationService.to.translateInstructions(strInstructions);
      } catch (e) {
        print('Error initializing translations: $e');
        // ถ้าแปลไม่สำเร็จ ใช้ fallback dictionary
        _thaiMealName = _getFromDictionary(strMeal);
        _thaiIngredients = ingredients.map((ing) => _getFromDictionary(ing)).toList();
        _thaiInstructions = strInstructions; // คงเดิมถ้าแปลไม่ได้
      }
    }
  }

  /// Fallback dictionary for common ingredients
  String _getFromDictionary(String text) {
    final dictionary = {
      // อาหารหลัก
      'chicken': 'ไก่',
      'beef': 'เนื้อวัว',
      'pork': 'หมู',
      'fish': 'ปลา',
      'shrimp': 'กุ้ง',
      'egg': 'ไข่',
      'rice': 'ข้าว',
      'noodles': 'ก๋วยเตี๋ยว',
      
      // ผัก
      'onion': 'หัวหอม',
      'garlic': 'กระเทียม',
      'tomato': 'มะเขือเทศ',
      'carrot': 'แครอท',
      'potato': 'มันฝรั่ง',
      'cabbage': 'กะหล่ำปลี',
      'lettuce': 'ผักกาดหอม',
      'ginger': 'ขิง',
      'lemon': 'มะนาว',
      'lime': 'มะนาว',
      'coconut milk': 'กะทิ',
      
      // เครื่องเทศ
      'salt': 'เกลือ',
      'pepper': 'พริกไทย',
      'sugar': 'น้ำตาล',
      'oil': 'น้ำมัน',
      'soy sauce': 'ซอสถั่วเหลือง',
      'vinegar': 'น้ำส้มสายชู',
      'fish sauce': 'น้ำปลา',
      'oyster sauce': 'น้ำมันหอย',
      
      // เมนูไทยยอดนิยม
      'Pad Thai': 'ผัดไทย',
      'Tom Yum': 'ต้มยำ',
      'Green Curry': 'แกงเขียวหวาน',
      'Massaman Curry': 'แกงมัสมั่น',
      'Som Tam': 'ส้มตำ',
      'Mango Sticky Rice': 'ข้าวเหนียวมะม่วง',
      'Thai Fried Rice': 'ข้าวผัดไทย',
      'Papaya Salad': 'ส้มตำ',
    };
    
    // ตรวจหาคำที่ตรงกัน (case insensitive)
    final lowerText = text.toLowerCase();
    for (final entry in dictionary.entries) {
      if (lowerText.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    return text; // คืนค่าเดิมถ้าไม่พบใน dictionary
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

  /// Clear cached translations (ใช้เมื่อเปลี่ยนภาษา)
  void clearTranslations() {
    _thaiMealName = null;
    _thaiIngredients = null;
    _thaiInstructions = null;
    _thaiCategory = null;
    _thaiArea = null;
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