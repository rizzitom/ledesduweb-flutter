import 'package:flutter/material.dart';
import 'inscription.dart';
import 'connexion.dart';
import 'mdpforget.dart';
import 'home_admin.dart';
import 'parametres.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Le Design Du Web App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ConnexionScreen(),
        '/inscription': (context) => const InscriptionScreen(),
        '/mdpforget': (context) => const MdpForgetScreen(),
        '/home_admin': (context) => HomeadminScreen(),
        '/parametres': (context) => ParametreScreen(),
      },
    );
  }
}
