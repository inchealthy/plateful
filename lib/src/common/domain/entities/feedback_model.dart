class FeedbackModel {
  const FeedbackModel({
    required this.id,
    this.orderId,
    this.restaurantId,
    required this.overallRating,
    required this.foodRating,
    required this.serviceRating,
    required this.recommendRating,
    this.comment,
    required this.submittedAt,
  });

  final String id;
  final String? orderId;
  final String? restaurantId;
  final int overallRating;
  final int foodRating;
  final int serviceRating;
  final int recommendRating;
  final String? comment;
  final DateTime submittedAt;

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String?,
      restaurantId: json['restaurantId'] as String?,
      overallRating: json['overallRating'] as int,
      foodRating: json['foodRating'] as int,
      serviceRating: json['serviceRating'] as int,
      recommendRating: json['recommendRating'] as int,
      comment: json['comment'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'restaurantId': restaurantId,
      'overallRating': overallRating,
      'foodRating': foodRating,
      'serviceRating': serviceRating,
      'recommendRating': recommendRating,
      'comment': comment,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}
