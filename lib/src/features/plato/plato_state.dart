import '../../common/domain/entities/menu_item.dart';

enum PlatoStatus { idle, loading, results, empty, error }

class PlatoRecommendation {
  const PlatoRecommendation({
    required this.item,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantEmoji,
    required this.isRestaurantClosed,
    this.reason,
  });

  final MenuItem item;
  final String restaurantId;
  final String restaurantName;
  final String restaurantEmoji;
  final bool isRestaurantClosed;
  final String? reason;
}

class PlatoState {
  const PlatoState({
    this.status = PlatoStatus.idle,
    this.selectedDietaryPrefs = const {},
    this.selectedAllergens = const {},
    this.freeText = '',
    this.recommendations = const [],
    this.errorMessage,
  });

  final PlatoStatus status;
  final Set<String> selectedDietaryPrefs;
  final Set<String> selectedAllergens;
  final String freeText;
  final List<PlatoRecommendation> recommendations;
  final String? errorMessage;

  PlatoState copyWith({
    PlatoStatus? status,
    Set<String>? selectedDietaryPrefs,
    Set<String>? selectedAllergens,
    String? freeText,
    List<PlatoRecommendation>? recommendations,
    String? errorMessage,
  }) {
    return PlatoState(
      status: status ?? this.status,
      selectedDietaryPrefs: selectedDietaryPrefs ?? this.selectedDietaryPrefs,
      selectedAllergens: selectedAllergens ?? this.selectedAllergens,
      freeText: freeText ?? this.freeText,
      recommendations: recommendations ?? this.recommendations,
      errorMessage: errorMessage,
    );
  }
}
