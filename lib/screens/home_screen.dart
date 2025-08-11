import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easycook/screens/detail.dart';
import '../controllers/meal_controller.dart';
import '../widgets/meal_card.dart';
import '../models/meal.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MealController mealController = Get.put(MealController());
  final TextEditingController searchController = TextEditingController();
  final RxList<String> allergyFilters = <String>[].obs;
  final TextEditingController allergyController = TextEditingController();
  bool _isAllergyExpanded = false;
  bool _isFilterExpanded = false;
  
  // ตัวเลือก filter
  final RxString selectedSearchType = 'ingredients'.obs;
  final RxString selectedCategory = 'all'.obs;
  
  final Map<String, String> searchTypes = {
    'ingredients': 'ส่วนผสม',
    'name': 'ชื่อเมนู',
  };
  
  final Map<String, String> categories = {
    'all': 'ทั้งหมด',
    'Beef': 'เนื้อ',
    'Chicken': 'ไก่',
    'Dessert': 'ของหวาน',
    'Lamb': 'เนื้อแกะ',
    'Miscellaneous': 'เบ็ดเตล็ด',
    'Pasta': 'พาสต้า',
    'Pork': 'หมู',
    'Seafood': 'อาหารทะเล',
    'Side': 'เครื่องเคียง',
    'Starter': 'อาหารเรียกน้ำย่อย',
    'Vegan': 'เจ',
    'Vegetarian': 'มังสวิรัติ',
    'Breakfast': 'อาหารเช้า',
  };

  @override
  void dispose() {
    searchController.dispose();
    allergyController.dispose();
    super.dispose();
  }

  void _searchMeals() {
    final inputText = searchController.text.trim();
    if (inputText.isEmpty) {
      _showSnackBar('กรุณากรอกคำค้นหา', isError: true);
      return;
    }
    
    if (selectedSearchType.value == 'ingredients') {
      // ค้นหาด้วยส่วนผสม
      final ingredients = inputText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      
      mealController.searchMealsByIngredients(
        ingredients, 
        allergyFilters.toList(),
        category: selectedCategory.value == 'all' ? null : selectedCategory.value
      );
    } else {
      // ค้นหาด้วยชื่อเมนู
      mealController.searchMealsByName(
        inputText,
        allergyFilters.toList(),
        category: selectedCategory.value == 'all' ? null : selectedCategory.value
      );
    }
  }

  void _addAllergy() {
    final allergy = allergyController.text.trim();
    if (allergy.isEmpty) {
      _showSnackBar('กรุณากรอกอาหารที่แพ้', isError: true);
      return;
    }
    if (allergyFilters.contains(allergy)) {
      _showSnackBar('มีอาหารนี้อยู่แล้ว', isError: true);
      return;
    }
    
    allergyFilters.add(allergy);
    allergyController.clear();
    _showSnackBar('เพิ่มอาหารแพ้แล้ว: $allergy');
  }

  void _loadRandomMeals() {
    mealController.loadMultipleRandomMeals(
      count: 5,
      excludeIngredients: allergyFilters.toList(),
      category: selectedCategory.value == 'all' ? null : selectedCategory.value
    );
  }

  void _clearAllAllergies() {
    if (allergyFilters.isNotEmpty) {
      allergyFilters.clear();
      _showSnackBar('ลบอาหารแพ้ทั้งหมดแล้ว');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'เมนูอาหาร',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            // กลับไปหน้าแรก
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          tooltip: 'หน้าแรก',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              mealController.clearMeals();
              searchController.clear();
              selectedSearchType.value = 'ingredients';
              selectedCategory.value = 'all';
            },
            tooltip: 'ล้างทั้งหมด',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section with Search
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.orange[600]!.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              children: [
                // ช่องค้นหา
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Obx(() => TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: selectedSearchType.value == 'ingredients' 
                          ? 'ค้นหาด้วยส่วนผสม' 
                          : 'ค้นหาด้วยชื่อเมนู',
                      hintText: selectedSearchType.value == 'ingredients'
                          ? 'เช่น chicken, onion, garlic'
                          : 'เช่น Pad Thai, Tom Yum',
                      prefixIcon: Icon(Icons.search, color: Colors.orange[600]),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[600],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: _searchMeals,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    onSubmitted: (value) => _searchMeals(),
                  )),
                ),

                // Quick Action Buttons (Filter และ Allergy)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isFilterExpanded = !_isFilterExpanded;
                            });
                          },
                          icon: Icon(
                            _isFilterExpanded ? Icons.expand_less : Icons.tune,
                            size: 20,
                          ),
                          label: const Text('ตัวกรอง'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isAllergyExpanded = !_isAllergyExpanded;
                            });
                          },
                          icon: Icon(
                            _isAllergyExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 20,
                          ),
                          label: const Text('อาหารแพ้'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter Section (Expandable)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isFilterExpanded ? null : 0,
                  child: _isFilterExpanded
                      ? Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ตัวกรองการค้นหา',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // ประเภทการค้นหา
                              const Text(
                                'ค้นหาด้วย:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(() => Wrap(
                                spacing: 8,
                                children: searchTypes.entries
                                    .map((entry) => ChoiceChip(
                                          label: Text(entry.value),
                                          selected: selectedSearchType.value == entry.key,
                                          onSelected: (selected) {
                                            if (selected) {
                                              selectedSearchType.value = entry.key;
                                            }
                                          },
                                          selectedColor: Colors.blue[100],
                                          labelStyle: TextStyle(
                                            color: selectedSearchType.value == entry.key
                                                ? Colors.blue[800]
                                                : Colors.grey[600],
                                          ),
                                        ))
                                    .toList(),
                              )),
                              
                              const SizedBox(height: 16),
                              
                              // หมวดหมู่อาหาร
                              const Text(
                                'หมวดหมู่:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(() => Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: categories.entries
                                    .map((entry) => ChoiceChip(
                                          label: Text(entry.value),
                                          selected: selectedCategory.value == entry.key,
                                          onSelected: (selected) {
                                            if (selected) {
                                              selectedCategory.value = entry.key;
                                            }
                                          },
                                          selectedColor: Colors.orange[100],
                                          labelStyle: TextStyle(
                                            color: selectedCategory.value == entry.key
                                                ? Colors.orange[800]
                                                : Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ))
                                    .toList(),
                              )),
                            ],
                          ),
                        )
                      : null,
                ),

                // Allergy Section (Expandable)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isAllergyExpanded ? null : 0,
                  child: _isAllergyExpanded
                      ? Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'จัดการอาหารที่แพ้',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (allergyFilters.isNotEmpty)
                                    TextButton.icon(
                                      onPressed: _clearAllAllergies,
                                      icon: const Icon(Icons.clear_all, size: 16),
                                      label: const Text('ลบทั้งหมด'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red[600],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // แสดง chips ของอาหารแพ้
                              Obx(() => allergyFilters.isEmpty
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      child: const Center(
                                        child: Text(
                                          '🍽️ ไม่มีอาหารที่แพ้',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: allergyFilters
                                          .map((allergy) => Chip(
                                                label: Text(allergy),
                                                deleteIcon: const Icon(Icons.close, size: 18),
                                                onDeleted: () => allergyFilters.remove(allergy),
                                                backgroundColor: Colors.red[50],
                                                labelStyle: TextStyle(color: Colors.red[800]),
                                                deleteIconColor: Colors.red[600],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                  side: BorderSide(color: Colors.red[200]!),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // ช่องเพิ่มอาหารแพ้
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: allergyController,
                                      decoration: InputDecoration(
                                        labelText: 'เพิ่มอาหารที่แพ้',
                                        hintText: 'เช่น peanut, milk, egg',
                                        prefixIcon: Icon(Icons.add_circle_outline, 
                                          color: Colors.red[600]),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.red[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.red[600]!, width: 2),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                      onSubmitted: (value) => _addAllergy(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: _addAllergy,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[600],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
                
                // ปุ่มสุ่มเมนู พร้อมแสดงประเภทที่เลือก
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  width: double.infinity,
                  child: Obx(() => ElevatedButton.icon(
                    onPressed: _loadRandomMeals,
                    icon: const Icon(Icons.shuffle, size: 20),
                    label: Text(
                      selectedCategory.value == 'all' 
                          ? 'สุ่ม 5 เมนู (ทั้งหมด)' 
                          : 'สุ่ม 5 เมนู (${categories[selectedCategory.value]})'
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )),
                ),
                
                const SizedBox(height: 8),
              ],
            ),
          ),
          
          // Results Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'ผลการค้นหา',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Obx(() => mealController.meals.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${mealController.meals.length} เมนู',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          
          // รายการผลลัพธ์
          Expanded(
            child: Obx(() {
              if (mealController.loading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'กำลังค้นหาเมนูอาหาร...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              if (mealController.meals.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'ไม่พบเมนูอาหาร',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ลองปรับเปลี่ยนคำค้นหาหรือตัวกรอง\nหรือกดปุ่ม "สุ่ม 5 เมนู"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadRandomMeals,
                        icon: const Icon(Icons.shuffle),
                        label: const Text('สุ่ม 5 เมนู'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                itemCount: mealController.meals.length,
                itemBuilder: (context, index) {
                  final meal = mealController.meals[index];
                  return MealCard(
                    meal: meal,
                    onTap: () {
                      Get.to(() => DetailPage(), arguments: meal);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}