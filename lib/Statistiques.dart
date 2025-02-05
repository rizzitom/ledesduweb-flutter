import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Statistiques extends StatefulWidget {
  @override
  _StatistiquesState createState() => _StatistiquesState();
}

class _StatistiquesState extends State<Statistiques> {
  String users = '0';
  String newUsers = '0';
  String products = '0';
  String totalOrders = '0';
  List<FlSpot> evolutionUsersData = [];
  List<FlSpot> evolutionOrdersData = [];
  List ongoingOrders = [];

  Future<void> fetchStatistics() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:3000/statistiques'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          users = data['activeUsers'].toString();
          newUsers = data['newUsers'].toString();
          products = data['onlineProducts'].toString();
          totalOrders = data['totalOrders'].toString();
        });
      } else {
        throw Exception('Échec de la récupération des statistiques');
      }
    } catch (e) {
      print('Erreur de connexion: $e');
    }
  }

  Future<void> fetchEvolutionData() async {
    final usersResponse = await http
        .get(Uri.parse('http://10.0.2.2:3000/evolution-statistiques'));
    final ordersResponse =
        await http.get(Uri.parse('http://10.0.2.2:3000/evolution-commandes'));

    if (usersResponse.statusCode == 200 && ordersResponse.statusCode == 200) {
      final usersData = json.decode(usersResponse.body);
      final ordersData = json.decode(ordersResponse.body);

      setState(() {
        evolutionUsersData = (usersData as List).map<FlSpot>((item) {
          return FlSpot((item['mois'] as num).toDouble(),
              (item['nouveaux_utilisateurs'] as num).toDouble());
        }).toList();

        evolutionOrdersData = ordersData.map<FlSpot>((item) {
          return FlSpot(
              item['mois'].toDouble(), item['nombre_commandes'].toDouble());
        }).toList();
      });
    } else {
      throw Exception('Échec de la récupération des statistiques d\'évolution');
    }
  }

  Future<void> fetchOngoingOrders() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/commandes-en-cours'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        ongoingOrders = data;
      });
    } else {
      throw Exception('Échec de la récupération des commandes en cours');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStatistics();
    fetchOngoingOrders();
    fetchEvolutionData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2d2c2e),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vue d'ensemble",
              style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Color(0xFF2d2c2e),
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  "Utilisateurs actifs",
                  users,
                  Colors.purple,
                ),
                _buildStatCard("Nouveaux inscrits", newUsers, Colors.purple),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard("Produits en ligne", products, Colors.purple),
                _buildStatCard("Commandes Total", totalOrders, Colors.purple),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Commandes en Cours",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ongoingOrders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 95,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          ongoingOrders.length > 4 ? 4 : ongoingOrders.length,
                      itemBuilder: (context, index) {
                        var order = ongoingOrders[index];
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(31, 255, 255, 255),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(66, 5, 5, 5),
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("Commande #${order['id']}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                Text("Total: ${order['total']} €",
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 59, 194, 82))),
                                Text(order['statut'],
                                    style: TextStyle(
                                        color: order['statut'] == 'En cours'
                                            ? Colors.orange
                                            : const Color.fromARGB(
                                                255, 211, 211, 208))),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            const Text(
              "Graphique d'évolution",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: true, border: Border.all()),
                  barGroups: [
                    for (int i = 0; i < evolutionUsersData.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: evolutionUsersData[i].y,
                            color: Colors.blue,
                            width: 10,
                          ),
                        ],
                      ),
                    for (int i = 0; i < evolutionOrdersData.length; i++)
                      BarChartGroupData(
                        x: i + evolutionUsersData.length,
                        barRods: [
                          BarChartRodData(
                            toY: evolutionOrdersData[i].y,
                            color: Colors.green,
                            width: 10,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
