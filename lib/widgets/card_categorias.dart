import 'package:flutter/material.dart';
import '../Models/categoria_model.dart';
import '../store/app_colors.dart';

class CardCategorias extends StatelessWidget {
  final Categoria categoria;
  final int index;
  final int activo;
  final Function(int) onTap;

  const CardCategorias({
    super.key,
    required this.categoria,
    required this.index,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == activo;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.subtitle,
            width: 1,
          ),
        ),
        child: Text(
          categoria.nombre,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.subtitle,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}