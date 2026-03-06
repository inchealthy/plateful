import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:plateful/src/common/domain/entities/order.dart';
import 'package:plateful/src/utils/dummy_data.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(HiveTestHelper.init);
  setUp(HiveTestHelper.clearAll);

  test('seedIfNeeded seeds exactly 3 completed orders once', () async {
    final ordersBox = Hive.box<String>('orders');
    final metaBox = Hive.box<bool>('meta');

    await DummyData.seedIfNeeded(ordersBox, metaBox);

    final payload = ordersBox.get('orders_list');
    expect(payload, isNotNull);

    final decoded = (jsonDecode(payload!) as List<dynamic>)
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();

    expect(decoded.length, 3);
    expect(decoded.every((order) => order.status == 'completed'), isTrue);
    expect(decoded.every((order) => order.isRated == false), isTrue);
    expect(metaBox.get('is_seeded'), isTrue);
  });

  test('seedIfNeeded does not reseed when meta is already seeded', () async {
    final ordersBox = Hive.box<String>('orders');
    final metaBox = Hive.box<bool>('meta');

    await DummyData.seedIfNeeded(ordersBox, metaBox);
    await ordersBox.put('orders_list', '[]');

    await DummyData.seedIfNeeded(ordersBox, metaBox);

    expect(ordersBox.get('orders_list'), '[]');
  });
}
