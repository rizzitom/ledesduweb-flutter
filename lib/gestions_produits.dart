import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GestionsProduits extends StatefulWidget {
  @override
  _GestionsProduitsState createState() => _GestionsProduitsState();
}

class _GestionsProduitsState extends State<GestionsProduits> {
  List produits = [];

  @override
  void initState() {
    super.initState();
    fetchProduits();
  }

  Future<void> fetchProduits() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/produits'));

    if (response.statusCode == 200) {
      setState(() {
        produits = jsonDecode(response.body);
      });
    } else {
      throw Exception('Erreur lors du chargement des produits');
    }
  }

  Future<void> ajouterOuModifierProduit({Map<String, dynamic>? produit}) async {
    TextEditingController nomController =
        TextEditingController(text: produit?['nom'] ?? '');
    TextEditingController descriptionController =
        TextEditingController(text: produit?['description'] ?? '');
    TextEditingController prixController =
        TextEditingController(text: produit?['prix']?.toString() ?? '');
    TextEditingController stockController =
        TextEditingController(text: produit?['stock']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(produit == null ? "Ajouter Produit" : "Modifier Produit"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                decoration: const InputDecoration(labelText: "Nom"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: prixController,
                decoration: const InputDecoration(labelText: "Prix"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: "Stock"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(produit == null ? "Ajouter" : "Modifier"),
              onPressed: () async {
                final body = jsonEncode({
                  "nom": nomController.text,
                  "description": descriptionController.text,
                  "prix": double.tryParse(prixController.text) ?? 0.0,
                  "stock": int.tryParse(stockController.text) ?? 0,
                });

                if (produit == null) {
                  await http.post(
                    Uri.parse('http://10.0.2.2:3000/produits'),
                    headers: {"Content-Type": "application/json"},
                    body: body,
                  );
                } else {
                  await http.put(
                    Uri.parse('http://10.0.2.2:3000/produits/${produit['id']}'),
                    headers: {"Content-Type": "application/json"},
                    body: body,
                  );
                }

                Navigator.of(context).pop();
                fetchProduits();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> supprimerProduit(int id) async {
    final response =
        await http.delete(Uri.parse('http://10.0.2.2:3000/produits/$id'));

    if (response.statusCode == 200) {
      fetchProduits();
    } else {
      throw Exception('Erreur lors de la suppression du produit');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2d2c2e),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => ajouterOuModifierProduit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6200b3),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Ajouter un produit",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: produits.length,
                itemBuilder: (context, index) {
                  final produit = produits[index];
                  return Card(
                    child: ListTile(
                      title: Text(produit['nom']),
                      subtitle: Text(
                          "Prix: ${produit['prix']} € | Stock: ${produit['stock']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color(0xFF6200b3)),
                            onPressed: () =>
                                ajouterOuModifierProduit(produit: produit),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => supprimerProduit(produit['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
