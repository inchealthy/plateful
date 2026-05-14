import 'package:flutter/material.dart';

import '../../../common/domain/entities/order.dart';

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const _restaurantEmojiById = {
  'r1': '🍽️',
  'r2': '🥗',
  'r3': '☕',
  'r4': '🍔',
  'r5': '🌿',
  'r6': '🏪',
  'r7': '☀️',
};

String orderDateLabel(DateTime dateTime) {
  final month = _monthNames[dateTime.month - 1];
  final day = dateTime.day;

  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';

  return '$month $day · $hour:$minute $period';
}

String orderShortId(Order order) {
  final id = order.id;
  if (id.length <= 6) {
    return id;
  }
  return id.substring(id.length - 6);
}

String orderItemsSummary(Order order) {
  final names = order.items.map((e) => e.item.name).toList();
  if (names.isEmpty) {
    return '-';
  }

  final head = names.take(2).join(', ');
  if (names.length <= 2) {
    return head;
  }

  return '$head +${names.length - 2} more';
}

String orderRestaurantEmoji(Order order) {
  return _restaurantEmojiById[order.restaurantId] ?? '🍽️';
}

Color orderStatusBackground(String status) {
  switch (status) {
    case 'preparing':
      return const Color(0xFFFFF3E0);
    case 'ready':
      return const Color(0xFFE8F5E9);
    case 'completed':
      return const Color(0xFFF5F5F5);
    default:
      return const Color(0xFFF5F5F5);
  }
}

Color orderStatusTextColor(String status) {
  switch (status) {
    case 'preparing':
      return const Color(0xFFFF9800);
    case 'ready':
      return const Color(0xFF4CAF50);
    case 'completed':
      return const Color(0xFF666666);
    default:
      return const Color(0xFF666666);
  }
}

String orderStatusLabel(String status) {
  if (status.isEmpty) {
    return '-';
  }
  return status[0].toUpperCase() + status.substring(1);
}
