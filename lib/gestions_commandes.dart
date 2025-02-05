import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'DetailsCommande.dart';

class GestionsCommandes extends StatefulWidget {
  const GestionsCommandes({super.key});

  @override
  _GestionsCommandesState createState() => _GestionsCommandesState();
}

class _GestionsCommandesState extends State<GestionsCommandes> {
  List commandes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCommandes();
  }

  Future<void> fetchCommandes() async {
    final url = Uri.parse('http://10.0.2.2:3000/commandes/en-cours');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          commandes = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Erreur de chargement');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2d2c2e),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : commandes.isEmpty
              ? const Center(
                  child: Text('Aucune commande en cours',
                      style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  itemCount: commandes.length,
                  itemBuilder: (context, index) {
                    final commande = commandes[index];
                    return Card(
                      color: Colors.white12,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          "Commande #${commande['id']}",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Utilisateur: ${commande['utilisateur_username']}",
                                style: const TextStyle(color: Colors.white70)),
                            Text("Total: ${commande['total']} €",
                                style: const TextStyle(color: Colors.white70)),
                            Text("Livraison: ${commande['adresse_livraison']}",
                                style: const TextStyle(color: Colors.white70)),
                            Text("Statut: ${commande['statut']}",
                                style: TextStyle(
                                    color: commande['statut'] == 'En cours'
                                        ? Colors.orange
                                        : Colors.green)),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward,
                            color: Colors.white),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailsCommande(commande['id']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
