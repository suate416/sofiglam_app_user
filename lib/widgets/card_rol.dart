import 'package:flutter/material.dart';

//import '../Screens/carrito_screen.dart';
import '../store/app_colors.dart';

class CardRol extends StatelessWidget {
  final String rol;

  const CardRol({super.key, required this.rol});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 210, 208, 208)),
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(
            Icons.diamond,
            color: AppColors.primary,
            size: 50,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                rol,
                style: const TextStyle(color: AppColors.title, fontSize: 40),
              ),
            ],
          ),
          GestureDetector(
              child: const Icon(
                Icons.shopping_cart,
                color: AppColors.primary,
                size: 40,
              ),
              /*onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CarritoScreen()));
              } */)
        ],
      ),
    );
  }
}
