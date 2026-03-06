class FeedbackModel {
  const FeedbackModel({
    required this.id,
    required this.orderId,
    required this.overallRating,
    required this.foodQualityRating,
    required this.portionSizeRating,
    required this.serviceSpeedRating,
    this.comment,
    required this.submittedAt,
  });

  final String id;
  final String orderId;
  final int overallRating;
  final int foodQualityRating;
  final int portionSizeRating;
  final int serviceSpeedRating;
  final String? comment;
  final DateTime submittedAt;

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      overallRating: json['overallRating'] as int,
      foodQualityRating: json['foodQualityRating'] as int,
      portionSizeRating: json['portionSizeRating'] as int,
      serviceSpeedRating: json['serviceSpeedRating'] as int,
      comment: json['comment'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'overallRating': overallRating,
      'foodQualityRating': foodQualityRating,
      'portionSizeRating': portionSizeRating,
      'serviceSpeedRating': serviceSpeedRating,
      'comment': comment,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}
