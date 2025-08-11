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
  
  // เพิ่มตัวแปรสำหรับ search mode
  String _searchMode = 'ingredients'; // 'ingredients' หรือ 'name'
  
  // เพิ่มตัวแปรสำหรับ filter
  String selectedCategory = 'All';
  String selectedArea = 'All';
  bool _isFilterExpanded = false;

  // รายการหมวดหมู่และประเทศ
  final List<String> categories = [
    'All', 'Beef', 'Chicken', 'Dessert', 'Lamb', 'Miscellaneous', 
    'Pasta', 'Pork', 'Seafood', 'Side', 'Starter', 'Vegan', 'Vegetarian'
  ];
  
  final List<String> areas = [
    'All', 'American', 'British', 'Canadian', 'Chinese', 'Croatian', 
    'Dutch', 'Egyptian', 'French', 'Greek', 'Indian', 'Irish', 'Italian', 
    'Jamaican', 'Japanese', 'Kenyan', 'Malaysian', 'Mexican', 'Moroccan', 
    'Polish', 'Portuguese', 'Russian', 'Spanish', 'Thai', 'Tunisian', 
    'Turkish', 'Vietnamese'
  ];

  @override
  void dispose() {
    searchController.dispose();
    allergyController.dispose();
    super.dispose();
  }

  void _searchMeals() {
    final inputText = searchController.text.trim();
    if (inputText.isEmpty) {
      _showSnackBar(
        _searchMode == 'ingredients' 
          ? 'กรุณากรอกส่วนผสม' 
          : 'กรุณากรอกชื่อเมนู', 
        isError: true
      );
      return;
    }
    
    if (_searchMode == 'ingredients') {
      final ingredients = inputText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      mealController.searchMeals(ingredients, allergyFilters.toList());
    } else {
      // ค้นหาด้วยชื่อเมนู
      mealController.searchMealsByName(inputText, allergyFilters.toList());
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
      excludeIngredients: allergyFilters.toList()
    );
  }

  void _clearAllAllergies() {
    if (allergyFilters.isNotEmpty) {
      allergyFilters.clear();
      _showSnackBar('ลบอาหารแพ้ทั้งหมดแล้ว');
    }
  }

  // ฟังก์ชันสำหรับ filter
  void _applyFilters() {
    mealController.searchMealsByFilter(
      category: selectedCategory != 'All' ? selectedCategory : null,
      area: selectedArea != 'All' ? selectedArea : null,
      excludeIngredients: allergyFilters.toList(),
    );
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
        // แก้ไขปุ่มกลับให้ทำงานได้
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // ใช้ Navigator.pop() แทน Get.back()
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              mealController.clearMeals();
              searchController.clear();
              // รีเซ็ต filter
              setState(() {
                selectedCategory = 'All';
                selectedArea = 'All';
                _isFilterExpanded = false;
                _searchMode = 'ingredients';
              });
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
                // Search Mode Toggle
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _searchMode = 'ingredients';
                                      searchController.clear();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _searchMode == 'ingredients' 
                                        ? Colors.orange[600] 
                                        : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(
                                        left: Radius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.set_meal,
                                          size: 18,
                                          color: _searchMode == 'ingredients' 
                                            ? Colors.white 
                                            : Colors.orange[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'ส่วนผสม',
                                          style: TextStyle(
                                            color: _searchMode == 'ingredients' 
                                              ? Colors.white 
                                              : Colors.orange[600],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _searchMode = 'name';
                                      searchController.clear();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _searchMode == 'name' 
                                        ? Colors.orange[600] 
                                        : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(
                                        right: Radius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.restaurant,
                                          size: 18,
                                          color: _searchMode == 'name' 
                                            ? Colors.white 
                                            : Colors.orange[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'ชื่อเมนู',
                                          style: TextStyle(
                                            color: _searchMode == 'name' 
                                              ? Colors.white 
                                              : Colors.orange[600],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ช่องค้นหา
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: _searchMode == 'ingredients' 
                        ? 'ค้นหาด้วยส่วนผสม' 
                        : 'ค้นหาด้วยชื่อเมนู',
                      hintText: _searchMode == 'ingredients' 
                        ? 'เช่น chicken, onion, garlic' 
                        : 'เช่น Pad Thai, Tom Yum, Fried Rice',
                      prefixIcon: Icon(
                        _searchMode == 'ingredients' ? Icons.set_meal : Icons.restaurant,
                        color: Colors.orange[600],
                      ),
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
                  ),
                ),

                const SizedBox(height: 16),

                // Quick Action Buttons - เพิ่มปุ่ม Filter
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _loadRandomMeals,
                          icon: const Icon(Icons.shuffle, size: 20),
                          label: const Text('สุ่ม 5 เมนู'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isFilterExpanded = !_isFilterExpanded;
                            });
                          },
                          icon: Icon(
                            _isFilterExpanded ? Icons.expand_less : Icons.filter_list,
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
                      const SizedBox(width: 8),
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

                // Filter Section (Expandable) - ส่วนใหม่
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
                                'ตัวกรองเมนูอาหาร',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // หมวดหมู่
                              const Text(
                                'หมวดหมู่อาหาร',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedCategory,
                                  isExpanded: true,
                                  underline: Container(),
                                  items: categories.map((String category) {
                                    return DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(category),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedCategory = newValue!;
                                    });
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // ประเทศ
                              const Text(
                                'ประเทศ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedArea,
                                  isExpanded: true,
                                  underline: Container(),
                                  items: areas.map((String area) {
                                    return DropdownMenuItem<String>(
                                      value: area,
                                      child: Text(area),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedArea = newValue!;
                                    });
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // ปุ่มใช้ตัวกรอง
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _applyFilters,
                                      icon: const Icon(Icons.search),
                                      label: const Text('ใช้ตัวกรอง'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[600],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedCategory = 'All';
                                        selectedArea = 'All';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[300],
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('รีเซ็ต'),
                                  ),
                                ],
                              ),
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
                      Text(
                        _searchMode == 'ingredients' 
                          ? 'กำลังค้นหาจากส่วนผสม...' 
                          : 'กำลังค้นหาจากชื่อเมนู...',
                        style: const TextStyle(
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
                      Text(
                        _searchMode == 'ingredients' 
                          ? 'ลองค้นหาด้วยส่วนผสมอื่น\nหรือกดปุ่ม "สุ่ม 5 เมนู"'
                          : 'ลองค้นหาด้วยชื่อเมนูอื่น\nหรือกดปุ่ม "สุ่ม 5 เมนู"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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