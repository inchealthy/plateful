import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../common/domain/entities/feedback_model.dart';
import '../orders/orders_controller.dart';
import 'feedback_state.dart';

class FeedbackController extends FamilyNotifier<FeedbackState, String> {
  static const _boxName = 'feedbacks';
  static const _feedbacksKey = 'feedbacks_list';

  @override
  FeedbackState build(String orderId) {
    Future.microtask(() => _loadOrder(orderId));
    return const FeedbackState();
  }

  void _loadOrder(String orderId) {
    final orders = ref.read(ordersProvider).orders;
    for (final order in orders) {
      if (order.id == orderId) {
        state = state.copyWith(order: order);
        return;
      }
    }
  }

  void setRating(FeedbackDimension dimension, int value) {
    state = switch (dimension) {
      FeedbackDimension.overall =>
        state.copyWith(overallRating: value, submitted: false),
      FeedbackDimension.foodQuality =>
        state.copyWith(foodQualityRating: value, submitted: false),
      FeedbackDimension.portionSize =>
        state.copyWith(portionSizeRating: value, submitted: false),
      FeedbackDimension.serviceSpeed =>
        state.copyWith(serviceSpeedRating: value, submitted: false),
    };
  }

  void setComment(String text) {
    state = state.copyWith(comment: text, submitted: false);
  }

  Future<void> submit() async {
    final order = state.order;
    if (order == null || !state.canSubmit) {
      return;
    }

    state = state.copyWith(isSubmitting: true, submitted: false);

    final feedback = FeedbackModel(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      orderId: order.id,
      overallRating: state.overallRating,
      foodQualityRating: state.foodQualityRating,
      portionSizeRating: state.portionSizeRating,
      serviceSpeedRating: state.serviceSpeedRating,
      comment: state.comment.trim().isEmpty ? null : state.comment.trim(),
      submittedAt: DateTime.now(),
    );

    final box = Hive.box<String>(_boxName);
    final raw = box.get(_feedbacksKey);

    final list = <FeedbackModel>[];
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final value in decoded) {
          list.add(FeedbackModel.fromJson(value as Map<String, dynamic>));
        }
      } catch (_) {}
    }

    list.add(feedback);

    box.put(
      _feedbacksKey,
      jsonEncode(list.map((value) => value.toJson()).toList()),
    );

    ref.read(ordersProvider.notifier).markAsRated(order.id);

    state = state.copyWith(isSubmitting: false, submitted: true);
  }
}

final feedbackProvider =
    NotifierProvider.family<FeedbackController, FeedbackState, String>(
  FeedbackController.new,
);
