import 'package:flutter/material.dart';

import '../../../common/components/app_search_bar.dart';
import '../../../common/domain/entities/building_location.dart';

class LocationSelectorScreen extends StatefulWidget {
  const LocationSelectorScreen({
    required this.locations,
    required this.selectedLocationId,
    required this.distanceKmByLocationId,
    required this.showDistance,
    super.key,
  });

  final List<BuildingLocation> locations;
  final String selectedLocationId;
  final Map<String, double> distanceKmByLocationId;
  final bool showDistance;

  @override
  State<LocationSelectorScreen> createState() => _LocationSelectorScreenState();
}

class _LocationSelectorScreenState extends State<LocationSelectorScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredLocations();

    return Scaffold(
      appBar: AppBar(title: const Text('Change location')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Search location',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('No locations found'))
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final location = list[index];
                      final distance =
                          widget.distanceKmByLocationId[location.id];
                      final subtitle = widget.showDistance && distance != null
                          ? '${distance.toStringAsFixed(1)} km away'
                          : null;
                      final selected = location.id == widget.selectedLocationId;

                      return ListTile(
                        key: Key('location-item-${location.id}'),
                        title: Text(location.name),
                        subtitle: subtitle == null ? null : Text(subtitle),
                        trailing: selected
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(Icons.radio_button_unchecked),
                        onTap: () => Navigator.of(context).pop(location.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<BuildingLocation> _filteredLocations() {
    if (_searchQuery.isEmpty) {
      return widget.locations;
    }

    return widget.locations
        .where((location) => location.name.toLowerCase().contains(_searchQuery))
        .toList();
  }
}
