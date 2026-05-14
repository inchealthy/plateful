class AddOnOption {
  const AddOnOption({
    required this.id,
    required this.name,
    required this.extraCost,
    this.calories = 0,
    this.carbs = 0,
    this.protein = 0,
    this.fat = 0,
  });

  final String id;
  final String name;
  final double extraCost;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;

  factory AddOnOption.fromJson(Map<String, dynamic> json) {
    return AddOnOption(
      id: json['id'] as String,
      name: json['name'] as String,
      extraCost: (json['extraCost'] as num).toDouble(),
      calories: (json['calories'] as num? ?? 0).toDouble(),
      carbs: (json['carbs'] as num? ?? 0).toDouble(),
      protein: (json['protein'] as num? ?? 0).toDouble(),
      fat: (json['fat'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'extraCost': extraCost,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
    };
  }
}

class AddOnGroup {
  const AddOnGroup({
    required this.id,
    required this.restaurantId,
    required this.applicableItemIds,
    required this.name,
    required this.required,
    required this.maxSelections,
    required this.options,
  });

  final String id;
  final String restaurantId;
  final List<String> applicableItemIds;
  final String name;
  final bool required;
  final int maxSelections;
  final List<AddOnOption> options;

  factory AddOnGroup.fromJson(Map<String, dynamic> json) {
    return AddOnGroup(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      applicableItemIds:
          List<String>.from(json['applicableItemIds'] as List),
      name: json['name'] as String,
      required: json['required'] as bool,
      maxSelections: json['maxSelections'] as int,
      options: (json['options'] as List<dynamic>)
          .map((e) => AddOnOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
