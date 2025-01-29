import 'package:flutter/material.dart';
import 'package:ledesignduweb/connexion.dart';

class Parametres extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2d2c2e),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text("Profil utilisateur"),
            textColor: Colors.white,
            subtitle: const Text("Modifier les informations personnelles"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            iconColor: Colors.white,
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.red),
            title: const Text("Changer le mot de passe"),
            textColor: Colors.white,
            subtitle: const Text("Mettre à jour votre mot de passe"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            iconColor: Colors.white,
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.orange),
            title: const Text("Notifications"),
            textColor: Colors.white,
            subtitle: const Text("Configurer vos préférences de notification"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            iconColor: Colors.white,
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.green),
            title: const Text("Centre d'aide"),
            textColor: Colors.white,
            subtitle: const Text("Obtenir de l'aide et des FAQ"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            iconColor: Colors.white,
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.grey),
            title: const Text("À propos de l'application"),
            textColor: Colors.white,
            subtitle: const Text("Informations sur cette application"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            iconColor: Colors.white,
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Déconnexion"),
            textColor: Colors.white,
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
                            builder: (context) => const ConnexionScreen(),
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
      ),
    );
  }
}
