# 🍳 EasyCook – Flutter Recipe Discovery App

EasyCook คือแอป Flutter สำหรับค้นหาสูตรอาหารจากทั่วโลก พร้อมระบบแปลภาษาไทยอัตโนมัติ, การกรองวัตถุดิบที่แพ้, และการค้นหาแบบอัจฉริยะ  
ออกแบบด้วยแนวคิด gradient UI ที่สดใสและใช้งานง่าย รองรับทั้งภาษาไทยและอังกฤษ

---

## 🛠 โครงสร้างโฟลเดอร์

```
lib/
├── main.dart
├── controllers/
│   └── meal_controller.dart
├── models/
│   └── meal.dart
├── screens/
│   ├── home_screen.dart
│   ├── detail.dart
|	├── splash_sceens.dart
│   └── brk.dart (Breaking/Welcome screen)
|	
├── widgets/
│   └── meal_card.dart
├── services/
│   ├── api_service.dart
│   └── translation_service.dart
├── routes/
|	├── app_routers.dart
│   └── app_pages.dart
├── theme/
|	└── app_theme.dart
├── utils/
|	├── app_translations.dart
|	└── navigation_helper.dart
├── widgets
|	└── meal_card.dart
```

---

## 🧠 หลักการทำงานของระบบ

แอปใช้ GetX ในการจัดการสถานะและ navigation  
ข้อมูลสูตรอาหารมาจาก TheMealDB API  
ระบบแปลภาษาใช้ Google Translate API สำหรับแปลสูตรอาหารเป็นภาษาไทย

---

### 🔄 การจัดการสถานะ (State Management)

ใช้ `GetX` controller หลัก 2 ตัว:

```dart
Get.put(MealController());
Get.put(TranslationService());
```

| Controller | หน้าที่ |
|------------|---------|
| `MealController` | จัดการการค้นหา/แสดงผลสูตรอาหาร |
| `TranslationService` | แปลภาษาและจัดการ cache การแปล |

---

## 🔧 โครงสร้าง Model

### Meal Model
```dart
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

  Meal({ required this.idMeal, required this.strMeal, ... });

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(...);
  Map<String, dynamic> toJson() => {...};
}
```

**หน้าที่ของแต่ละฟิลด์:**
- `ingredients`: รายการวัตถุดิบทั้งหมด (1-20 รายการ)
- `measurements`: ปริมาณของแต่ละวัตถุดิบ
- `_thaiMealName`: แคชชื่อเมนูภาษาไทย
- `displayMealName`: แสดงชื่อตามภาษาที่เลือก

---

## 🏠 หน้า Home (Recipe Search & Discovery)

หน้าหลักประกอบด้วย:
- **Search Bar**: ค้นหาจากวัตถุดิบหรือชื่อเมนู
- **Quick Actions**: สุ่มเมนูและจัดการ Filter
- **Allergy Filters**: กรองวัตถุดิบที่แพ้
- **Recipe Grid**: แสดงผลสูตรอาหารแบบ Card

```dart
Widget _buildSearchBar() {
  return Container(
    child: Row(
      children: [
        // Search Mode Toggle (ingredients/name)
        DropdownButton<String>(...),
        // Search Field
        Expanded(child: TextField(...)),
        // Search Button
        IconButton(...),
        // Options Button
        IconButton(...),
      ],
    ),
  );
}
```

- ผู้ใช้สามารถเลือกค้นหาจาก "วัตถุดิบ" หรือ "ชื่อเมนู"
- มี Quick Actions สำหรับสุ่มเมนูและตั้งค่าการกรอง

---

## 🔍 ระบบค้นหาอัจฉริยะ

