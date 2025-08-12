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

  // Improved Colors and Theme
  final Color primaryColor = Color(0xFF1565C0);
  final Color accentColor = Color(0xFF42A5F5);
  final Color backgroundColor = Color(0xFFF8FAFC);
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
      // ถ้าเป็นภาษาไทย ให้แปลเป็นอังกฤษก่อนค้นหา
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
      // ค้นหาด้วยชื่อเมนู
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
                  color: _searchMode == 'ingredients'
                      ? primaryColor
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
                          : primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ingredients'.tr,
                      style: TextStyle(
                        color: _searchMode == 'ingredients'
                            ? Colors.white
                            : primaryColor,
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
                  color: _searchMode == 'name'
                      ? primaryColor
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
                          : primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'meal_name'.tr,
                      style: TextStyle(
                        color: _searchMode == 'name'
                            ? Colors.white
                            : primaryColor,
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
              ? 'search_by_ingredients'.tr
              : 'search_by_name'.tr,
          labelStyle: TextStyle(color: textSecondary, fontSize: 14),
          hintText: _searchMode == 'ingredients'
              ? 'search_ingredients_hint'.tr
              : 'search_name_hint'.tr,
          hintStyle: TextStyle(
            color: textSecondary.withOpacity(0.7),
            fontSize: 13,
          ),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
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
              label: 'random'.tr,
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
              label: 'filter'.tr,
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
              icon: _isAllergyExpanded
                  ? Icons.expand_less
                  : Icons.warning_amber,
              label: 'allergies'.tr,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
                        'meal_filter'.tr,
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
                    'food_category'.tr,
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

                  const SizedBox(height: 16),

                  Text(
                    'country'.tr,
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

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _applyFilters,
                          icon: const Icon(Icons.search, size: 16),
                          label: Text('apply_filter'.tr),
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
                          child: Text('reset'.tr),
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
                          Icon(
                            Icons.warning_amber,
                            color: Colors.red[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'allergy_management'.tr,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: const Size(0, 0),
                          ),
                          child: Text(
                            'remove_all'.tr,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Obx(
                    () => allergyFilters.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.restaurant_menu,
                                    size: 32,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'no_allergies'.tr,
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
                                .map(
                                  (allergy) => Chip(
                                    label: Text(
                                      allergy,
                                      style: TextStyle(
                                        color: Colors.red[800],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                    deleteIcon: const Icon(
                                      Icons.close,
                                      size: 16,
                                    ),
                                    onDeleted: () =>
                                        allergyFilters.remove(allergy),
                                    backgroundColor: Colors.red[50],
                                    deleteIconColor: Colors.red[600],
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(color: Colors.red[200]!),
                                    ),
                                  ),
                                )
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
                            labelText: 'add_allergy'.tr,
                            labelStyle: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                            hintText: 'allergy_hint'.tr,
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: textSecondary.withOpacity(0.7),
                            ),
                            prefixIcon: Icon(
                              Icons.add_circle_outline,
                              color: Colors.red[600],
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.red[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.red[600]!,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
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
                            horizontal: 16,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('add'.tr, style: TextStyle(fontSize: 14)),
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'meal_menu'.tr,
          style: const TextStyle(
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
          onPressed: () {
            if (Get.key.currentState?.canPop() ?? false) {
              Get.back(); // กลับหน้าก่อนหน้า
            } else {
              Get.offAllNamed('/brk'); // ถ้าไม่มีหน้าก่อนหน้า ไปหน้า brk แทน
            }
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, size: 22),
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
            tooltip: 'clear_all'.tr,
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
                  colors: [Colors.white.withOpacity(0.1), Colors.transparent],
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
                            ? 'loading_ingredients'.tr
                            : 'loading_name'.tr,
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
