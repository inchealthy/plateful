import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/themes/app_colors.dart';
import '../../../common/domain/entities/restaurant.dart';
import 'map_pin_bottom_sheet.dart';

class RestaurantMapView extends StatefulWidget {
  const RestaurantMapView({
    required this.restaurants,
    required this.centerLat,
    required this.centerLng,
    required this.onViewMenu,
    super.key,
  });

  final List<Restaurant> restaurants;
  final double centerLat;
  final double centerLng;
  final ValueChanged<Restaurant> onViewMenu;

  @override
  State<RestaurantMapView> createState() => _RestaurantMapViewState();
}

class _RestaurantMapViewState extends State<RestaurantMapView> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(covariant RestaurantMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasCenterChanged =
        oldWidget.centerLat != widget.centerLat ||
        oldWidget.centerLng != widget.centerLng;
    if (hasCenterChanged) {
      _moveToSelectedLocation();
    }
  }

  void _moveToSelectedLocation() {
    try {
      _mapController.move(LatLng(widget.centerLat, widget.centerLng), 15);
    } catch (_) {}
  }

  void _showPinSheet(BuildContext context, Restaurant restaurant) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return MapPinBottomSheet(
          restaurant: restaurant,
          onViewMenu: () {
            Navigator.of(context).pop();
            widget.onViewMenu(restaurant);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      key: ValueKey(
        'map-${widget.centerLat.toStringAsFixed(6)}-${widget.centerLng.toStringAsFixed(6)}-${widget.restaurants.length}',
      ),
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(widget.centerLat, widget.centerLng),
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.plateful',
        ),
        MarkerLayer(
          markers: [
            for (final restaurant in widget.restaurants)
              Marker(
                point: LatLng(restaurant.lat, restaurant.lng),
                width: 48,
                height: 48,
                child: GestureDetector(
                  onTap: () => _showPinSheet(context, restaurant),
                  child: _RestaurantPin(emoji: restaurant.emoji),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _RestaurantPin extends StatelessWidget {
  const _RestaurantPin({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }
}
