import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = GoRouterState.of(context).pathParameters['orderId'];
    return Scaffold(
      appBar: AppBar(title: const Text('FeedbackScreen')),
      body: Center(
        child: Text(
          'TODO: FeedbackScreen\norderId = ${orderId ?? 'unknown'}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
