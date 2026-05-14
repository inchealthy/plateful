import 'package:flutter/material.dart';

import '../../../common/components/restaurant_card.dart';
import '../../../common/domain/entities/restaurant.dart';

class RestaurantListView extends StatelessWidget {
  const RestaurantListView({
    required this.restaurants,
    required this.isLoading,
    required this.onTapRestaurant,
    this.bottomPadding = 20,
    this.showMeta = true,
    super.key,
  });

  final List<Restaurant> restaurants;
  final bool isLoading;
  final ValueChanged<Restaurant> onTapRestaurant;
  final double bottomPadding;
  final bool showMeta;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (restaurants.isEmpty) {
      return const Center(
        child: _NoResultsWidget(),
      );
    }

    return ListView.builder(
      key: const Key('home-restaurant-list'),
      padding: EdgeInsets.fromLTRB(16, 4, 16, bottomPadding),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return RestaurantCard(
          restaurant: restaurant,
          onTap: () => onTapRestaurant(restaurant),
          showMeta: showMeta,
        );
      },
    );
  }
}

class _NoResultsWidget extends StatelessWidget {
  const _NoResultsWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text('🔍', style: TextStyle(fontSize: 56)),
        SizedBox(height: 8),
        Text('No restaurants found'),
        SizedBox(height: 4),
        Text('Try a different search'),
      ],
    );
  }
}
