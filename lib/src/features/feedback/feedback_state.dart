import '../../common/domain/entities/order.dart';

enum FeedbackDimension { overall, foodQuality, portionSize, serviceSpeed }

class FeedbackState {
  const FeedbackState({
    this.order,
    this.overallRating = 0,
    this.foodQualityRating = 0,
    this.portionSizeRating = 0,
    this.serviceSpeedRating = 0,
    this.comment = '',
    this.isSubmitting = false,
    this.submitted = false,
  });

  final Order? order;
  final int overallRating;
  final int foodQualityRating;
  final int portionSizeRating;
  final int serviceSpeedRating;
  final String comment;
  final bool isSubmitting;
  final bool submitted;

  bool get canSubmit {
    return overallRating > 0 &&
        foodQualityRating > 0 &&
        portionSizeRating > 0 &&
        serviceSpeedRating > 0;
  }

  FeedbackState copyWith({
    Order? order,
    bool clearOrder = false,
    int? overallRating,
    int? foodQualityRating,
    int? portionSizeRating,
    int? serviceSpeedRating,
    String? comment,
    bool? isSubmitting,
    bool? submitted,
  }) {
    return FeedbackState(
      order: clearOrder ? null : (order ?? this.order),
      overallRating: overallRating ?? this.overallRating,
      foodQualityRating: foodQualityRating ?? this.foodQualityRating,
      portionSizeRating: portionSizeRating ?? this.portionSizeRating,
      serviceSpeedRating: serviceSpeedRating ?? this.serviceSpeedRating,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitted: submitted ?? this.submitted,
    );
  }
}
