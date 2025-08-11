import 'package:easycook/screens/detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/meal_controller.dart';
import '../widgets/meal_card.dart';
import '../models/meal.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final MealController mealController = Get.put(MealController());
  final TextEditingController searchController = TextEditingController();
  final RxList<String> allergyFilters = <String>[].obs; // รายการแพ้ที่กรอง

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เมนูอาหาร')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'ค้นหาจากส่วนประกอบ เช่น เนื้อไก่',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    mealController.searchMeals(
                      searchController.text.trim(),
                      excludeIngredients: allergyFilters,
                    );
                  },
                ),
              ),
            ),
            Obx(() => Wrap(
                  spacing: 8,
                  children: allergyFilters
                      .map((e) => Chip(
                            label: Text(e),
                            onDeleted: () {
                              allergyFilters.remove(e);
                            },
                          ))
                      .toList(),
                )),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'เพิ่มส่วนผสมแพ้ (เช่น ถั่ว)',
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) allergyFilters.add(val.trim());
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    mealController.loadRandomMeal(excludeIngredients: allergyFilters);
                  },
                )
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (mealController.loading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (mealController.meals.isEmpty) {
                  return const Center(child: Text('ไม่พบเมนูอาหาร'));
                }
                return ListView.builder(
                  itemCount: mealController.meals.length,
                  itemBuilder: (context, index) {
                    final Meal meal = mealController.meals[index];
                    return MealCard(
                      meal: meal,
                      onTap: () {
                        Get.to(DetailPage(), arguments: meal);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
