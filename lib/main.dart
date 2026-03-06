import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/app/themes/app_theme.dart';
import 'src/routing/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  try {
    await Firebase.initializeApp();
  } catch (_) {}

  runApp(const ProviderScope(child: PlatefulApp()));
}

class PlatefulApp extends StatelessWidget {
  const PlatefulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp.router(
        title: 'Plateful',
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
  }
}
