import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/app/themes/app_theme.dart';
import 'src/routing/routes.dart';
import 'src/utils/dummy_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('cart');
  await Hive.openBox<String>('feedbacks');
  await Hive.openBox<String>('profile');
  final ordersBox = await Hive.openBox<String>('orders');
  final metaBox = await Hive.openBox<bool>('meta');
  await DummyData.seedIfNeeded(ordersBox, metaBox);

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  runApp(const ProviderScope(child: PlatefulApp()));
}

class PlatefulApp extends StatelessWidget {
  const PlatefulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: MaterialApp.router(
          title: 'NutriHero',
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );
  }
}
