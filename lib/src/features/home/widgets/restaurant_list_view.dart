import 'package:flutter/material.dart';

import '../../../common/components/restaurant_card.dart';
import '../../../common/domain/entities/restaurant.dart';

class RestaurantListView extends StatelessWidget {
  const RestaurantListView({
    required this.restaurants,
    required this.isLoading,
    required this.onTapRestaurant,
    super.key,
  });

  final List<Restaurant> restaurants;
  final bool isLoading;
  final ValueChanged<Restaurant> onTapRestaurant;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (restaurants.isEmpty) {
      return const Center(
        child: Text('No restaurants found'),
      );
    }

    return ListView.builder(
      key: const Key('home-restaurant-list'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return RestaurantCard(
          restaurant: restaurant,
          onTap: () => onTapRestaurant(restaurant),
        );
      },
    );
  }
}
