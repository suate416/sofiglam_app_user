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
  State<BuildBottomNavigationBar> createState() =>
      BuildBottomNavigationBarState();
}

class BuildBottomNavigationBarState extends State<BuildBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color.fromARGB(255, 250, 236, 220),
      selectedIconTheme: const IconThemeData(
          color: AppColors.primary, size: 40, applyTextScaling: true),
      showUnselectedLabels: true,
      unselectedIconTheme: const IconThemeData(
          color: AppColors.subtitle, size: 25, applyTextScaling: true),
      unselectedItemColor: AppColors.subtitle,
      selectedItemColor: AppColors.primary,
      selectedLabelStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        color: AppColors.subtitle,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      currentIndex: widget.currentIndex,
      onTap: widget.cambiarTab,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
        BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone_outlined), label: "Contacto"),
      ],
    );
  }
}
