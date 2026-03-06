class ProfileState {
  const ProfileState({
    this.selectedDietaryPrefs = const {},
    this.allergiesText = '',
  });

  final Set<String> selectedDietaryPrefs;
  final String allergiesText;

  ProfileState copyWith({
    Set<String>? selectedDietaryPrefs,
    String? allergiesText,
  }) {
    return ProfileState(
      selectedDietaryPrefs: selectedDietaryPrefs ?? this.selectedDietaryPrefs,
      allergiesText: allergiesText ?? this.allergiesText,
    );
  }
}
