
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../store/app_colors.dart';


class BuildBottomNavigationBar extends StatefulWidget {
  final Function(int) cambiarTab;
  final int currentIndex;

  const BuildBottomNavigationBar({
    super.key,
    required this.cambiarTab,
    required this.currentIndex,
  });

  @override
  State<BuildBottomNavigationBar> createState() => BuildBottomNavigationBarState();
}

class BuildBottomNavigationBarState extends State<BuildBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedIconTheme: const IconThemeData(color: AppColors.primary, size: 40, applyTextScaling: true),
      showUnselectedLabels: true,
      unselectedIconTheme: const IconThemeData(color: AppColors.subtitle, size: 25, applyTextScaling: true),
      unselectedItemColor: AppColors.subtitle,
      currentIndex: widget.currentIndex,
      onTap: widget.cambiarTab,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
        BottomNavigationBarItem(icon: Icon(Icons.newspaper_outlined), label: "Avisos"),
      ],
    );
  }
}
