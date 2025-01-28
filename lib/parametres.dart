import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ParametreScreen extends StatelessWidget {
  final List<Map<String, dynamic>> settingsOptions = [
    {
      'id': '1',
      'title': 'Archive de mes publications et reels',
      'icon': Icons.archive
    },
    {
      'id': '2',
      'title': 'Gérer mes notifications',
      'icon': Icons.notifications
    },
    {'id': '3', 'title': 'Passer sur un compte premium', 'icon': Icons.star},
    {
      'id': '4',
      'title': 'Temps passé sur Le Design Du Web',
      'icon': Icons.access_time
    },
    {'id': '5', 'title': 'Sécurité et mot de passe', 'icon': Icons.security},
    {'id': '6', 'title': 'Compte bloqué', 'icon': Icons.block},
    {'id': '7', 'title': 'Moyen de paiement', 'icon': Icons.payment},
    {
      'id': '8',
      'title': 'Nombre de like et de partages',
      'icon': Icons.thumb_up
    },
    {'id': '9', 'title': 'Autorisation appareil', 'icon': Icons.devices},
    {'id': '10', 'title': 'Langue', 'icon': Icons.language},
    {
      'id': '11',
      'title': 'Information de livraison',
      'icon': Icons.local_shipping
    },
    {'id': '12', 'title': 'Aide', 'icon': Icons.help},
    {'id': '14', 'title': 'À propos', 'icon': Icons.info},
  ];

  void handleSettingPress(BuildContext context, String id) {
    if (id == '13') {
      Navigator.pushReplacementNamed(context, '/welcome');
    } else if (id == '5') {
      Navigator.pushNamed(context, '/security');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: settingsOptions.length,
                itemBuilder: (context, index) {
                  final item = settingsOptions[index];
                  return ListTile(
                    leading: Icon(item['icon'], color: Colors.grey),
                    title: Text(item['title']),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () => handleSettingPress(context, item['id']),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/welcome'),
                child: const Text(
                  'Se déconnecter',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Ajouter'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              // Ajouter action
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/messages');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/parametres');
              break;
          }
        },
      ),
    );
  }
}
