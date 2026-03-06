import 'dart:io';

import 'package:hive/hive.dart';

class HiveTestHelper {
  static Directory? _tempDir;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) {
      if (!Hive.isBoxOpen('cart')) {
        await Hive.openBox<String>('cart');
      }
      if (!Hive.isBoxOpen('orders')) {
        await Hive.openBox<String>('orders');
      }
      if (!Hive.isBoxOpen('feedbacks')) {
        await Hive.openBox<String>('feedbacks');
      }
      if (!Hive.isBoxOpen('profile')) {
        await Hive.openBox<String>('profile');
      }
      if (!Hive.isBoxOpen('meta')) {
        await Hive.openBox<bool>('meta');
      }
      return;
    }

    _tempDir = await Directory.systemTemp.createTemp('plateful_hive_test_');
    Hive.init(_tempDir!.path);
    await Hive.openBox<String>('cart');
    await Hive.openBox<String>('orders');
    await Hive.openBox<String>('feedbacks');
    await Hive.openBox<String>('profile');
    await Hive.openBox<bool>('meta');
    _initialized = true;
  }

  static Future<void> clearCart() async {
    if (!Hive.isBoxOpen('cart')) {
      await Hive.openBox<String>('cart');
    }
    await Hive.box<String>('cart').clear();
  }

  static Future<void> clearOrders() async {
    if (!Hive.isBoxOpen('orders')) {
      await Hive.openBox<String>('orders');
    }
    await Hive.box<String>('orders').clear();
  }

  static Future<void> clearMeta() async {
    if (!Hive.isBoxOpen('meta')) {
      await Hive.openBox<bool>('meta');
    }
    await Hive.box<bool>('meta').clear();
  }

  static Future<void> clearFeedbacks() async {
    if (!Hive.isBoxOpen('feedbacks')) {
      await Hive.openBox<String>('feedbacks');
    }
    await Hive.box<String>('feedbacks').clear();
  }

  static Future<void> clearProfile() async {
    if (!Hive.isBoxOpen('profile')) {
      await Hive.openBox<String>('profile');
    }
    await Hive.box<String>('profile').clear();
  }

  static Future<void> clearAll() async {
    await clearCart();
    await clearOrders();
    await clearFeedbacks();
    await clearProfile();
    await clearMeta();
  }

  static Future<void> dispose() async {
    if (Hive.isBoxOpen('cart')) {
      await Hive.box<String>('cart').close();
    }
    if (Hive.isBoxOpen('orders')) {
      await Hive.box<String>('orders').close();
    }
    if (Hive.isBoxOpen('feedbacks')) {
      await Hive.box<String>('feedbacks').close();
    }
    if (Hive.isBoxOpen('profile')) {
      await Hive.box<String>('profile').close();
    }
    if (Hive.isBoxOpen('meta')) {
      await Hive.box<bool>('meta').close();
    }
    await Hive.close();
    _tempDir = null;
    _initialized = false;
  }
}
