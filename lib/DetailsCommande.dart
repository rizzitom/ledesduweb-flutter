import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailsCommande extends StatefulWidget {
  final int commandeId;
  const DetailsCommande(this.commandeId, {super.key});

  @override
  _DetailsCommandeState createState() => _DetailsCommandeState();
}

class _DetailsCommandeState extends State<DetailsCommande> {
  bool isLoading = true;
  bool isError = false;
  Map<String, dynamic> commandeDetails = {};

  @override
  void initState() {
    super.initState();
    fetchDetailsCommande();
  }

  Future<void> fetchDetailsCommande() async {
    final url =
        Uri.parse('http://10.0.2.2:3000/commandes/${widget.commandeId}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          commandeDetails = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      print("Erreur lors de la récupération des données: $e");
    }
  }

  static const Color backgroundColor = Color(0xFF2d2c2e);
  static const Color textColor = Colors.white;
  static const Color primaryColor = Color(0xFF6200b3);

  void _modifierCommande() {
    print("Modifier la commande");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Détails de la commande #${widget.commandeId}",
          style: const TextStyle(color: textColor),
        ),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: textColor))
          : isError
              ? const Center(
                  child: Text(
                    "Erreur de chargement des données",
                    style: TextStyle(color: textColor),
                  ),
                )
              : commandeDetails.isEmpty
                  ? const Center(
                      child: Text(
                        "Aucune information disponible",
                        style: TextStyle(color: textColor),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: [
                          buildDetailRow(
                            "Utilisateur:",
                            commandeDetails['commande']
                                    ['utilisateur_username'] ??
                                'Non précisé',
                          ),
                          buildDetailRow(
                            "Statut:",
                            commandeDetails['commande']['statut'],
                          ),
                          buildDetailRow(
                            "Total:",
                            "${commandeDetails['commande']['total']} €",
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Adresse de Livraison:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            commandeDetails['commande']['adresse_livraison'],
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Articles inclus:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 5),
                          ...commandeDetails['articles']
                                  ?.map<Widget>((article) {
                                return Text(
                                  "${article['nom']} - ${article['quantite']}x",
                                  style: const TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                );
                              })?.toList() ??
                              [
                                const Text(
                                  "Aucun article",
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                )
                              ],
                          const SizedBox(height: 20),
                          const Text(
                            "Informations de paiement:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 5),
                          ...commandeDetails['articles']
                                  ?.map<Widget>((article) {
                                return Text(
                                  "${article['mode_paiement']} - ${article['quantite']}x - ${article['prix_unitaire']} €",
                                  style: const TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                );
                              })?.toList() ??
                              [
                                const Text(
                                  "Aucune information de paiement",
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                )
                              ],
                        ],
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _modifierCommande,
        label: const Text('Modifier la commande'),
        icon: const Icon(Icons.edit),
        backgroundColor: const Color.fromARGB(255, 254, 254, 255),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
