import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../common/components/app_bottom_nav_bar.dart';
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
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: widget.shell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