### ค้นหาจากวัตถุดิบ (Ingredients Search)
```dart
Future<void> searchMeals(List<String> ingredients, List<String> excludeIngredients) async {
  // ค้นหาเมนูทีละวัตถุดิบ
  for (var ingredient in ingredients) {
    final mealsByIngredient = await _apiService.searchMealsByIngredient(ingredient);
    mealsPerIngredient.add(mealsByIngredient);
  }
  
  // หาเมนูที่มีวัตถุดิบทุกตัว (intersection)
  List<Meal> intersectMeals = mealsPerIngredient.first;
  for (var mealList in mealsPerIngredient.skip(1)) {
    intersectMeals = intersectMeals.where((meal) => 
      mealList.any((m) => m.idMeal == meal.idMeal)
    ).toList();
  }
}
```

### ค้นหาจากชื่อเมนู (Name Search)
```dart
Future<void> searchMealsByName(String name, List<String> excludeIngredients) async {
  final searchResults = await _apiService.searchMealsByName(name);
  
  // กรองวัตถุดิบที่แพ้
  final filteredMeals = searchResults.where((meal) {
    return !meal.ingredients.any((ing) => 
      excludeLower.any((ex) => ing.toLowerCase().contains(ex))
    );
  }).toList();
}
```

---

## 🌐 ระบบแปลภาษาอัตโนมัติ

### Translation Service
```dart
class TranslationService extends GetxService {
  final Map<String, String> _cache = {};
  
  Future<String> translateMealName(String mealName) async {
    if (_cache.containsKey(mealName)) return _cache[mealName]!;
    
    final translated = await _translateWithAPI(mealName);
    _cache[mealName] = translated;
    return translated;
  }
  
  Future<List<String>> translateIngredients(List<String> ingredients) async {
    List<String> translated = [];
    for (String ingredient in ingredients) {
      if (_cache.containsKey(ingredient)) {
        translated.add(_cache[ingredient]!);
      } else {
        final result = await _translateWithAPI(ingredient);
        _cache[ingredient] = result;
        translated.add(result);
      }
    }
    return translated;
  }
}
```

**การทำงาน:**
- แคชการแปลเพื่อลดการเรียก API
- แปลชื่อเมนู, วัตถุดิบ, และขั้นตอนการทำ
- Fallback ไปใช้ Static Dictionary ถ้าแปลไม่ได้

---

## 📱 หน้า Recipe Detail

แสดงรายละเอียดสูตรอาหารแบบเต็ม:

```dart
class DetailPage extends StatefulWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: ...),
        child: Column(
          children: [
            // Hero Image
            ClipRRect(child: Image.network(meal.strMealThumb)),
            
            // Info Chips (Category, Area)
            Row(children: [
              _buildInfoChip(icon: Icons.category, label: meal.displayCategory),
              _buildInfoChip(icon: Icons.public, label: meal.displayArea),
            ]),
            
            // Ingredients Section
            _buildIngredientsSection(),
            
            // Instructions Steps
            _buildStepsSection(),
            
            // YouTube Video Link
            if (meal.strYoutube != null) _buildVideoButton(),
          ],
        ),
      ),
    );
  }
}
```

**Features:**
- รูปอาหารขนาดใหญ่พร้อม loading state
- แสดงหมวดหมู่และประเทศต้นกำเนิด
- รายการวัตถุดิบพร้อมปริมาณ
- ขั้นตอนการทำแบบแยกเป็นหมายเลข
- ลิงค์วิดีโอ YouTube (ถ้ามี)

---

## 🎛️ ระบบกรองและตัวเลือก (Advanced Options)

### Bottom Sheet Options
```dart
void _showOptionsBottomSheet() {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      child: Column(
        children: [
          // Category Filter
          DropdownButton<String>(
            value: selectedCategory,
            items: categories.map((category) => 
              DropdownMenuItem(value: category['value'], child: Text(category['key']!.tr))
            ).toList(),
          ),
          
          // Area Filter
          DropdownButton<String>(...),
          
          // Allergy Management
          Wrap(
            children: commonAllergies.map((allergy) => 
              FilterChip(
                label: Text(allergy.tr),
                selected: allergyFilters.contains(allergy),
                onSelected: (selected) => _handleAllergyFilter(allergy, selected),
              )
            ).toList(),
          ),
          
          // Custom Allergy Input
          TextField(...),
        ],
      ),
    ),
  );
}
```

