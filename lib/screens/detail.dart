import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/meal.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Meal meal = Get.arguments as Meal;

    return Scaffold(
      appBar: AppBar(
        title: Text(meal.strMeal),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพอาหาร
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(meal.strMealThumb),
            ),
            const SizedBox(height: 16),

            // ส่วนผสม
            const Text(
              "ingredient",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...meal.ingredients.map((ing) => Text("• $ing")).toList(),

            const SizedBox(height: 16),

            // วิธีทำ
            const Text(
              "method",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(meal.strInstructions),
          ],
        ),
      ),
    );
  }
}
