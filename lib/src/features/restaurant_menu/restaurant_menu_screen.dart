import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RestaurantMenuScreen extends StatelessWidget {
  const RestaurantMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurantId = GoRouterState.of(context).pathParameters['restaurantId'];
    return Scaffold(
      appBar: AppBar(title: const Text('RestaurantMenuScreen')),
      body: Center(
        child: Text(
          'TODO: RestaurantMenuScreen\nrestaurantId = ${restaurantId ?? 'unknown'}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