**ตัวเลือกการกรอง:**
- หมวดหมู่อาหาร: เนื้อวัว, ไก่, ของหวาน, เจ ฯลฯ
- ประเทศ: ไทย, อิตาลี, ญี่ปุ่น, เม็กซิกัน ฯลฯ
- อาหารแพ้: ถั่วลิสง, นม, ไข่, กลูเตน ฯลฯ
- กรอกอาหารแพ้เอง: ช่องกรอกข้อความแบบกำหนดเอง

---

## 🎲 ระบบสุ่มเมนู (Random Meals)

```dart
Future<void> loadMultipleRandomMeals({
  int count = 5,
  List<String>? excludeIngredients,
}) async {
  final List<Meal> randomMeals = [];
  final Set<String> usedMealIds = {};

  for (int i = 0; i < count;) {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php'));
    final meal = Meal.fromJson(response.data);
    
    // ตรวจสอบไม่ให้ซ้ำและไม่มีวัตถุดิบแพ้
    if (!usedMealIds.contains(meal.idMeal) && !hasAllergen(meal)) {
      randomMeals.add(meal);
      usedMealIds.add(meal.idMeal);
      i++;
    }
  }
}
```

- สุ่มเมนูไม่ซ้ำกัน
- กรองวัตถุดิบที่แพ้อัตโนมัติ
- ปรับจำนวนเมนูได้ (ค่าเริ่มต้น 5 เมนู)

---

## 🌍 ระบบหลายภาษา (Internationalization)

```dart
// เปลี่ยนภาษา
void _changeLanguage(String languageCode) async {
  if (languageCode == 'th') {
    Get.updateLocale(const Locale('th', 'TH'));
  } else {
    Get.updateLocale(const Locale('en', 'US'));
  }
  
  // เคลียร์ cache การแปล
  TranslationService.to.clearCache();
  
  // แปลเมนูที่มีอยู่ใหม่
  await mealController.refreshTranslations();
}
```

**การแปลภาษา:**
- ไทย ↔ อังกฤษ
- แปลชื่อเมนู, วัตถุดิบ, วิธีทำ
- แปลหมวดหมู่และประเทศต้นกำเนิด
- Cache การแปลเพื่อประสิทธิภาพ

---

## 🎨 UI Design System

### สีหลัก (Color Palette)
```dart
final Color primaryColor = Color(0xFFFF6B6B);    // สีแดงอ่อน
final Color accentColor = Color(0xFFFF8E53);     // สีส้ม
final Color backgroundColor = Color(0xFFFFD93D);  // สีเหลือง
final Color textPrimary = Color(0xFF1A202C);     // สีข้อความหลัก
final Color textSecondary = Color(0xFF64748B);   // สีข้อความรอง
```

### Background Pattern
```dart
Widget _buildBackgroundPattern() {
  return Opacity(
    opacity: 0.08,
    child: Stack(
      children: [
        for (int row = 0; row < 15; row++)
          for (int col = 0; col < 6; col++)
            _buildIconPattern(row, col), // ไอคอนอาหารกระจาย
      ],
    ),
  );
}
```

- **Gradient Background**: แดง → ส้ม → เหลือง
- **Food Icon Pattern**: ไอคอนอาหารกระจายเป็น pattern
- **Card Design**: มุมโค้ง, เงา, พื้นหลังขาว
- **Responsive**: ปรับขนาดตามหน้าจอ

---



## 🌟 API Integration

