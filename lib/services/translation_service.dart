// services/translation_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TranslationService extends GetxService {
  static TranslationService get to => Get.find();
  
  // Cache สำหรับเก็บคำแปลที่เคยแปลแล้ว
  final Map<String, String> _translationCache = {};
  
  // Google Translate API key (ถ้าต้องการใช้ Google Translate)
  // หรือใช้ Microsoft Translator API หรือ LibreTranslate
  static const String _translateApiUrl = 'https://libretranslate.com/translate';
  
  /// แปลข้อความจากอังกฤษเป็นไทย
  Future<String> translateToThai(String text) async {
    if (text.isEmpty) return text;
    
    // ตรวจสอบ cache ก่อน
    if (_translationCache.containsKey(text)) {
      return _translationCache[text]!;
    }
    
    try {
      // ใช้ LibreTranslate API (Free)
      final response = await http.post(
        Uri.parse(_translateApiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'source': 'en',
          'target': 'th',
          'format': 'text',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['translatedText'] as String;
        
        // เก็บไว้ใน cache
        _translationCache[text] = translatedText;
        return translatedText;
      }
    } catch (e) {
      print('Translation error: $e');
    }
    
    // ถ้าแปลไม่สำเร็จ ใช้ dictionary สำรอง
    return _getFromDictionary(text);
  }
  
  /// Dictionary สำหรับคำที่ใช้บ่อย
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
      
      // เครื่องเทศ
      'salt': 'เกลือ',
      'pepper': 'พริกไทย',
      'sugar': 'น้ำตาล',
      'oil': 'น้ำมัน',
      'soy sauce': 'ซอสถั่วเหลือง',
      'vinegar': 'น้ำส้มสายชู',
      
      // หมวดหมู่
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
      
      // ประเทศ
      'American': 'อเมริกัน',
      'British': 'อังกฤษ',
      'Chinese': 'จีน',
      'French': 'ฝรั่งเศส',
      'Indian': 'อินเดีย',
      'Italian': 'อิตาลี',
      'Japanese': 'ญี่ปุ่น',
      'Mexican': 'เม็กซิกัน',
      'Thai': 'ไทย',
      'Turkish': 'ตุรกี',
      'Vietnamese': 'เวียดนาม',
    };
    
    return dictionary[text.toLowerCase()] ?? text;
  }
  
  /// แปลรายการส่วนผสมทั้งหมด
  Future<List<String>> translateIngredients(List<String> ingredients) async {
    List<String> translatedIngredients = [];
    
    for (String ingredient in ingredients) {
      final translated = await translateToThai(ingredient);
      translatedIngredients.add(translated);
    }
    
    return translatedIngredients;
  }
  
  /// แปลชื่อเมนูอาหาร
  Future<String> translateMealName(String mealName) async {
    return await translateToThai(mealName);
  }
  
  /// แปลคำแนะนำการทำอาหาร
  Future<String> translateInstructions(String instructions) async {
    // แบ่งคำแนะนำออกเป็นประโยค แล้วแปลทีละประโยค
    final sentences = instructions.split('. ');
    List<String> translatedSentences = [];
    
    for (String sentence in sentences) {
      if (sentence.trim().isNotEmpty) {
        final translated = await translateToThai(sentence.trim());
        translatedSentences.add(translated);
      }
    }
    
    return translatedSentences.join('. ');
  }
  
  /// ค้นหาเมนูด้วยคำไทย
  String translateThaiToEnglish(String thaiText) {
    final reverseDict = {
      'ไก่': 'chicken',
      'เนื้อวัว': 'beef',
      'หมู': 'pork',
      'ปลา': 'fish',
      'กุ้ง': 'shrimp',
      'ไข่': 'egg',
      'ข้าว': 'rice',
      'ก๋วยเตี๋ยว': 'noodles',
      'หัวหอม': 'onion',
      'กระเทียม': 'garlic',
      'มะเขือเทศ': 'tomato',
      'แครอท': 'carrot',
      'มันฝรั่ง': 'potato',
      'ผัดไทย': 'pad thai',
      'ต้มยำ': 'tom yum',
      'แกงเขียวหวาน': 'green curry',
      'ส้มตำ': 'papaya salad',
      'มาสมั่น': 'massaman',
    };
    
    // แปลงเป็นตัวพิมพ์เล็ก และตรวจหา
    final lowerThai = thaiText.toLowerCase();
    for (final entry in reverseDict.entries) {
      if (lowerThai.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return thaiText; // ถ้าไม่พบให้ return ตัวเดิม
  }
  
  /// เคลียร์ cache
  void clearCache() {
    _translationCache.clear();
  }
}