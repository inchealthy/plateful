import '../../common/domain/entities/order.dart';

enum FeedbackDimension { overall, food, service, recommend }

class FeedbackState {
  const FeedbackState({
    this.order,
    this.overallRating = 0,
    this.foodRating = 0,
    this.serviceRating = 0,
    this.recommendRating = 0,
    this.comment = '',
    this.isSubmitting = false,
    this.submitted = false,
  });

  final Order? order;
  final int overallRating;
  final int foodRating;
  final int serviceRating;
  final int recommendRating;
  final String comment;
  final bool isSubmitting;
  final bool submitted;

  bool get canSubmit =>
      overallRating > 0 &&
      foodRating > 0 &&
      serviceRating > 0 &&
      recommendRating > 0;

  FeedbackState copyWith({
    Order? order,
    bool clearOrder = false,
    int? overallRating,
    int? foodRating,
    int? serviceRating,
    int? recommendRating,
    String? comment,
    bool? isSubmitting,
    bool? submitted,
  }) {
    return FeedbackState(
      order: clearOrder ? null : (order ?? this.order),
      overallRating: overallRating ?? this.overallRating,
      foodRating: foodRating ?? this.foodRating,
      serviceRating: serviceRating ?? this.serviceRating,
      recommendRating: recommendRating ?? this.recommendRating,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitted: submitted ?? this.submitted,
    );
  }
}
