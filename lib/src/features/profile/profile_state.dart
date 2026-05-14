class ProfileState {
  const ProfileState({
    this.selectedDietaryPrefs = const {},
    this.selectedAllergens = const {},
  });

  final Set<String> selectedDietaryPrefs;
  final Set<String> selectedAllergens;

  ProfileState copyWith({
    Set<String>? selectedDietaryPrefs,
    Set<String>? selectedAllergens,
  }) {
    return ProfileState(
      selectedDietaryPrefs: selectedDietaryPrefs ?? this.selectedDietaryPrefs,
      selectedAllergens: selectedAllergens ?? this.selectedAllergens,
    );
  }
}
