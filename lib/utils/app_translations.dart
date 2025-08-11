// utils/app_translations.dart
import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      // App Title
      'app_title': 'Easy Cook',
      'meal_menu': 'Meal Menu',
      
      // Search
      'search_by_ingredients': 'Search by Ingredients',
      'search_by_name': 'Search by Name',
      'ingredients': 'Ingredients',
      'meal_name': 'Meal Name',
      'search_ingredients_hint': 'e.g. chicken, onion, garlic',
      'search_name_hint': 'e.g. Pad Thai, Tom Yum',
      'search': 'Search',
      
      // Buttons
      'random': 'Random',
      'filter': 'Filter',
      'allergies': 'Allergies',
      'apply_filter': 'Apply Filter',
      'reset': 'Reset',
      'clear_all': 'Clear All',
      'add': 'Add',
      'remove_all': 'Remove All',
      
      // Sections
      'ingredients_section': 'Ingredients',
      'instructions_section': 'Instructions',
      'cooking_steps': 'Cooking Steps',
      'watch_video': 'Watch Video Tutorial',
      'step': 'Step',
      
      // Filter
      'meal_filter': 'Meal Filter',
      'food_category': 'Food Category',
      'country': 'Country',
      'all': 'All',
      
      // Allergy
      'allergy_management': 'Allergy Management',
      'add_allergy': 'Add Allergy',
      'allergy_hint': 'e.g. peanut, milk, egg',
      'no_allergies': 'No Allergies',
      
      // Results
      'search_results': 'Search Results',
      'no_meals_found': 'No Meals Found',
      'try_different_search': 'Try different ingredients or press "Random"',
      'try_different_name': 'Try different meal name or press "Random"',
      'random_meals': 'Random Meals',
      'items_count': '@count items',
      'menus_count': '@count menus',
      'as_needed': 'as needed',
      
      // Loading
      'loading_ingredients': 'Searching by ingredients...',
      'loading_name': 'Searching by name...',
      
      // Categories
      'beef': 'Beef',
      'chicken': 'Chicken',
      'dessert': 'Dessert',
      'lamb': 'Lamb',
      'miscellaneous': 'Miscellaneous',
      'pasta': 'Pasta',
      'pork': 'Pork',
      'seafood': 'Seafood',
      'side': 'Side',
      'starter': 'Starter',
      'vegan': 'Vegan',
      'vegetarian': 'Vegetarian',
      
      // Countries
      'american': 'American',
      'british': 'British',
      'canadian': 'Canadian',
      'chinese': 'Chinese',
      'french': 'French',
      'indian': 'Indian',
      'italian': 'Italian',
      'japanese': 'Japanese',
      'mexican': 'Mexican',
      'thai': 'Thai',
      'turkish': 'Turkish',
      'vietnamese': 'Vietnamese',
      
      // Errors
      'error': 'Error',
      'please_enter_ingredients': 'Please enter ingredients',
      'please_enter_meal_name': 'Please enter meal name',
      'please_enter_allergy': 'Please enter allergy',
      'allergy_already_exists': 'This allergy already exists',
      'allergy_added': 'Allergy added: @allergy',
      'all_allergies_removed': 'All allergies removed',
      
      // Settings
      'settings': 'Settings',
      'language': 'Language',
      'english': 'English',
      'thai': 'ไทย',
    },
    
    'th_TH': {
      // App Title
      'app_title': 'อีซี่คุก',
      'meal_menu': 'เมนูอาหาร',
      
      // Search
      'search_by_ingredients': 'ค้นหาด้วยส่วนผสม',
      'search_by_name': 'ค้นหาด้วยชื่อเมนู',
      'ingredients': 'ส่วนผสม',
      'meal_name': 'ชื่อเมนู',
      'search_ingredients_hint': 'เช่น ไก่, หัวหอม, กระเทียม',
      'search_name_hint': 'เช่น ผัดไทย, ต้มยำกุ้ง',
      'search': 'ค้นหา',
      
      // Buttons
      'random': 'สุ่ม',
      'filter': 'ตัวกรอง',
      'allergies': 'อาหารแพ้',
      'apply_filter': 'ใช้ตัวกรอง',
      'reset': 'รีเซ็ต',
      'clear_all': 'ล้างทั้งหมด',
      'add': 'เพิ่ม',
      'remove_all': 'ลบทั้งหมด',
      
      // Sections
      'ingredients_section': 'ส่วนผสม',
      'instructions_section': 'วิธีทำ',
      'cooking_steps': 'ขั้นตอนการทำอาหาร',
      'watch_video': 'ดูวิดีโอสอนทำ',
      'step': 'ขั้นตอนที่',
      
      // Filter
      'meal_filter': 'ตัวกรองเมนูอาหาร',
      'food_category': 'หมวดหมู่อาหาร',
      'country': 'ประเทศ',
      'all': 'ทั้งหมด',
      
      // Allergy
      'allergy_management': 'จัดการอาหารที่แพ้',
      'add_allergy': 'เพิ่มอาหารที่แพ้',
      'allergy_hint': 'เช่น ถั่วลิสง, นม, ไข่',
      'no_allergies': 'ไม่มีอาหารที่แพ้',
      
      // Results
      'search_results': 'ผลการค้นหา',
      'no_meals_found': 'ไม่พบเมนูอาหาร',
      'try_different_search': 'ลองค้นหาด้วยส่วนผสมอื่น หรือกดปุ่ม "สุ่ม"',
      'try_different_name': 'ลองค้นหาด้วยชื่อเมนูอื่น หรือกดปุ่ม "สุ่ม"',
      'random_meals': 'สุ่มเมนู',
      'items_count': '@count รายการ',
      'menus_count': '@count เมนู',
      'as_needed': 'ตามต้องการ',
      
      // Loading
      'loading_ingredients': 'กำลังค้นหาจากส่วนผสม...',
      'loading_name': 'กำลังค้นหาจากชื่อเมนู...',
      
      // Categories
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
      
      // Countries
      'american': 'อเมริกัน',
      'british': 'อังกฤษ',
      'canadian': 'แคนาดา',
      'chinese': 'จีน',
      'french': 'ฝรั่งเศส',
      'indian': 'อินเดีย',
      'italian': 'อิตาลี',
      'japanese': 'ญี่ปุ่น',
      'mexican': 'เม็กซิกัน',
      'thai': 'ไทย',
      'turkish': 'ตุรกี',
      'vietnamese': 'เวียดนาม',
      
      // Errors
      'error': 'ข้อผิดพลาด',
      'please_enter_ingredients': 'กรุณากรอกส่วนผสม',
      'please_enter_meal_name': 'กรุณากรอกชื่อเมนู',
      'please_enter_allergy': 'กรุณากรอกอาหารที่แพ้',
      'allergy_already_exists': 'มีอาหารนี้อยู่แล้ว',
      'allergy_added': 'เพิ่มอาหารแพ้แล้ว: @allergy',
      'all_allergies_removed': 'ลบอาหารแพ้ทั้งหมดแล้ว',
      
      // Settings
      'settings': 'ตั้งค่า',
      'language': 'ภาษา',
      'english': 'English',
      'thai': 'ไทย',
    },
  };
}