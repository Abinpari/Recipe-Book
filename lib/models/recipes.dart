// models.dart
class RecipeStep {
  final int? id;
  final String ingredients;
  final String time;
  final String instruction;

  RecipeStep({
    this.id,
    required this.ingredients,
    required this.time,
    required this.instruction,
  });

  Map<String, dynamic> toMap(int recipeId) {
    return {
      "recipeId": recipeId,
      "ingredients": ingredients,
      "time": time,
      "instruction": instruction,
    };
  }

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      id: map["id"] as int?,
      ingredients: map["ingredients"] as String,
      time: map["time"] as String,
      instruction: map["instruction"] as String,
    );
  }
}

class Recipe {
  final int? id;
  final String title;
  final String imageUrl;
  final List<RecipeStep> steps;

  Recipe({
    this.id,
    required this.title,
    required this.imageUrl,
    required this.steps,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "imageUrl": imageUrl,
    };
  }
}