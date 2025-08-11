import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/meal.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  // Function to parse instructions into steps
  List<String> _parseInstructions(String instructions) {
    // Split by common step indicators
    List<String> steps = [];
    
    // Try to split by numbered steps first (1., 2., etc.)
    List<String> numberedSteps = instructions.split(RegExp(r'\d+\.'));
    if (numberedSteps.length > 2) {
      // Remove first empty element and clean up
      numberedSteps.removeAt(0);
      return numberedSteps
          .map((step) => step.trim())
          .where((step) => step.isNotEmpty)
          .toList();
    }
    
    // Try to split by sentences ending with periods
    List<String> sentences = instructions
        .split(RegExp(r'\.(?=\s[A-Z]|\s*$)'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    
    if (sentences.length > 1) {
      return sentences.map((s) => s.endsWith('.') ? s : '$s.').toList();
    }
    
    // If no clear separation, try to split by line breaks
    List<String> lines = instructions
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    
    if (lines.length > 1) {
      return lines;
    }
    
    // If still no separation, split by length (every ~100-150 characters at sentence boundaries)
    if (instructions.length > 150) {
      List<String> chunks = [];
      List<String> words = instructions.split(' ');
      String currentChunk = '';
      
      for (String word in words) {
        if (currentChunk.length + word.length > 120 && currentChunk.isNotEmpty) {
          chunks.add(currentChunk.trim());
          currentChunk = word;
        } else {
          currentChunk += (currentChunk.isEmpty ? '' : ' ') + word;
        }
      }
      
      if (currentChunk.isNotEmpty) {
        chunks.add(currentChunk.trim());
      }
      
      return chunks;
    }
    
    // Default: return as single step
    return [instructions];
  }

  @override
  Widget build(BuildContext context) {
    final Meal meal = Get.arguments as Meal;

    // Improved Colors and Theme
    final Color primaryColor = Color(0xFF1565C0);
    final Color backgroundColor = Color(0xFFF8FAFC);
    final Color cardColor = Colors.white;
    final Color textPrimary = Color(0xFF1A202C);
    final Color textSecondary = Color(0xFF64748B);
    final Color accentColor = Color(0xFF42A5F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          meal.strMeal,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image Section
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Image.network(
                      meal.strMealThumb,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 220,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Meal Info Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (meal.strCategory != null)
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.category,
                        label: meal.strCategory!,
                        color: Colors.blue[600]!,
                      ),
                    ),
                  if (meal.strCategory != null && meal.strArea != null)
                    const SizedBox(width: 12),
                  if (meal.strArea != null)
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.public,
                        label: meal.strArea!,
                        color: Colors.green[600]!,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Ingredients Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    title: "ส่วนผสม",
                    subtitle: "${meal.ingredients.length} รายการ",
                    icon: Icons.shopping_cart,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Container(
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
                      children: List.generate(meal.ingredients.length, (index) {
                        final ingredient = meal.ingredients[index];
                        final measurement = index < meal.measurements.length 
                            ? meal.measurements[index] 
                            : '';
                        final isLast = index == meal.ingredients.length - 1;
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: !isLast
                                ? Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Bullet point
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Ingredient name (Left side)
                              Expanded(
                                flex: 3,
                                child: Text(
                                  ingredient,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.3,
                                    color: textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // Measurement (Right side)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: measurement.isNotEmpty 
                                        ? primaryColor.withOpacity(0.1)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: measurement.isNotEmpty 
                                          ? primaryColor.withOpacity(0.3)
                                          : Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    measurement.isNotEmpty ? measurement : 'ตามต้องการ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: measurement.isNotEmpty 
                                          ? primaryColor
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Instructions Section with Steps
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    title: "วิธีทำ",
                    subtitle: "ขั้นตอนการทำอาหาร",
                    icon: Icons.restaurant_menu,
                    color: Colors.orange[600]!,
                  ),
                  const SizedBox(height: 12),
                  _buildStepsSection(meal.strInstructions, primaryColor, textPrimary, cardColor),
                ],
              ),
            ),

            // YouTube Link (if available)
            if (meal.strYoutube != null && meal.strYoutube!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red[600]!, Colors.red[500]!],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // Handle YouTube link opening
                        // You can use url_launcher package here
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'ดูวิดีโอสอนทำ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsSection(String instructions, Color primaryColor, Color textPrimary, Color cardColor) {
    final steps = _parseInstructions(instructions);
    
    return Container(
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
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;
          final stepNumber = index + 1;
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: !isLast
                  ? Border(
                      bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step number badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$stepNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Step content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ขั้นตอนที่ $stepNumber',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A202C),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}