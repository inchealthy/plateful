class Restaurant {
  const Restaurant({
    required this.id,
    required this.locationId,
    required this.name,
    required this.cuisine,
    required this.emoji,
    required this.rating,
    required this.hours,
    required this.status,
    required this.lat,
    required this.lng,
    required this.distanceMiles,
    required this.tags,
  });

  final String id;
  final String locationId;
  final String name;
  final String cuisine;
  final String emoji;
  final double rating;
  final String hours;
  final String status;
  final double lat;
  final double lng;
  final double distanceMiles;
  final List<String> tags;

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      locationId: json['locationId'] as String,
      name: json['name'] as String,
      cuisine: json['cuisine'] as String,
      emoji: json['emoji'] as String,
      rating: (json['rating'] as num).toDouble(),
      hours: json['hours'] as String,
      status: json['status'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      distanceMiles: (json['distanceMiles'] as num).toDouble(),
      tags: List<String>.from(json['tags'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locationId': locationId,
      'name': name,
      'cuisine': cuisine,
      'emoji': emoji,
      'rating': rating,
      'hours': hours,
      'status': status,
      'lat': lat,
      'lng': lng,
      'distanceMiles': distanceMiles,
      'tags': tags,
    };
  }
}
