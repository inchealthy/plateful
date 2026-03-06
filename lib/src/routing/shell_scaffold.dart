import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/themes/app_colors.dart';
import 'route_enums.dart';

class ShellScaffold extends StatefulWidget {
  const ShellScaffold({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  static const _tabPaths = [
    AppRoute.home,
    AppRoute.orders,
    AppRoute.feedback,
    AppRoute.profile,
  ];

  void _onTap(int index) {
    context.go(_tabPaths[index].path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.shell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.shell.currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
