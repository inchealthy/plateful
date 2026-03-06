class MenuItem {
  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    required this.price,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.allergens,
    required this.dietaryTags,
  });

  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String emoji;
  final String category;
  final double price;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final List<String> allergens;
  final List<String> dietaryTags;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      emoji: json['emoji'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      allergens: List<String>.from(json['allergens'] as List),
      dietaryTags: List<String>.from(json['dietaryTags'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'emoji': emoji,
      'category': category,
      'price': price,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'allergens': allergens,
      'dietaryTags': dietaryTags,
    };
  }
}
