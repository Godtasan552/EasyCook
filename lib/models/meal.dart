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

  Meal({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
    required this.strInstructions,
    required this.ingredients,
    this.strCategory,
    this.strArea,
    this.strYoutube,
    this.measurements = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    List<String> parsedIngredients = [];
    List<String> parsedMeasurements = [];
    
    // Parse ingredients และ measurements
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measurement = json['strMeasure$i'];
      
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        parsedIngredients.add(ingredient.toString().trim());
        
        if (measurement != null && measurement.toString().trim().isNotEmpty) {
          parsedMeasurements.add(measurement.toString().trim());
        } else {
          parsedMeasurements.add('');
        }
      }
    }
    
    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strInstructions: json['strInstructions'] ?? '',
      ingredients: parsedIngredients,
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strYoutube: json['strYoutube'],
      measurements: parsedMeasurements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strMealThumb': strMealThumb,
      'strInstructions': strInstructions,
      'ingredients': ingredients,
      'strCategory': strCategory,
      'strArea': strArea,
      'strYoutube': strYoutube,
      'measurements': measurements,
    };
  }

  /// Get formatted ingredients with measurements
  List<String> get formattedIngredients {
    List<String> formatted = [];
    for (int i = 0; i < ingredients.length; i++) {
      final ingredient = ingredients[i];
      final measurement = i < measurements.length && measurements[i].isNotEmpty 
          ? measurements[i] 
          : '';
      
      if (measurement.isNotEmpty) {
        formatted.add('$measurement $ingredient');
      } else {
        formatted.add(ingredient);
      }
    }
    return formatted;
  }

  @override
  String toString() {
    return 'Meal{id: $idMeal, name: $strMeal, category: $strCategory, area: $strArea}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meal &&
          runtimeType == other.runtimeType &&
          idMeal == other.idMeal;

  @override
  int get hashCode => idMeal.hashCode;
}