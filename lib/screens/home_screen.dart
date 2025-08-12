// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easycook/screens/detail.dart';
import '../controllers/meal_controller.dart';
import '../widgets/meal_card.dart';
import '../models/meal.dart';
import '../services/translation_service.dart';
import '../screens/brk.dart';

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

  // Updated Colors matching BKK Theme
  final Color primaryColor = Color(0xFFFF6B6B); // สีแดงอ่อนจาก BKK
  final Color accentColor = Color(0xFFFF8E53); // สีส้มจาก BKK
  final Color backgroundColor = Color(0xFFFFD93D); // สีเหลืองจาก BKK
  final Color cardColor = Colors.white;
  final Color textPrimary = Color(0xFF1A202C);
  final Color textSecondary = Color(0xFF64748B);

  // Categories and Areas with translation keys
  final List<Map<String, String>> categories = [
    {'key': 'all', 'value': 'All'},
    {'key': 'beef', 'value': 'Beef'},
    {'key': 'chicken', 'value': 'Chicken'},
    {'key': 'dessert', 'value': 'Dessert'},
    {'key': 'lamb', 'value': 'Lamb'},
    {'key': 'miscellaneous', 'value': 'Miscellaneous'},
    {'key': 'pasta', 'value': 'Pasta'},
    {'key': 'pork', 'value': 'Pork'},
    {'key': 'seafood', 'value': 'Seafood'},
    {'key': 'side', 'value': 'Side'},
    {'key': 'starter', 'value': 'Starter'},
    {'key': 'vegan', 'value': 'Vegan'},
    {'key': 'vegetarian', 'value': 'Vegetarian'},
  ];

  final List<Map<String, String>> areas = [
    {'key': 'all', 'value': 'All'},
    {'key': 'american', 'value': 'American'},
    {'key': 'british', 'value': 'British'},
    {'key': 'canadian', 'value': 'Canadian'},
    {'key': 'chinese', 'value': 'Chinese'},
    {'key': 'french', 'value': 'French'},
    {'key': 'indian', 'value': 'Indian'},
    {'key': 'italian', 'value': 'Italian'},
    {'key': 'japanese', 'value': 'Japanese'},
    {'key': 'mexican', 'value': 'Mexican'},
    {'key': 'thai', 'value': 'Thai'},
    {'key': 'turkish', 'value': 'Turkish'},
    {'key': 'vietnamese', 'value': 'Vietnamese'},
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
            ? 'please_enter_ingredients'.tr
            : 'please_enter_meal_name'.tr,
        isError: true,
      );
      return;
    }

    if (_searchMode == 'ingredients') {
      String searchText = inputText;
      if (Get.locale?.languageCode == 'th') {
        searchText = TranslationService.to.translateThaiToEnglish(inputText);
      }

      final ingredients = searchText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      mealController.searchMeals(ingredients, allergyFilters.toList());
    } else {
      String searchText = inputText;
      if (Get.locale?.languageCode == 'th') {
        searchText = TranslationService.to.translateThaiToEnglish(inputText);
      }
      mealController.searchMealsByName(searchText, allergyFilters.toList());
    }
  }

  void _addAllergy() {
    final allergy = allergyController.text.trim();
    if (allergy.isEmpty) {
      _showSnackBar('please_enter_allergy'.tr, isError: true);
      return;
    }
    if (allergyFilters.contains(allergy)) {
      _showSnackBar('allergy_already_exists'.tr, isError: true);
      return;
    }

    allergyFilters.add(allergy);
    allergyController.clear();
    _showSnackBar('allergy_added'.trParams({'allergy': allergy}));
  }

  void _loadRandomMeals() {
    mealController.loadMultipleRandomMeals(
      count: 5,
      excludeIngredients: allergyFilters.toList(),
    );
  }

  void _clearAllAllergies() {
    if (allergyFilters.isNotEmpty) {
      allergyFilters.clear();
      _showSnackBar('all_allergies_removed'.tr);
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Background Pattern Widget matching BKK style
  Widget _buildBackgroundPattern() {
    return Opacity(
      opacity: 0.08,
      child: Stack(
        children: [
          for (int row = 0; row < 15; row++)
            for (int col = 0; col < 6; col++) _buildIconPattern(row, col),
        ],
      ),
    );
  }

  Widget _buildIconPattern(int row, int col) {
    const double horizontalSpacing = 70.0;
    const double verticalSpacing = 65.0;
    const double startX = 25.0;
    const double startY = 40.0;

    final List<IconData> foodIcons = [
      Icons.restaurant,
      Icons.local_pizza,
      Icons.rice_bowl,
      Icons.coffee,
      Icons.cake,
      Icons.lunch_dining,
      Icons.fastfood,
      Icons.icecream,
      Icons.local_dining,
      Icons.breakfast_dining,
      Icons.dinner_dining,
      Icons.bakery_dining,
      Icons.set_meal,
      Icons.ramen_dining,
      Icons.egg_alt,
      Icons.local_bar,
    ];

    double x = startX + (col * horizontalSpacing);
    double y = startY + (row * verticalSpacing);

    if (row % 2 == 1) {
      x += horizontalSpacing / 2;
    }

    int iconIndex = (row * 6 + col) % foodIcons.length;
    double iconSize = (row + col) % 3 == 0
        ? 32
        : (row + col) % 3 == 1
        ? 28
        : 30;

    return Positioned(
      left: x,
      top: y,
      child: Transform.rotate(
        angle: (row + col) % 4 * 0.1,
        child: Container(
          width: iconSize + 8,
          height: iconSize + 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            foodIcons[iconIndex],
            size: iconSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ปรับปุ่ม toggle แบบเรียบง่าย
  Widget _buildSearchModeToggle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 1),
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
                height: 36,
                decoration: BoxDecoration(
                  color: _searchMode == 'ingredients'
                      ? primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    'ingredients'.tr,
                    style: TextStyle(
                      color: _searchMode == 'ingredients'
                          ? Colors.white
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
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
                height: 36,
                decoration: BoxDecoration(
                  color: _searchMode == 'name'
                      ? primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    'meal_name'.tr,
                    style: TextStyle(
                      color: _searchMode == 'name'
                          ? Colors.white
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ปรับแถบค้นหาให้เรียบง่าย
  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: _searchMode == 'ingredients'
              ? 'search_ingredients_hint'.tr
              : 'search_name_hint'.tr,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 18),
          suffixIcon: Container(
            margin: const EdgeInsets.all(6),
            child: ElevatedButton(
              onPressed: _searchMeals,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.search, size: 16),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onSubmitted: (value) => _searchMeals(),
      ),
    );
  }

  // ปรับปุ่มให้เป็นแบบ compact
  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          _buildCompactButton(
            onPressed: _loadRandomMeals,
            icon: Icons.shuffle,
            label: 'random'.tr,
            color: Colors.green[500]!,
          ),
          const SizedBox(width: 8),
          _buildCompactButton(
            onPressed: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            icon: Icons.tune,
            label: 'filter'.tr,
            color: Colors.blue[500]!,
          ),
          const SizedBox(width: 8),
          _buildCompactButton(
            onPressed: () {
              setState(() {
                _isAllergyExpanded = !_isAllergyExpanded;
              });
            },
            icon: Icons.block,
            label: 'allergies'.tr,
            color: Colors.orange[500]!,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: 32,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: color.withOpacity(0.3), width: 1),
            ),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13),
              const SizedBox(width: 3),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ซ่อน search results header เพื่อลดความรก
  Widget _buildResultsSection() {
    return Expanded(
      child: Obx(() {
        if (mealController.loading.value) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'loading'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (mealController.meals.isEmpty) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 40, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'no_meals_found'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'try_different_search'.tr,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadRandomMeals,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[500],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'random_meals'.tr,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          itemCount: mealController.meals.length,
          itemBuilder: (context, index) {
            final meal = mealController.meals[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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
    );
  }

  // ปรับส่วน filter ให้เรียบง่าย
  Widget _buildFilterSection() {
    if (!_isFilterExpanded) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'meal_filter'.tr,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'food_category'.tr,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: TextStyle(fontSize: 13, color: textPrimary),
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['value'],
                            child: Text(category['key']!.tr),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'country'.tr,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: selectedArea,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: TextStyle(fontSize: 13, color: textPrimary),
                        items: areas.map((area) {
                          return DropdownMenuItem<String>(
                            value: area['value'],
                            child: Text(area['key']!.tr),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedArea = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    minimumSize: const Size(0, 34),
                  ),
                  child: Text(
                    'apply_filter'.tr,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = 'All';
                      selectedArea = 'All';
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                    minimumSize: const Size(0, 34),
                  ),
                  child: Text('reset'.tr, style: const TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ปรับส่วนแพ้อาหารให้เรียบง่าย
  Widget _buildAllergySection() {
    if (!_isAllergyExpanded) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'allergy_management'.tr,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              if (allergyFilters.isNotEmpty)
                TextButton(
                  onPressed: _clearAllAllergies,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[500],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    minimumSize: const Size(0, 0),
                  ),
                  child: Text(
                    'remove_all'.tr,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          Obx(
            () => allergyFilters.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'no_allergies'.tr,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: allergyFilters
                        .map(
                          (allergy) => Chip(
                            label: Text(
                              allergy,
                              style: const TextStyle(fontSize: 11),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => allergyFilters.remove(allergy),
                            backgroundColor: Colors.red[50],
                            deleteIconColor: Colors.red[500],
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  child: TextField(
                    controller: allergyController,
                    decoration: InputDecoration(
                      hintText: 'allergy_hint'.tr,
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onSubmitted: (value) => _addAllergy(),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: _addAllergy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[500],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  minimumSize: const Size(50, 36),
                ),
                child: Text('add'.tr, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.restaurant_menu, color: primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            'search_results'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const Spacer(),
          Obx(
            () => mealController.meals.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'menus_count'.trParams({
                        'count': '${mealController.meals.length}',
                      }),
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6B6B), // สีแดงอ่อน
              Color(0xFFFF8E53), // สีส้ม
              Color(0xFFFFD93D), // สีเหลือง
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(child: _buildBackgroundPattern()),

            // Main Content
            Column(
              children: [
                // Custom App Bar
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // Back Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () {
                              if (Get.key.currentState?.canPop() ?? false) {
                                Get.back();
                              } else {
                                Get.offAllNamed('/brk');
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        // App Title
                        Expanded(
                          child: Text(
                            'meal_menu'.tr,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Language Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.language,
                              color: Colors.white,
                              size: 22,
                            ),
                            onSelected: (String languageCode) {
                              if (languageCode == 'th') {
                                Get.updateLocale(const Locale('th', 'TH'));
                              } else {
                                Get.updateLocale(const Locale('en', 'US'));
                              }
                              if (Get.isRegistered<TranslationService>()) {
                                TranslationService.to.clearCache();
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem<String>(
                                value: 'en',
                                child: Row(
                                  children: [
                                    Icon(Icons.language, size: 16),
                                    SizedBox(width: 8),
                                    Text('english'.tr),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'th',
                                child: Row(
                                  children: [
                                    Icon(Icons.language, size: 16),
                                    SizedBox(width: 8),
                                    Text('thai'.tr),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Refresh Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
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
                            tooltip: 'clear_all'.tr,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Header Section with gradient overlay
                Container(
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
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryColor,
                                ),
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _searchMode == 'ingredients'
                                    ? 'loading_ingredients'.tr
                                    : 'loading_name'.tr,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (mealController.meals.isEmpty) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(32),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                                'no_meals_found'.tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchMode == 'ingredients'
                                    ? 'try_different_search'.tr
                                    : 'try_different_name'.tr,
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
                                label: Text('random_meals'.tr),
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
                        ),
                      );
                    }

                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: mealController.meals.length,
                        itemBuilder: (context, index) {
                          final meal = mealController.meals[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: MealCard(
                              meal: meal,
                              onTap: () {
                                Get.to(() => DetailPage(), arguments: meal);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
