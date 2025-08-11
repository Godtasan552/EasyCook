class MealDetail {
  final String idMeal;
  final String strMeal;
  final String? strMealAlternate;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String strMealThumb;
  final String? strTags;
  final String? strYoutube;
  final List<String?> strIngredients;
  final List<String?> strMeasures;
  final String? strSource;
  final String? strImageSource;
  final String? strCreativeCommonsConfirmed;
  final String? dateModified;

  MealDetail({
    required this.idMeal,
    required this.strMeal,
    this.strMealAlternate,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    this.strTags,
    this.strYoutube,
    required this.strIngredients,
    required this.strMeasures,
    this.strSource,
    this.strImageSource,
    this.strCreativeCommonsConfirmed,
    this.dateModified,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    List<String?> ing = List.generate(20, (i) {
      final v = json['strIngredient${i + 1}'];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    });
    List<String?> measures = List.generate(20, (i) {
      final v = json['strMeasure${i + 1}'];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    });

    return MealDetail(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealAlternate: json['strMealAlternate'],
      strCategory: json['strCategory'] ?? '',
      strArea: json['strArea'] ?? '',
      strInstructions: json['strInstructions'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strTags: json['strTags'],
      strYoutube: json['strYoutube'],
      strIngredients: ing,
      strMeasures: measures,
      strSource: json['strSource'],
      strImageSource: json['strImageSource'],
      strCreativeCommonsConfirmed: json['strCreativeCommonsConfirmed'],
      dateModified: json['dateModified'],
    );
  }

  Map<String, dynamic> toJson() {
    final m = {
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strMealAlternate': strMealAlternate,
      'strCategory': strCategory,
      'strArea': strArea,
      'strInstructions': strInstructions,
      'strMealThumb': strMealThumb,
      'strTags': strTags,
      'strYoutube': strYoutube,
      'strSource': strSource,
      'strImageSource': strImageSource,
      'strCreativeCommonsConfirmed': strCreativeCommonsConfirmed,
      'dateModified': dateModified,
    };
    for (var i = 0; i < strIngredients.length; i++) {
      m['strIngredient${i + 1}'] = strIngredients[i];
      m['strMeasure${i + 1}'] = strMeasures[i];
    }
    return m;
  }
}
