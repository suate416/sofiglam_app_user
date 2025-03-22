import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/card_rol.dart';
import 'buscar_screen.dart';
import 'tienda_screen.dart';
import 'contacto_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int indexActual = 0;

  final List<Widget> screens = [
    const TiendaScreen(),
    const BuscarScreen(),
    const ContactoScreen(),
  ];

  void _cambiarTab(int index) {
    setState(() {
      indexActual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey[50]!,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const CardRol(rol: "SofiGlam"),
                ),
                Expanded(
                  child: Center(
                    child: screens[indexActual],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BuildBottomNavigationBar(
        cambiarTab: _cambiarTab,
        currentIndex: indexActual,
      ),
    );
  }
}
