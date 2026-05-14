import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../home/home_controller.dart';
import '../home/widgets/restaurant_list_view.dart';

class FeedbackTabScreen extends ConsumerWidget {
  const FeedbackTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    final restaurants = homeState.selectedLocationId.isEmpty
        ? homeState.allRestaurants
        : homeState.allRestaurants
            .where((r) => r.locationId == homeState.selectedLocationId)
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: RestaurantListView(
        restaurants: restaurants,
        isLoading: homeState.isLoading,
        showMeta: false,
        onTapRestaurant: (restaurant) =>
            context.push('/feedback/restaurant/${restaurant.id}'),
      ),
    );
  }
}
