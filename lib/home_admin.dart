import 'package:flutter/material.dart';
import 'package:ledesignduweb/connexion.dart';

class HomeadminScreen extends StatefulWidget {
  @override
  _HomeadminScreenState createState() => _HomeadminScreenState();
}

class _HomeadminScreenState extends State<HomeadminScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Statistiques(),
    Gestionsproduits(),
    Gestionscommandes(),
    parametres(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Interface Administrateur',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up,
                color: Color.fromARGB(255, 18, 158, 13)),
            label: 'Statistiques',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory, color: Color.fromARGB(255, 43, 42, 41)),
            label: 'Gestion Produits',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.storefront, color: Color.fromARGB(255, 43, 42, 41)),
            label: 'Gestion Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}

class Statistiques extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Statistiques sur les produits',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class Gestionsproduits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Gestion des Produits',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class Gestionscommandes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Gestion des Commandes',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class parametres extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ListTile(
          leading: const Icon(Icons.person, color: Colors.blue),
          title: const Text("Profil utilisateur"),
          subtitle: const Text("Modifier les informations personnelles"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.lock, color: Colors.red),
          title: const Text("Changer le mot de passe"),
          subtitle: const Text("Mettre à jour votre mot de passe"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.notifications, color: Colors.orange),
          title: const Text("Notifications"),
          subtitle: const Text("Configurer vos préférences de notification"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.help, color: Colors.green),
          title: const Text("Centre d'aide"),
          subtitle: const Text("Obtenir de l'aide et des FAQ"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info, color: Colors.grey),
          title: const Text("À propos de l'application"),
          subtitle: const Text("Informations sur cette application"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("Déconnexion"),
          subtitle: const Text("Se déconnecter de votre compte"),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Déconnexion"),
                content:
                    const Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
                actions: [
                  TextButton(
                    child: const Text("Annuler"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Déconnexion"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => ConnexionScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeadminScreen(),
  ));
}
