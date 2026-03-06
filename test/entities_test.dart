import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plateful/src/common/domain/entities/menu_item.dart';
import 'package:plateful/src/common/domain/entities/restaurant.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Restaurant json parse roundtrip', () async {
    final raw = await rootBundle.loadString('assets/jsons/restaurants.json');
    final decoded = jsonDecode(raw) as List<dynamic>;

    final restaurants = decoded
        .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
        .toList();

    expect(restaurants.length, 6);
    expect(restaurants.first.id, 'r1');
    expect(restaurants.first.toJson()['name'], 'Main Campus Cafeteria');
  });

  test('MenuItem json parse roundtrip', () async {
    final raw = await rootBundle.loadString('assets/jsons/menu_items.json');
    final decoded = jsonDecode(raw) as List<dynamic>;

    final items = decoded
        .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
        .toList();

    expect(items.length, 29);
    expect(items.first.restaurantId, 'r1');
    expect(items.first.toJson()['name'], 'Canyon Classic Burger');
  });
}
