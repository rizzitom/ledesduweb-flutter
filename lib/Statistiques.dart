import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'services/api_service.dart';

class StatistiquesScreen extends StatefulWidget {
  @override
  _StatistiquesScreenState createState() => _StatistiquesScreenState();
}

class _StatistiquesScreenState extends State<StatistiquesScreen> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatistiques();
  }

  Future<void> _loadStatistiques() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await ApiService.getDashboardStats();
      if (!mounted) return;
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'en_attente':
        return Colors.orange;
      case 'validee':
        return Colors.blue;
      case 'en_preparation':
        return Colors.purple;
      case 'expediee':
        return Colors.green;
      case 'livree':
        return const Color(0xFF4CAF50);
      case 'annulee':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'en_attente':
        return 'En attente';
      case 'validee':
        return 'Validée';
      case 'en_preparation':
        return 'En préparation';
      case 'expediee':
        return 'Expédiée';
      case 'livree':
        return 'Livrée';
      case 'annulee':
        return 'Annulée';
      default:
        return status;
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              Icon(
                Icons.trending_up,
                color: Colors.green,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2d3748),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.green[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommandesParStatutChart() {
    if (_dashboardData == null) return Container();
    
    final commandesParStatut = _dashboardData!['commandesParStatut'] as List<dynamic>? ?? [];
    
    if (commandesParStatut.isEmpty) {
      return Container(
        height: 200,
        child: const Center(
          child: Text(
            'Aucune donnée disponible',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    List<PieChartSectionData> sections = commandesParStatut.map((data) {
      final status = data['statut']?.toString() ?? '';
      final countValue = data['count'];
      
      double count = 0.0;
      if (countValue != null) {
        if (countValue is num) {
          count = countValue.toDouble();
        } else {
          count = double.tryParse(countValue.toString()) ?? 0.0;
        }
      }
      
      final color = _getStatusColor(status);
      
      return PieChartSectionData(
        color: color,
        value: count,
        title: '${count.toInt()}',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: commandesParStatut.map((data) {
              final status = data['statut']?.toString() ?? '';
              final countValue = data['count'];
              
              int count = 0;
              if (countValue != null) {
                if (countValue is num) {
                  count = countValue.toInt();
                } else {
                  count = int.tryParse(countValue.toString()) ?? 0;
                }
              }
              
              final color = _getStatusColor(status);
              
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_getStatusText(status)} ($count)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVentesParMoisChart() {
    if (_dashboardData == null) return Container();
    
    final ventesParMois = _dashboardData!['ventesParMois'] as List<dynamic>? ?? [];
    
    if (ventesParMois.isEmpty) {
      return Container(
        height: 200,
        child: const Center(
          child: Text(
            'Aucune donnée disponible',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    List<FlSpot> spots = [];
    List<String> months = [];
    double maxValue = 0.0;
    
    for (int i = 0; i < ventesParMois.length && i < 6; i++) {
      final data = ventesParMois[i];
      final chiffreAffairesValue = data['chiffre_affaires'];
      
      double chiffreAffaires = 0.0;
      if (chiffreAffairesValue != null) {
        if (chiffreAffairesValue is num) {
          chiffreAffaires = chiffreAffairesValue.toDouble();
        } else if (chiffreAffairesValue is String) {
          chiffreAffaires = double.tryParse(chiffreAffairesValue) ?? 0.0;
        }
      }
      
      // S'assurer que la valeur est positive (seulement si c'est un nombre)
      if (chiffreAffaires < 0) {
        chiffreAffaires = -chiffreAffaires;
      }
      
      if (chiffreAffaires > maxValue) {
        maxValue = chiffreAffaires;
      }
      
      spots.add(FlSpot(i.toDouble(), chiffreAffaires));
      
      final mois = data['mois'] as String? ?? '';
      if (mois.isNotEmpty) {
        try {
          final date = DateTime.parse('$mois-01');
          months.add(DateFormat('MMM', 'fr_FR').format(date));
        } catch (e) {
          months.add(mois.length >= 2 ? mois.substring(mois.length - 2) : mois);
        }
      } else {
        months.add('N/A');
      }
    }

    // Si toutes les valeurs sont nulles, afficher un message
    if (maxValue == 0.0) {
      return Container(
        height: 200,
        child: const Center(
          child: Text(
            'Aucune vente enregistrée',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const Text('0€', style: TextStyle(fontSize: 10));
                  return Text(
                    '${(value / 1000).toStringAsFixed(0)}k€',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < months.length) {
                    return Text(
                      months[index],
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: 0,
          maxY: maxValue * 1.1,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF667eea),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFF667eea),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF667eea).withOpacity(0.3),
                    const Color(0xFF667eea).withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProduitsChart() {
    if (_dashboardData == null) return Container();
    
    final topProduits = _dashboardData!['topProduits'] as List<dynamic>? ?? [];
    
    if (topProduits.isEmpty) {
      return Container(
        height: 200,
        child: const Center(
          child: Text(
            'Aucune donnée disponible',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    List<BarChartGroupData> barGroups = [];
    double maxValue = 0.0;
    
    for (int i = 0; i < topProduits.length; i++) {
      final produit = topProduits[i];
      final totalVenduValue = produit['total_vendu'];
      
      double totalVendu = 0.0;
      if (totalVenduValue != null) {
        if (totalVenduValue is num) {
          totalVendu = totalVenduValue.toDouble();
        } else {
          totalVendu = double.tryParse(totalVenduValue.toString()) ?? 0.0;
        }
      }
      
      if (totalVendu > maxValue) {
        maxValue = totalVendu;
      }
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: totalVendu,
              color: const Color(0xFF667eea),
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue > 0 ? maxValue * 1.2 : 100,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < topProduits.length) {
                    final nom = topProduits[index]['nom']?.toString() ?? '';
                    return Text(
                      nom.length > 10 ? '${nom.substring(0, 10)}...' : nom,
                      style: const TextStyle(fontSize: 8),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          barGroups: barGroups,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Statistiques',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
          ),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Statistiques',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
          ),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadStatistiques,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final stats = _dashboardData?['stats'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistiques',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _loadStatistiques,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStatistiques,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bar_chart,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statistiques détaillées',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Analyse des performances',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Cartes de statistiques principales
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    title: 'Produits actifs',
                    value: stats?['totalProduits']?.toString() ?? '0',
                    icon: Icons.inventory,
                    color: const Color(0xFF4CAF50),
                    subtitle: '+2% ce mois',
                  ),
                  _buildStatCard(
                    title: 'Total commandes',
                    value: stats?['totalCommandes']?.toString() ?? '0',
                    icon: Icons.shopping_cart,
                    color: const Color(0xFF2196F3),
                    subtitle: '+5% ce mois',
                  ),
                  _buildStatCard(
                    title: 'Clients inscrits',
                    value: stats?['totalClients']?.toString() ?? '0',
                    icon: Icons.people,
                    color: const Color(0xFF9C27B0),
                    subtitle: '+3% ce mois',
                  ),
                  _buildStatCard(
                    title: 'Chiffre d\'affaires',
                    value: () {
                      final chiffreAffairesValue = stats?['chiffreAffaires'];
                      double chiffreAffaires = 0.0;
                      
                      if (chiffreAffairesValue != null) {
                        if (chiffreAffairesValue is num) {
                          chiffreAffaires = chiffreAffairesValue.toDouble();
                        } else {
                          chiffreAffaires = double.tryParse(chiffreAffairesValue.toString()) ?? 0.0;
                        }
                      }
                      
                      return NumberFormat.compactCurrency(locale: 'fr_FR', symbol: '€').format(chiffreAffaires);
                    }(),
                    icon: Icons.euro,
                    color: const Color(0xFFFF9800),
                    subtitle: '+8% ce mois',
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Graphique répartition des commandes par statut
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Répartition des commandes par statut',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2d3748),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCommandesParStatutChart(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Graphique évolution des ventes
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Évolution du chiffre d\'affaires',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2d3748),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildVentesParMoisChart(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Graphique top produits
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Produits les plus vendus',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2d3748),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTopProduitsChart(),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Espace pour la bottom navigation
            ],
          ),
        ),
      ),
    );
  }
}
