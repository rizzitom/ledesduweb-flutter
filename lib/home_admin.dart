import 'package:flutter/material.dart';
import 'package:ledesignduweb/gestions_commandes.dart';
import 'package:ledesignduweb/gestions_produits.dart';
import 'package:ledesignduweb/parametres.dart';
import 'package:ledesignduweb/statistiques.dart';

class HomeadminScreen extends StatefulWidget {
  @override
  _HomeadminScreenState createState() => _HomeadminScreenState();
}

class _HomeadminScreenState extends State<HomeadminScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Statistiques(),
    GestionsProduits(),
    GestionsCommandes(),
    Parametres(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2d2c2e),
        elevation: 0,
        title: const Text(
          'Administration LDDW',
          style: TextStyle(
            color: Color.fromARGB(255, 252, 252, 252),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/img/logo/logo.png',
            fit: BoxFit.contain,
            height: 30,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications,
                color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () {},
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF6200b3),
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        showUnselectedLabels: true,
        showSelectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart, color: Color.fromARGB(255, 0, 0, 0)),
            label: 'Statistiques',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.conveyor_belt, color: Color.fromARGB(255, 0, 0, 0)),
            label: 'Catalogues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront, color: Color.fromARGB(255, 0, 0, 0)),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Color.fromARGB(255, 0, 0, 0)),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }

  void main() {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeadminScreen(),
    ));
  }
}
