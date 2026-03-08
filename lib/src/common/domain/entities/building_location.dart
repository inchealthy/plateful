class BuildingLocation {
  const BuildingLocation({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
  });

  final String id;
  final String name;
  final double lat;
  final double lng;

  factory BuildingLocation.fromJson(Map<String, dynamic> json) {
    return BuildingLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'lat': lat, 'lng': lng};
  }
}
