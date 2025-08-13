// services/translation_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TranslationService extends GetxService {
  static TranslationService get to => Get.find();
  
  // Cache สำหรับเก็บคำแปลที่เคยแปลแล้ว
  final Map<String, String> _translationCache = {};
  
  // ใช้ Microsoft Translator API (Free Tier) หรือ Google Translate
  static const String _translateApiUrl = 'https://api.mymemory.translated.net/get';
  
  @override
  void onInit() {
    super.onInit();
    print('TranslationService initialized');
  }

  /// แปลข้อความจากอังกฤษเป็นไทย
  Future<String> translateToThai(String text) async {
    if (text.isEmpty) return text;
    
    // ถ้าข้อความเป็นภาษาไทยอยู่แล้วหรือมีตัวเลข/สัญลักษณ์เป็นหลัก
    if (_isThaiOrNumeric(text)) {
      return text;
    }
    
    // ตรวจสอบ cache ก่อน
    final cacheKey = 'en_th_$text';
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }
    
    try {
      // ลองใช้ dictionary ก่อน (เร็วกว่า)
      final dictResult = _getFromDictionary(text);
      if (dictResult != text) {
        _translationCache[cacheKey] = dictResult;
        return dictResult;
      }

      // ใช้ MyMemory Translator API (Free และไม่ต้อง API Key)
      final response = await http.get(
        Uri.parse('$_translateApiUrl?q=${Uri.encodeComponent(text)}&langpair=en|th'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['responseStatus'] == 200 && data['responseData'] != null) {
          final translatedText = data['responseData']['translatedText'] as String;
          
          // ตรวจสอบว่าผลลัพธ์ไม่ใช่ error message
          if (!translatedText.toLowerCase().contains('error') && 
              !translatedText.toLowerCase().contains('invalid')) {
            _translationCache[cacheKey] = translatedText;
            return translatedText;
          }
        }
      }
    } catch (e) {
      print('Translation API error: $e');
    }
    
    // ถ้าแปลไม่สำเร็จ ใช้ dictionary สำรอง
    final fallbackResult = _getFromDictionary(text);
    _translationCache[cacheKey] = fallbackResult;
    return fallbackResult;
  }
  
  /// ตรวจสอบว่าข้อความเป็นภาษาไทยหรือตัวเลข/สัญลักษณ์
  bool _isThaiOrNumeric(String text) {
    // ตรวจสอบว่ามีอักษรไทย
    final thaiRegex = RegExp(r'[\u0E00-\u0E7F]');
    if (thaiRegex.hasMatch(text)) return true;
    
    // ตรวจสอบว่าเป็นตัวเลข/สัญลักษณ์เป็นหลัก
    final nonAlphaRegex = RegExp(r'^[^a-zA-Z]*$');
    if (nonAlphaRegex.hasMatch(text)) return true;
    
    return false;
  }
  
  /// Dictionary ที่ครอบคลุมมากขึ้นสำหรับคำที่ใช้บ่อย
  String _getFromDictionary(String text) {
    final lowerText = text.toLowerCase().trim();
    
    // Dictionary หลัก
    final dictionary = {
      // อาหารหลัก
      'chicken': 'ไก่',
      'beef': 'เนื้อวัว', 
      'pork': 'หมู',
      'fish': 'ปลา',
      'shrimp': 'กุ้ง',
      'prawns': 'กุ้ง',
      'egg': 'ไข่',
      'eggs': 'ไข่',
      'rice': 'ข้าว',
      'noodles': 'ก๋วยเตี๋ยว',
      'pasta': 'พาสต้า',
      'bread': 'ขนมปัง',
      'cheese': 'ชีส',
      'milk': 'นม',
      'butter': 'เนย',
      'cream': 'ครีม',
      
      // ผัก
      'onion': 'หัวหอม',
      'onions': 'หัวหอม',
      'garlic': 'กระเทียม',
      'tomato': 'มะเขือเทศ',
      'tomatoes': 'มะเขือเทศ',
      'carrot': 'แครอท',
      'carrots': 'แครอท',
      'potato': 'มันฝรั่ง',
      'potatoes': 'มันฝรั่ง',
      'cabbage': 'กะหล่ำปลี',
      'lettuce': 'ผักกาดหอม',
      'cucumber': 'แตงกวา',
      'mushroom': 'เห็ด',
      'mushrooms': 'เห็ด',
      'bell pepper': 'พริกหยวก',
      'chili': 'พริก',
      'ginger': 'ขิง',
      'lemongrass': 'ตะไคร้',
      'basil': 'โหระพา',
      'cilantro': 'ผักชี',
      'mint': 'สะระแหน่',
      'lime': 'มะนาว',
      'lemon': 'มะนาว',
      'coconut': 'มะพร้าว',
      'coconut milk': 'กะทิ',
      
      // เครื่องเทศและปรุงรส
      'salt': 'เกลือ',
      'pepper': 'พริกไทย',
      'black pepper': 'พริกไทยดำ',
      'white pepper': 'พริกไทยขาว',
      'sugar': 'น้ำตาล',
      'brown sugar': 'น้ำตาลแดง',
      'oil': 'น้ำมัน',
      'olive oil': 'น้ำมันมะกอก',
      'vegetable oil': 'น้ำมันพืช',
      'sesame oil': 'น้ำมันงา',
      'soy sauce': 'ซอสถั่วเหลือง',
      'light soy sauce': 'ซีอิ๊วขาว',
      'dark soy sauce': 'ซีอิ๊วดำ',
      'fish sauce': 'น้ำปลา',
      'oyster sauce': 'น้ำมันหอย',
      'vinegar': 'น้ำส้มสายชู',
      'rice vinegar': 'น้ำส้มสายชูข้าว',
      'tamarind': 'มะขาม',
      'curry powder': 'ผงกะหรี่',
      'turmeric': 'ขมิ้น',
      'coriander': 'ผักชี',
      'cumin': 'ยี่หร่า',
      'cardamom': 'กระวาน',
      'cinnamon': 'อบเชย',
      'star anise': 'โป๊ยกั๊ก',
      
      // เมนูไทยและเอเชีย
      'pad thai': 'ผัดไทย',
      'tom yum': 'ต้มยำ',
      'tom kha': 'ต้มข่า',
      'green curry': 'แกงเขียวหวาน',
      'red curry': 'แกงเผด',
      'massaman curry': 'แกงมัสมั่น',
      'panang curry': 'แกงพะแนง',
      'som tam': 'ส้มตำ',
      'papaya salad': 'ส้มตำ',
      'mango sticky rice': 'ข้าวเหนียวมะม่วง',
      'thai fried rice': 'ข้าวผัดไทย',
      'pad see ew': 'ผัดซีอิ๊ว',
      'pad kra pao': 'ผัดกะเพรา',
      'larb': 'ลาบ',
      'satay': 'สะเต๊ะ',
      'spring rolls': 'ปอเปี๊ยะ',
      'fried rice': 'ข้าวผัด',
      'stir fry': 'ผัด',
      'soup': 'ซุป',
      'salad': 'สลัด',
      
      // หมวดหมู่อาหาร
      'beef': 'เนื้อวัว',
      'chicken': 'ไก่',
      'dessert': 'ของหวาน',
      'lamb': 'เนื้อแกะ',
      'miscellaneous': 'อื่นๆ',
      'pasta': 'พาสต้า',
      'pork': 'หมู',
      'seafood': 'อาหารทะเล',
      'side': 'จานเคียง',
      'starter': 'จานเปิด',
      'vegan': 'เจ',
      'vegetarian': 'มังสวิรัติ',
      
      // ประเทศ
      'american': 'อเมริกัน',
      'british': 'อังกฤษ',
      'canadian': 'แคนาดา',
      'chinese': 'จีน',
      'croatian': 'โครเอเชีย',
      'dutch': 'เนเธอร์แลนด์',
      'egyptian': 'อียิปต์',
      'french': 'ฝรั่งเศส',
      'greek': 'กรีก',
      'indian': 'อินเดีย',
      'irish': 'ไอร์แลนด์',
      'italian': 'อิตาลี',
      'jamaican': 'จาเมกา',
      'japanese': 'ญี่ปุ่น',
      'kenyan': 'เคนยา',
      'malaysian': 'มาเลเซีย',
      'mexican': 'เม็กซิกัน',
      'moroccan': 'โมร็อกโก',
      'polish': 'โปแลนด์',
      'portuguese': 'โปรตุเกส',
      'russian': 'รัสเซีย',
      'spanish': 'สเปน',
      'thai': 'ไทย',
      'tunisian': 'ตูนิเซีย',
      'turkish': 'ตุรกี',
      'ukrainian': 'ยูเครน',
      'unknown': 'ไม่ระบุ',
      'vietnamese': 'เวียดนาม',
      
      // หน่วยวัด
      'cup': 'ถ้วย',
      'cups': 'ถ้วย',
      'tablespoon': 'ช้อนโต๊ะ',
      'tablespoons': 'ช้อนโต๊ะ',
      'teaspoon': 'ช้อนชา',
      'teaspoons': 'ช้อนชา',
      'gram': 'กรัม',
      'grams': 'กรัม',
      'kilogram': 'กิโลกรัม',
      'pound': 'ปอนด์',
      'pounds': 'ปอนด์',
      'ounce': 'ออนซ์',
      'ounces': 'ออนซ์',
      'liter': 'ลิตร',
      'liters': 'ลิตร',
      'milliliter': 'มิลลิลิตร',
      'pinch': 'หยิบมือ',
      'dash': 'เล็กน้อย',
      'to taste': 'ตามใจชอบ',
      'as needed': 'ตามต้องการ',
      
      // คำทั่วไป
      'fresh': 'สด',
      'dried': 'แห้ง',
      'chopped': 'หั่น',
      'sliced': 'ชิ้น',
      'minced': 'สับ',
      'diced': 'หั่นเต็าซี่',
      'ground': 'บด',
      'whole': 'ทั้งลูก',
      'large': 'ใหญ่',
      'medium': 'กลาง',
      'small': 'เล็ก',
      'thick': 'หนา',
      'thin': 'บาง',
      'hot': 'ร้อน',
      'cold': 'เย็น',
      'sweet': 'หวาน',
      'sour': 'เปรี้ยว',
      'spicy': 'เผ็ด',
      'salty': 'เค็ม',
      'bitter': 'ขม',
    };
    
    // ค้นหาคำที่ตรงกันทั้งหมด
    if (dictionary.containsKey(lowerText)) {
      return dictionary[lowerText]!;
    }
    
    // ค้นหาแบบ partial match
    for (final entry in dictionary.entries) {
      if (lowerText.contains(entry.key)) {
        return text.replaceAll(RegExp(entry.key, caseSensitive: false), entry.value);
      }
    }
    
    return text; // คืนค่าเดิมถ้าไม่พบใน dictionary
  }
  
  /// แปลรายการส่วนผสมทั้งหมด
  Future<List<String>> translateIngredients(List<String> ingredients) async {
    List<String> translatedIngredients = [];
    
    for (String ingredient in ingredients) {
      if (ingredient.trim().isEmpty) {
        translatedIngredients.add(ingredient);
        continue;
      }
      
      final translated = await translateToThai(ingredient);
      translatedIngredients.add(translated);
    }
    
    return translatedIngredients;
  }
  
  /// แปลชื่อเมนูอาหาร
  Future<String> translateMealName(String mealName) async {
    if (mealName.trim().isEmpty) return mealName;
    return await translateToThai(mealName);
  }
  
  /// แปลคำแนะนำการทำอาหาร
  Future<String> translateInstructions(String instructions) async {
    if (instructions.trim().isEmpty) return instructions;
    
    try {
      // แบ่งคำแนะนำออกเป็นประโยค
      final sentences = instructions.split(RegExp(r'[.!?]+\s*'));
      List<String> translatedSentences = [];
      
      for (String sentence in sentences) {
        final trimmed = sentence.trim();
        if (trimmed.isNotEmpty) {
          final translated = await translateToThai(trimmed);
          translatedSentences.add(translated);
        }
      }
      
      return translatedSentences.join('. ');
    } catch (e) {
      print('Error translating instructions: $e');
      return instructions; // คืนค่าเดิมถ้าแปลไม่สำเร็จ
    }
  }
  
  /// ค้นหาเมนูด้วยคำไทย (แปลกลับเป็นอังกฤษ)
  String translateThaiToEnglish(String thaiText) {
    if (thaiText.trim().isEmpty) return thaiText;
    
    final reverseDict = {
      // อาหารหลัก
      'ไก่': 'chicken',
      'เนื้อวัว': 'beef',
      'หมู': 'pork',
      'ปลา': 'fish',
      'กุ้ง': 'shrimp',
      'ไข่': 'egg',
      'ข้าว': 'rice',
      'ก๋วยเตี๋ยว': 'noodles',
      'พาสต้า': 'pasta',
      
      // ผัก
      'หัวหอม': 'onion',
      'กระเทียม': 'garlic',
      'มะเขือเทศ': 'tomato',
      'แครอท': 'carrot',
      'มันฝรั่ง': 'potato',
      'เห็ด': 'mushroom',
      'พริก': 'chili',
      'ขิง': 'ginger',
      'มะนาว': 'lime',
      'กะทิ': 'coconut milk',
      
      // เมนูไทย
      'ผัดไทย': 'pad thai',
      'ต้มยำ': 'tom yum',
      'ต้มข่า': 'tom kha',
      'แกงเขียวหวาน': 'green curry',
      'แกงเผด': 'red curry',
      'แกงมัสมั่น': 'massaman curry',
      'แกงพะแนง': 'panang curry',
      'ส้มตำ': 'papaya salad',
      'ข้าวเหนียวมะม่วง': 'mango sticky rice',
      'ข้าวผัดไทย': 'thai fried rice',
      'ผัดซีอิ๊ว': 'pad see ew',
      'ผัดกะเพรา': 'pad kra pao',
      'ลาบ': 'larb',
      'สะเต๊ะ': 'satay',
      
      // หมวดหมู่
      'เนื้อวัว': 'beef',
      'ของหวาน': 'dessert',
      'เนื้อแกะ': 'lamb',
      'อาหารทะเล': 'seafood',
      'มังสวิรัติ': 'vegetarian',
      'เจ': 'vegan',
      
      // ประเทศ
      'อเมริกัน': 'american',
      'อังกฤษ': 'british',
      'จีน': 'chinese',
      'ฝรั่งเศส': 'french',
      'อินเดีย': 'indian',
      'อิตาลี': 'italian',
      'ญี่ปุ่น': 'japanese',
      'เม็กซิกัน': 'mexican',
      'ไทย': 'thai',
      'ตุรกี': 'turkish',
      'เวียดนาม': 'vietnamese',
    };
    
    // แปลงเป็นตัวพิมพ์เล็ก และตรวจหา
    final lowerThai = thaiText.toLowerCase().trim();
    for (final entry in reverseDict.entries) {
      if (lowerThai.contains(entry.key)) {
        return thaiText.replaceAll(entry.key, entry.value);
      }
    }
    
    return thaiText; // ถ้าไม่พบให้ return ตัวเดิม
  }
  
  /// เคลียร์ cache
  void clearCache() {
    _translationCache.clear();
    print('Translation cache cleared');
  }
  
  /// ตรวจสอบขนาด cache
  int getCacheSize() {
    return _translationCache.length;
  }
  
  /// แสดงสถิติการแปล
  void printCacheStats() {
    print('Translation cache size: ${_translationCache.length}');
    print('Sample translations:');
    int count = 0;
    for (final entry in _translationCache.entries) {
      if (count >= 5) break;
      print('  ${entry.key} -> ${entry.value}');
      count++;
    }
  }
}