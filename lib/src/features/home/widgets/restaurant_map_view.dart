import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/themes/app_colors.dart';
import '../../../common/domain/entities/restaurant.dart';
import 'map_pin_bottom_sheet.dart';

class RestaurantMapView extends StatefulWidget {
  const RestaurantMapView({
    required this.restaurants,
    required this.onViewMenu,
    super.key,
  });

  final List<Restaurant> restaurants;
  final ValueChanged<Restaurant> onViewMenu;

  @override
  State<RestaurantMapView> createState() => _RestaurantMapViewState();
}

class _RestaurantMapViewState extends State<RestaurantMapView> {
  static const _latOffsets = [0.002, -0.003, 0.005, -0.004, 0.007, -0.001];
  static const _lngOffsets = [-0.003, 0.004, -0.002, 0.006, -0.005, 0.003];

  final MapController _mapController = MapController();

  double _originLat = 0;
  double _originLng = 0;
  double _centerLat = 0;
  double _centerLng = 0;
  bool _hasLocation = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initLocation());
  }

  @override
  void didUpdateWidget(covariant RestaurantMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasLocation &&
        oldWidget.restaurants.length != widget.restaurants.length) {
      _setFallbackCenter();
    }
  }

  Future<void> _initLocation() async {
    try {
      final permission = await Geolocator.requestPermission().timeout(
        const Duration(seconds: 1),
      );
      if (!mounted) return;

      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (granted) {
        final pos = await Geolocator.getCurrentPosition().timeout(
          const Duration(seconds: 1),
        );
        if (!mounted) return;
        setState(() {
          _originLat = pos.latitude;
          _originLng = pos.longitude;
          _centerLat = pos.latitude;
          _centerLng = pos.longitude;
          _hasLocation = true;
          _isReady = true;
        });
        return;
      }
    } catch (_) {}

    if (!mounted) return;
    _setFallbackCenter();
  }

  void _setFallbackCenter() {
    final points =
        _buildPoints(widget.restaurants.length, baseLat: 0, baseLng: 0);
    var avgLat = 0.0;
    var avgLng = 0.0;

    if (points.isNotEmpty) {
      avgLat =
          points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
      avgLng = points.map((p) => p.longitude).reduce((a, b) => a + b) /
          points.length;
    }

    setState(() {
      _originLat = 0;
      _originLng = 0;
      _centerLat = avgLat;
      _centerLng = avgLng;
      _hasLocation = false;
      _isReady = true;
    });
    _safeMoveToCenter();
  }

  void _safeMoveToCenter() {
    try {
      _mapController.move(LatLng(_centerLat, _centerLng), 15);
    } catch (_) {}
  }

  List<LatLng> _buildPoints(
    int count, {
    required double baseLat,
    required double baseLng,
  }) {
    return List<LatLng>.generate(count, (index) {
      final latOffset = _latOffsets[index % _latOffsets.length];
      final lngOffset = _lngOffsets[index % _lngOffsets.length];
      return LatLng(baseLat + latOffset, baseLng + lngOffset);
    });
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
    if (!_isReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final points = _buildPoints(
      widget.restaurants.length,
      baseLat: _originLat,
      baseLng: _originLng,
    );

    return Stack(
      children: [
        FlutterMap(
          key: ValueKey(
            'map-${_centerLat.toStringAsFixed(6)}-${_centerLng.toStringAsFixed(6)}-${widget.restaurants.length}',
          ),
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(_centerLat, _centerLng),
            initialZoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.plateful',
            ),
            if (_hasLocation)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(_originLat, _originLng),
                    radius: 10,
                    color: Colors.blue.withValues(alpha: 0.3),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                for (int i = 0; i < widget.restaurants.length; i++)
                  Marker(
                    point: points[i],
                    width: 48,
                    height: 48,
                    child: GestureDetector(
                      onTap: () =>
                          _showPinSheet(context, widget.restaurants[i]),
                      child: _RestaurantPin(emoji: widget.restaurants[i].emoji),
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (!_hasLocation)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4CE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFD666)),
              ),
              child: const Text(
                '📍 Enable location for better experience',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: AppColors.primary,
            onPressed: _safeMoveToCenter,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
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
