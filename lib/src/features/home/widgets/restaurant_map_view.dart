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
    this.userLat,
    this.userLng,
    super.key,
  });

  final List<Restaurant> restaurants;
  final double centerLat;
  final double centerLng;
  final ValueChanged<Restaurant> onViewMenu;
  final double? userLat;
  final double? userLng;

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

  void _recenterOnUser() {
    if (widget.userLat != null && widget.userLng != null) {
      _mapController.move(LatLng(widget.userLat!, widget.userLng!), 15);
    }
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
    final hasUserLocation = widget.userLat != null && widget.userLng != null;

    return Stack(
      children: [
        FlutterMap(
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
              userAgentPackageName: 'com.issi.plateful',
            ),
            MarkerLayer(
              markers: [
                if (hasUserLocation)
                  Marker(
                    point: LatLng(widget.userLat!, widget.userLng!),
                    width: 24,
                    height: 24,
                    child: const _UserLocationDot(),
                  ),
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
        ),
        if (hasUserLocation)
          Positioned(
            right: 12,
            bottom: 12,
            child: GestureDetector(
              onTap: _recenterOnUser,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _UserLocationDot extends StatelessWidget {
  const _UserLocationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xFF4285F4),
            shape: BoxShape.circle,
          ),
        ),
      ),
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
