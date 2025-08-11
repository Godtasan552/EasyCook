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
  
  String _searchMode = 'ingredients';
  String selectedCategory = 'All';
  String selectedArea = 'All';
  bool _isFilterExpanded = false;

  // Improved Colors and Theme
  final Color primaryColor = Color(0xFF1565C0);
  final Color accentColor = Color(0xFF42A5F5);
  final Color backgroundColor = Color(0xFFF8FAFC);
  final Color cardColor = Colors.white;
  final Color textPrimary = Color(0xFF1A202C);
  final Color textSecondary = Color(0xFF64748B);

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
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSearchModeToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                  color: _searchMode == 'ingredients' ? primaryColor : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.set_meal,
                      size: 18,
                      color: _searchMode == 'ingredients' ? Colors.white : primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ส่วนผสม',
                      style: TextStyle(
                        color: _searchMode == 'ingredients' ? Colors.white : primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
                  color: _searchMode == 'name' ? primaryColor : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 18,
                      color: _searchMode == 'name' ? Colors.white : primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ชื่อเมนู',
                      style: TextStyle(
                        color: _searchMode == 'name' ? Colors.white : primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: _searchMode == 'ingredients' 
            ? 'ค้นหาด้วยส่วนผสม' 
            : 'ค้นหาด้วยชื่อเมนู',
          labelStyle: TextStyle(color: textSecondary, fontSize: 14),
          hintText: _searchMode == 'ingredients' 
            ? 'เช่น chicken, onion, garlic' 
            : 'เช่น Pad Thai, Tom Yum',
          hintStyle: TextStyle(color: textSecondary.withOpacity(0.7), fontSize: 13),
          prefixIcon: Icon(
            _searchMode == 'ingredients' ? Icons.set_meal : Icons.restaurant,
            color: primaryColor,
            size: 20,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(4),
            width: 40,
            height: 40,
            child: ElevatedButton(
              onPressed: _searchMeals,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.search, size: 18),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onSubmitted: (value) => _searchMeals(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              onPressed: _loadRandomMeals,
              icon: Icons.shuffle,
              label: 'สุ่ม',
              color: Colors.green[600]!,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              onPressed: () {
                setState(() {
                  _isFilterExpanded = !_isFilterExpanded;
                });
              },
              icon: _isFilterExpanded ? Icons.expand_less : Icons.filter_list,
              label: 'ตัวกรอง',
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              onPressed: () {
                setState(() {
                  _isAllergyExpanded = !_isAllergyExpanded;
                });
              },
              icon: _isAllergyExpanded ? Icons.expand_less : Icons.warning_amber,
              label: 'อาหารแพ้',
              color: Colors.red[600]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: _isFilterExpanded
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.filter_list, color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'ตัวกรองเมนูอาหาร',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Text(
                  'หมวดหมู่อาหาร',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    underline: const SizedBox(),
                    style: TextStyle(fontSize: 14, color: textPrimary),
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
                
                Text(
                  'ประเทศ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedArea,
                    isExpanded: true,
                    underline: const SizedBox(),
                    style: TextStyle(fontSize: 14, color: textPrimary),
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
                
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _applyFilters,
                        icon: const Icon(Icons.search, size: 16),
                        label: const Text('ใช้ตัวกรอง'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedCategory = 'All';
                            selectedArea = 'All';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          foregroundColor: textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        child: const Text('รีเซ็ต'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : const SizedBox.shrink(),
    );
  }

  Widget _buildAllergySection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: _isAllergyExpanded
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
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
                    Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.red[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'จัดการอาหารที่แพ้',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (allergyFilters.isNotEmpty)
                      TextButton(
                        onPressed: _clearAllAllergies,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: const Size(0, 0),
                        ),
                        child: const Text('ลบทั้งหมด', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Obx(() => allergyFilters.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 32,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'ไม่มีอาหารที่แพ้',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: allergyFilters
                        .map((allergy) => Chip(
                          label: Text(
                            allergy,
                            style: TextStyle(
                              color: Colors.red[800],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => allergyFilters.remove(allergy),
                          backgroundColor: Colors.red[50],
                          deleteIconColor: Colors.red[600],
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.red[200]!),
                          ),
                        ))
                        .toList(),
                    ),
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: allergyController,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'เพิ่มอาหารที่แพ้',
                          labelStyle: TextStyle(fontSize: 13, color: textSecondary),
                          hintText: 'เช่น peanut, milk, egg',
                          hintStyle: TextStyle(fontSize: 12, color: textSecondary.withOpacity(0.7)),
                          prefixIcon: Icon(Icons.add_circle_outline, 
                            color: Colors.red[600], size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red[600]!, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                          horizontal: 16,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.add, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          )
        : const SizedBox.shrink(),
    );
  }

  Widget _buildResultsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.restaurant_menu, color: primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            'ผลการค้นหา',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const Spacer(),
          Obx(() => mealController.meals.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${mealController.meals.length} เมนู',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            : const SizedBox.shrink()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'เมนูอาหาร',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: () {
              mealController.clearMeals();
              searchController.clear();
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
          // Header Section
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildSearchModeToggle(),
                  const SizedBox(height: 12),
                  _buildSearchField(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          _buildActionButtons(),
          
          // Expandable Sections
          _buildFilterSection(),
          _buildAllergySection(),
          
          // Results Header
          _buildResultsHeader(),
          
          // Results List
          Expanded(
            child: Obx(() {
              if (mealController.loading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        strokeWidth: 2,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchMode == 'ingredients' 
                          ? 'กำลังค้นหาจากส่วนผสม...' 
                          : 'กำลังค้นหาจากชื่อเมนู...',
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
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
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'ไม่พบเมนูอาหาร',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchMode == 'ingredients' 
                          ? 'ลองค้นหาด้วยส่วนผสมอื่น หรือกดปุ่ม "สุ่ม"'
                          : 'ลองค้นหาด้วยชื่อเมนูอื่น หรือกดปุ่ม "สุ่ม"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _loadRandomMeals,
                        icon: const Icon(Icons.shuffle, size: 18),
                        label: const Text('สุ่มเมนู'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: mealController.meals.length,
                itemBuilder: (context, index) {
                  final meal = mealController.meals[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: MealCard(
                      meal: meal,
                      onTap: () {
                        Get.to(() => DetailPage(), arguments: meal);
                      },
                    ),
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