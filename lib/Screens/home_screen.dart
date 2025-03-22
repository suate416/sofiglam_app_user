import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/card_rol.dart';
import 'buscar_screen.dart';
import 'tienda_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int indexActual = 0;

  final List<Widget> screens = [
    const TiendaScreen(),
    const BuscarScreen()

  ];

  void _cambiarTab(int index) {
    setState(() {
      indexActual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
          child: Column(
            children: [
              CardRol(rol: "SofiGlam" ),
              Expanded(
                child: Center(
                  child: screens[indexActual],
                ),
              ),
            ],
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