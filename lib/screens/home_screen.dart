// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easycook/screens/detail.dart';
import '../controllers/meal_controller.dart';
import '../widgets/meal_card.dart';
import '../services/translation_service.dart';
import '../screens/brk.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MealController mealController = Get.put(MealController());
  final TextEditingController searchController = TextEditingController();
  final TextEditingController allergyController = TextEditingController();
  final RxList<String> allergyFilters = <String>[].obs;
  String _searchMode = 'ingredients';
  String selectedCategory = 'All';
  String selectedArea = 'All';

  // Colors
  final Color primaryColor = Color(0xFFFF6B6B);
  final Color accentColor = Color(0xFFFF8E53);
  final Color backgroundColor = Color(0xFFFFD93D);
  final Color textPrimary = Color(0xFF1A202C);
  final Color textSecondary = Color(0xFF64748B);

  // Categories and Areas
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

  // Common allergies for grid selection
  final List<String> commonAllergies = [
    'peanuts', 'tree_nuts', 'milk', 'eggs', 'fish',
    'shellfish', 'soy', 'wheat', 'sesame', 'gluten'
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
        _searchMode == 'ingredients' ? 'please_enter_ingredients'.tr : 'please_enter_meal_name'.tr,
        isError: true,
      );
      return;
    }
    if (_searchMode == 'ingredients') {
      String searchText = inputText;
      if (Get.locale?.languageCode == 'th') {
        searchText = TranslationService.to.translateThaiToEnglish(inputText);
      }
      final ingredients = searchText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      mealController.searchMeals(ingredients, allergyFilters.toList());
    } else {
      String searchText = inputText;
      if (Get.locale?.languageCode == 'th') {
        searchText = TranslationService.to.translateThaiToEnglish(inputText);
      }
      mealController.searchMealsByName(searchText, allergyFilters.toList());
    }
  }

  void _addAllergy(String allergy) {
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
    mealController.loadMultipleRandomMeals(count: 5, excludeIngredients: allergyFilters.toList());
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
        content: Text(message, style: const TextStyle(fontSize: 12)),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Opacity(
      opacity: 0.08,
      child: Stack(
        children: [
          for (int row = 0; row < 15; row++)
            for (int col = 0; col < 6; col++)
              _buildIconPattern(row, col),
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
      Icons.restaurant, Icons.local_pizza, Icons.rice_bowl, Icons.coffee,
      Icons.cake, Icons.lunch_dining, Icons.fastfood, Icons.icecream,
    ];
    double x = startX + (col * horizontalSpacing);
    double y = startY + (row * verticalSpacing);
    if (row % 2 == 1) x += horizontalSpacing / 2;
    int iconIndex = (row * 6 + col) % foodIcons.length;
    double iconSize = (row + col) % 3 == 0 ? 28 : (row + col) % 3 == 1 ? 24 : 26;

    return Positioned(
      left: x,
      top: y,
      child: Transform.rotate(
        angle: (row + col) % 4 * 0.1,
        child: Icon(foodIcons[iconIndex], size: iconSize, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      height: 48, // Increased height from 40 to 48
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Slightly larger border radius
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          // Search Mode Toggle
          Container(
            width: 90, // Slightly wider for better touch area
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButton<String>(
              value: _searchMode,
              isExpanded: true,
              underline: const SizedBox(),
              style: const TextStyle(fontSize: 14, color: Colors.black), // Increased font size
              items: [
                DropdownMenuItem(value: 'ingredients', child: Text('ingredients'.tr, style: TextStyle(fontSize: 14))),
                DropdownMenuItem(value: 'name', child: Text('meal_name'.tr, style: TextStyle(fontSize: 14))),
              ],
              onChanged: (value) {
                setState(() {
                  _searchMode = value!;
                  searchController.clear();
                });
              },
            ),
          ),
          // Search Field
          Expanded(
            child: TextField(
              controller: searchController,
              style: const TextStyle(fontSize: 15), // Increased font size
              decoration: InputDecoration(
                hintText: _searchMode == 'ingredients' ? 'search_ingredients_hint'.tr : 'search_name_hint'.tr,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14), // Increased hint font size
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14), // Adjusted padding
              ),
              onSubmitted: (value) => _searchMeals(),
            ),
          ),
          // Search Button
          IconButton(
            icon: Icon(Icons.search, size: 20, color: primaryColor), // Increased icon size
            onPressed: _searchMeals,
          ),
          // Options Button
          IconButton(
            icon: Icon(Icons.tune, size: 20, color: primaryColor), // Increased icon size
            onPressed: () => _showOptionsBottomSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // Random Button
          Expanded(
            child: ElevatedButton(
              onPressed: _loadRandomMeals,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[500],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shuffle, size: 14),
                  SizedBox(width: 4),
                  Text('random'.tr, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          // Filters Counter or Add Filters
          Expanded(
            child: Obx(() => ElevatedButton(
              onPressed: () => _showOptionsBottomSheet(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: primaryColor.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.filter_alt, size: 14),
                  SizedBox(width: 4),
                  Text(
                    allergyFilters.isEmpty && selectedCategory == 'All' && selectedArea == 'All'
                        ? 'add_filters'.tr
                        : 'filters_count'.trParams({'count': '${allergyFilters.length + (selectedCategory != 'All' ? 1 : 0) + (selectedArea != 'All' ? 1 : 0)}'}),
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyFilters() {
    return Obx(() => allergyFilters.isEmpty
        ? SizedBox.shrink()
        : Container(
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allergyFilters.length,
              itemBuilder: (context, index) {
                final allergy = allergyFilters[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Chip(
                    label: Text(allergy, style: TextStyle(fontSize: 11)),
                    deleteIcon: Icon(Icons.close, size: 14),
                    onDeleted: () => allergyFilters.remove(allergy),
                    backgroundColor: Colors.red[50],
                    deleteIconColor: Colors.red[500],
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              },
            ),
          ));
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text('advanced_options'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
              SizedBox(height: 12),
              // Category Filter
              Text('food_category'.tr, style: TextStyle(fontSize: 13, color: textSecondary)),
              SizedBox(height: 8),
              DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                style: TextStyle(fontSize: 13, color: textPrimary),
                items: categories.map((category) => DropdownMenuItem<String>(
                  value: category['value'],
                  child: Text(category['key']!.tr),
                )).toList(),
                onChanged: (value) => setState(() => selectedCategory = value!),
              ),
              SizedBox(height: 12),
              // Area Filter
              Text('country'.tr, style: TextStyle(fontSize: 13, color: textSecondary)),
              SizedBox(height: 8),
              DropdownButton<String>(
                value: selectedArea,
                isExpanded: true,
                style: TextStyle(fontSize: 13, color: textPrimary),
                items: areas.map((area) => DropdownMenuItem<String>(
                  value: area['value'],
                  child: Text(area['key']!.tr),
                )).toList(),
                onChanged: (value) => setState(() => selectedArea = value!),
              ),
              SizedBox(height: 12),
              // Allergy Management
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('allergy_management'.tr, style: TextStyle(fontSize: 13, color: textSecondary)),
                  if (allergyFilters.isNotEmpty)
                    TextButton(
                      onPressed: _clearAllAllergies,
                      child: Text('remove_all'.tr, style: TextStyle(fontSize: 12, color: Colors.red[500])),
                    ),
                ],
              ),
              SizedBox(height: 8),
              // Common Allergies Grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: commonAllergies.map((allergy) => FilterChip(
                  label: Text(allergy.tr, style: TextStyle(fontSize: 12)),
                  selected: allergyFilters.contains(allergy),
                  onSelected: (selected) {
                    if (selected) {
                      _addAllergy(allergy);
                    } else {
                      allergyFilters.remove(allergy);
                    }
                  },
                  selectedColor: Colors.red[100],
                  checkmarkColor: Colors.red[500],
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
              SizedBox(height: 12),
              // Custom Allergy Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: allergyController,
                      style: TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'allergy_hint'.tr,
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onSubmitted: (value) => _addAllergy(value),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _addAllergy(allergyController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[500],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: Size(60, 36),
                    ),
                    child: Text('add'.tr, style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Apply and Reset Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _applyFilters();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: Size(0, 40),
                      ),
                      child: Text('apply_filter'.tr, style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = 'All';
                          selectedArea = 'All';
                          allergyFilters.clear();
                        });
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textSecondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: Colors.grey[300]!),
                        minimumSize: Size(0, 40),
                      ),
                      child: Text('reset'.tr, style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFD93D)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: _buildBackgroundPattern()),
            Column(
              children: [
                // App Bar
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          onPressed: () => Get.key.currentState?.canPop() ?? false ? Get.back() : Get.offAllNamed('/brk'),
                        ),
                        Expanded(
                          child: Text(
                            'meal_menu'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black26)],
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.language, color: Colors.white, size: 20),
                          onSelected: (languageCode) {
                            Get.updateLocale(Locale(languageCode == 'th' ? 'th' : 'en', languageCode == 'th' ? 'TH' : 'US'));
                            if (Get.isRegistered<TranslationService>()) {
                              TranslationService.to.clearCache();
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'en', child: Text('english'.tr, style: TextStyle(fontSize: 12))),
                            PopupMenuItem(value: 'th', child: Text('thai'.tr, style: TextStyle(fontSize: 12))),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh, color: Colors.white, size: 20),
                          onPressed: () {
                            mealController.clearMeals();
                            searchController.clear();
                            setState(() {
                              selectedCategory = 'All';
                              selectedArea = 'All';
                              _searchMode = 'ingredients';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Search and Actions
                _buildSearchBar(),
                _buildQuickActions(),
                _buildAllergyFilters(),
                // Results
                Expanded(
                  child: Obx(() {
                    if (mealController.loading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          strokeWidth: 2,
                        ),
                      );
                    }
                    if (mealController.meals.isEmpty) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 2))],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off, size: 36, color: Colors.grey[400]),
                              SizedBox(height: 8),
                              Text('no_meals_found'.tr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary)),
                              SizedBox(height: 4),
                              Text(
                                _searchMode == 'ingredients' ? 'try_different_search'.tr : 'try_different_name'.tr,
                                style: TextStyle(fontSize: 12, color: textSecondary),
                              ),
                              SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _loadRandomMeals,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[500],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: Text('random_meals'.tr, style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                      itemCount: mealController.meals.length,
                      itemBuilder: (context, index) {
                        final meal = mealController.meals[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: Offset(0, 2))],
                          ),
                          child: MealCard(
                            meal: meal,
                            onTap: () => Get.to(() => DetailPage(), arguments: meal),
                          ),
                        );
                      },
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