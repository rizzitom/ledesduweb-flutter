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
  String Products = '0';
  String totalOrders = '0';
  List<dynamic> ongoingOrders = [];

  Future<void> fetchStatistics() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/statistiques'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        users = data['activeUsers'].toString();
        newUsers = data['newUsers'].toString();
        Products = data['onlineProducts'].toString();
        totalOrders = data['totalOrders'].toString();
      });
    } else {
      throw Exception('Échec de la récupération des statistiques');
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard("Utilisateurs actifs", users, Colors.blue),
                _buildStatCard("Nouveaux inscrits", newUsers, Colors.blue),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard("Produits en ligne", Products, Colors.purple),
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
            const SizedBox(height: 10),
            ongoingOrders.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: ongoingOrders.length,
                      itemBuilder: (context, index) {
                        var order = ongoingOrders[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Commande #${order['id']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Total: ${order['total']}",
                                  style: const TextStyle(color: Colors.purple),
                                ),
                                Text(
                                  order['status'],
                                  style: const TextStyle(color: Colors.green),
                                ),
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
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: false, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 1:
                              return const Text("Jan");
                            case 2:
                              return const Text("Fév");
                            case 3:
                              return const Text("Mar");
                            case 4:
                              return const Text("Avr");
                            case 5:
                              return const Text("Mai");
                            case 6:
                              return const Text("Juin");
                            default:
                              return const Text("");
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(1, 800),
                        FlSpot(2, 1000),
                        FlSpot(3, 750),
                        FlSpot(4, 1250),
                        FlSpot(5, 1500),
                        FlSpot(6, 1700),
                      ],
                      isCurved: true,
                      color: const Color(0xFF6200b3),
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color.fromARGB(255, 78, 76, 76),
                      ),
                    )
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
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
