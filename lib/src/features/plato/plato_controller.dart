import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../common/domain/entities/menu_item.dart';
import '../../common/domain/entities/restaurant.dart';
import '../home/home_controller.dart';
import '../profile/profile_controller.dart';
import 'plato_state.dart';

class PlatoController extends Notifier<PlatoState> {
  static const _geminiKey = 'AIzaSyD1yglTqyHsHdUv0ZUiRujz10oBOfZVY7A';
  static const _geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_geminiKey';

  @override
  PlatoState build() {
    final profile = ref.read(profileProvider);
    return PlatoState(
      selectedDietaryPrefs: Set.from(profile.selectedDietaryPrefs),
      selectedAllergens: Set.from(profile.selectedAllergens),
    );
  }

  void togglePref(String pref) {
    final updated = Set<String>.from(state.selectedDietaryPrefs);
    updated.contains(pref) ? updated.remove(pref) : updated.add(pref);
    state = state.copyWith(selectedDietaryPrefs: updated, status: PlatoStatus.idle);
  }

  void toggleAllergen(String allergen) {
    final updated = Set<String>.from(state.selectedAllergens);
    updated.contains(allergen) ? updated.remove(allergen) : updated.add(allergen);
    state = state.copyWith(selectedAllergens: updated, status: PlatoStatus.idle);
  }

  void updateFreeText(String text) {
    state = state.copyWith(freeText: text);
  }

  void reset() {
    state = state.copyWith(status: PlatoStatus.idle, recommendations: []);
  }

  Future<void> findMyMeal() async {
    state = state.copyWith(status: PlatoStatus.loading);

    try {
      final menuRaw = await rootBundle.loadString('assets/jsons/menu_items.json');
      final restRaw = await rootBundle.loadString('assets/jsons/restaurants.json');

      final allItems = (jsonDecode(menuRaw) as List)
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final restaurants = (jsonDecode(restRaw) as List)
          .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .toList();

      final selectedLocationId = ref.read(homeProvider).selectedLocationId;
      final locationRestaurantIds = restaurants
          .where((r) =>
              selectedLocationId.isEmpty || r.locationId == selectedLocationId)
          .map((r) => r.id)
          .toSet();
      final restaurantMap = {for (final r in restaurants) r.id: r};

      final filtered = allItems.where((item) {
        if (!locationRestaurantIds.contains(item.restaurantId)) { return false; }
        if (state.selectedAllergens.isNotEmpty &&
            item.allergens.any(state.selectedAllergens.contains)) { return false; }
        for (final pref in state.selectedDietaryPrefs) {
          switch (pref) {
            case 'Vegan 🌱':
              if (!item.dietaryTags.contains('Vegan')) { return false; }
            case 'Vegetarian':
              if (!item.dietaryTags.contains('Vegan') &&
                  !item.dietaryTags.contains('Vegetarian')) { return false; }
            case 'Gluten-Free':
              if (!item.dietaryTags.contains('Gluten-Free')) { return false; }
            case 'Halal':
              if (!item.dietaryTags.contains('Halal')) { return false; }
            case 'No Spicy':
              if (item.dietaryTags.contains('Spicy')) { return false; }
            case 'Dairy-Free':
              if (item.allergens.contains('Dairy')) { return false; }
          }
        }
        return true;
      }).toList();

      if (filtered.isEmpty) {
        state = state.copyWith(status: PlatoStatus.empty, recommendations: []);
        return;
      }

      final query = state.freeText.trim();
      List<PlatoRecommendation> picks;

      if (query.isEmpty) {
        picks = filtered.map((item) {
          final r = restaurantMap[item.restaurantId]!;
          return PlatoRecommendation(
            item: item,
            restaurantId: item.restaurantId,
            restaurantName: r.name,
            restaurantEmoji: r.emoji,
            isRestaurantClosed: r.status.toLowerCase() == 'closed',
          );
        }).toList();
      } else {
        picks = await _askGemini(filtered, restaurantMap, query);
      }

      state = state.copyWith(
        status: picks.isEmpty ? PlatoStatus.empty : PlatoStatus.results,
        recommendations: picks,
      );
    } catch (e) {
      state = state.copyWith(
        status: PlatoStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<List<PlatoRecommendation>> _askGemini(
    List<MenuItem> items,
    Map<String, Restaurant> restaurantMap,
    String query,
  ) async {
    final itemsPayload = items.map((item) {
      final r = restaurantMap[item.restaurantId];
      return {
        'id': item.id,
        'name': item.name,
        'restaurant': r?.name ?? '',
        'price': item.price,
        'calories': item.calories.toInt(),
        'protein_g': item.protein.toInt(),
        'carbs_g': item.carbs.toInt(),
        'fat_g': item.fat.toInt(),
        'category': item.category,
        'tags': item.dietaryTags,
      };
    }).toList();

    final prompt = '''
You are a food advisor helping a user find the perfect meal.

The user is looking for: "$query"

The following menu items are pre-filtered to match the user's dietary preferences and allergen restrictions:
${jsonEncode(itemsPayload)}

From the list above, select the 3–5 items that best match what the user described. Consider cravings, mood, flavor preferences, and nutritional goals mentioned in their request.

Rules:
- Only pick items from the provided list
- Return ONLY a valid JSON array — no markdown, no code blocks, no explanation before or after
- Format exactly: [{"id":"<item_id>","reason":"<one concise sentence explaining why this fits the user's request>"}]
''';

    final response = await http.post(
      Uri.parse(_geminiEndpoint),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 1024,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error ${response.statusCode}: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final text = (((body['candidates'] as List).first)['content']['parts']
        as List)
        .first['text'] as String;

    return _parseResponse(text, items, restaurantMap);
  }

  List<PlatoRecommendation> _parseResponse(
    String text,
    List<MenuItem> items,
    Map<String, Restaurant> restaurantMap,
  ) {
    final start = text.indexOf('[');
    final end = text.lastIndexOf(']');
    if (start == -1 || end == -1) { return []; }

    final parsed = jsonDecode(text.substring(start, end + 1)) as List;
    final itemMap = {for (final i in items) i.id: i};
    final picks = <PlatoRecommendation>[];

    for (final pick in parsed) {
      final id = pick['id'] as String?;
      final reason = pick['reason'] as String?;
      if (id == null) { continue; }
      final item = itemMap[id];
      if (item == null) { continue; }
      final restaurant = restaurantMap[item.restaurantId];
      if (restaurant == null) { continue; }
      picks.add(PlatoRecommendation(
        item: item,
        restaurantId: item.restaurantId,
        restaurantName: restaurant.name,
        restaurantEmoji: restaurant.emoji,
        isRestaurantClosed: restaurant.status.toLowerCase() == 'closed',
        reason: reason,
      ));
    }

    return picks;
  }
}

final platoProvider =
    NotifierProvider<PlatoController, PlatoState>(PlatoController.new);