### TheMealDB API Endpoints
```dart
class ApiService {
  static const _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  
  // ค้นหาจากวัตถุดิบ
  '/filter.php?i={ingredient}'
  
  // ค้นหาจากชื่อเมนู
  '/search.php?s={name}'
  
  // ดึงรายละเอียดเมนู
  '/lookup.php?i={id}'
  
  // สุ่มเมนู
  '/random.php'
  
  // กรองตามหมวดหมู่
  '/filter.php?c={category}'
  
  // กรองตามประเทศ
  '/filter.php?a={area}'
}
```

---

## ✅ ความสามารถเด่น

| Feature | Description |
|--------|-------------|
| 🔍 **Smart Search** | ค้นหาจากวัตถุดิบหลายตัว + ตัดที่แพ้ |
| 🌐 **Auto Translation** | แปลภาษาไทยอัตโนมัติพร้อม Cache |
| 🎲 **Random Discovery** | สุ่มเมนูแบบไม่ซ้ำกัน |
| 🚫 **Allergy Filter** | กรองวัตถุดิบที่แพ้อย่างละเอียด |
| 📱 **Beautiful UI** | Gradient design พร้อม pattern |
| 📖 **Step-by-Step** | แยกขั้นตอนการทำแบบชัดเจน |
| 🎥 **Video Support** | ลิงค์วิดีโอ YouTube (ถ้ามี) |
| 🌏 **Multi-Language** | รองรับไทย-อังกฤษ |

---

## 🧪 ตัวอย่าง Recipe Data

```json
{
  "idMeal": "52772",
  "strMeal": "Pad Thai",
  "strMealThumb": "https://www.themealdb.com/images/media/meals/1548772327.jpg",
  "strInstructions": "Put the rice noodles in a large bowl...",
  "ingredients": ["Rice noodles", "Prawns", "Eggs", "Bean sprouts"],
  "measurements": ["200g", "100g", "2", "50g"],
  "strCategory": "Chicken",
  "strArea": "Thai",
  "strYoutube": "https://www.youtube.com/watch?v=CHTIu_LP9bk"
}
```

---

## ▶️ วิธีเริ่มต้นใช้งาน

```bash
# Clone repository
git clone https://github.com/your-repo/easycook-app.git

# Install dependencies
flutter pub get

# Run app
flutter run
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.7.2                     # State management และ routing
  http: ^1.1.0                    # HTTP requests สำหรับ API calls
  intl: ^0.20.2                   # จัดการรูปแบบวันที่/เวลา
  shared_preferences: ^2.2.2      # เก็บข้อมูลผู้ใช้แบบ local
  cached_network_image: ^3.3.0    # Cache รูปภาพจาก network
  flutter_staggered_grid_view: ^0.7.0  # Grid layout แบบยืดหยุ่น
```

---

## 🚀 Future Enhancements

- [ ] **Offline Mode**: บันทึกสูตรโปรดไว้ดูออฟไลน์
- [ ] **Nutrition Info**: แสดงข้อมูลโภชนาการ
- [ ] **Shopping List**: สร้างรายการซื้อจากสูตรอาหาร
- [ ] **User Reviews**: รีวิวและให้คะแนนสูตรอาหาร
- [ ] **Social Sharing**: แชร์สูตรโปรดไปยัง Social Media
- [ ] **Voice Search**: ค้นหาด้วยเสียง
- [ ] **Dark Mode**: โหมดมืดสำหรับใช้งานกลางคืน

---

## 👨‍💻 Developer Notes

- **Performance**: ใช้ `Obx()` สำหรับ reactive UI updates
- **Error Handling**: แสดง SnackBar เมื่อเกิดข้อผิดพลาด
- **Loading States**: แสดง CircularProgressIndicator ระหว่างโหลด
- **Translation Cache**: ลด API calls ด้วยการ cache การแปล
- **Responsive Design**: ปรับขนาดตามหน้าจออัตโนมัติ

---

<div align="center">

**EasyCook** - *Discover, Cook, Enjoy* 🍳✨

Made with ❤️ using Flutter

</div>