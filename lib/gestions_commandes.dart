import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api_service.dart';

class GestionCommandesScreen extends StatefulWidget {
  @override
  _GestionCommandesScreenState createState() => _GestionCommandesScreenState();
}

class _GestionCommandesScreenState extends State<GestionCommandesScreen> {
  List<dynamic> _commandes = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  String _selectedStatut = '';

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  Future<void> _loadCommandes({bool reset = false}) async {
    if (reset) {
      if (!mounted) return;
      setState(() {
        _currentPage = 1;
        _commandes.clear();
      });
    }

    try {
      if (!mounted) return;
      setState(() {
        if (reset) _isLoading = true;
        _error = null;
      });

      final data = await ApiService.getCommandes(
        page: _currentPage,
        statut: _selectedStatut,
      );

      if (!mounted) return;
      setState(() {
        if (reset) {
          _commandes = data['commandes'];
        } else {
          _commandes.addAll(data['commandes']);
        }
        _totalPages = data['pagination']['pages'];
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

  Future<void> _updateStatut(int commandeId, String nouveauStatut) async {
    try {
      await ApiService.updateCommandeStatut(commandeId, nouveauStatut);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Statut mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      _loadCommandes(reset: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStatutDialog(Map<String, dynamic> commande) {
    String statutSelectionne = commande['statut'];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Modifier le statut - ${commande['reference']}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: statutSelectionne,
                    decoration: const InputDecoration(
                      labelText: 'Nouveau statut',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'en_attente',
                      'validee',
                      'en_preparation',
                      'expediee',
                      'livree',
                      'annulee'
                    ].map<DropdownMenuItem<String>>((statut) {
                      return DropdownMenuItem<String>(
                        value: statut,
                        child: Text(_getStatusText(statut)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          statutSelectionne = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _updateStatut(commande['id'], statutSelectionne);
                  },
                  child: const Text('Mettre à jour'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCommandeDetails(Map<String, dynamic> commande) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsCommandeScreen(commandeId: commande['id']),
      ),
    );
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

  Widget _buildCommandeCard(Map<String, dynamic> commande) {
    final statusColor = _getStatusColor(commande['statut']);
    final statusText = _getStatusText(commande['statut']);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showCommandeDetails(commande),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    commande['reference'] ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      commande['client_nom'] ?? 'Client inconnu',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      commande['client_email'] ?? 'Email non disponible',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM/yyyy à HH:mm').format(
                      DateTime.parse(commande['date_commande']),
                    ),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(double.tryParse(commande['montant_total'].toString()) ?? 0.0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF2d3748),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showStatutDialog(commande),
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        tooltip: 'Modifier le statut',
                      ),
                      IconButton(
                        onPressed: () => _showCommandeDetails(commande),
                        icon: Icon(
                          Icons.visibility,
                          color: Colors.green[600],
                          size: 20,
                        ),
                        tooltip: 'Voir les détails',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestion des commandes',
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
      body: Column(
        children: [
          // Filtre par statut
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedStatut.isEmpty ? null : _selectedStatut,
              decoration: InputDecoration(
                labelText: 'Filtrer par statut',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Tous les statuts'),
                ),
                ...['en_attente', 'validee', 'en_preparation', 'expediee', 'livree', 'annulee']
                    .map<DropdownMenuItem<String>>((statut) {
                  return DropdownMenuItem<String>(
                    value: statut,
                    child: Text(_getStatusText(statut)),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatut = value ?? '';
                });
                _loadCommandes(reset: true);
              },
            ),
          ),
          
          // Liste des commandes
          Expanded(
            child: _isLoading && _commandes.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
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
                              onPressed: () => _loadCommandes(reset: true),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : _commandes.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Aucune commande trouvée',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _loadCommandes(reset: true),
                            child: ListView.builder(
                              itemCount: _commandes.length,
                              itemBuilder: (context, index) {
                                return _buildCommandeCard(_commandes[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// Écran de détails d'une commande
class DetailsCommandeScreen extends StatefulWidget {
  final int commandeId;

  const DetailsCommandeScreen({Key? key, required this.commandeId}) : super(key: key);

  @override
  _DetailsCommandeScreenState createState() => _DetailsCommandeScreenState();
}

class _DetailsCommandeScreenState extends State<DetailsCommandeScreen> {
  Map<String, dynamic>? _commandeDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCommandeDetails();
  }

  Future<void> _loadCommandeDetails() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await ApiService.getCommandeDetails(widget.commandeId);
      if (!mounted) return;
      setState(() {
        _commandeDetails = data;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails de la commande'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _commandeDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails de la commande'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Erreur de chargement',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCommandeDetails,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final commande = _commandeDetails!['commande'];
    final produits = _commandeDetails!['produits'] ?? [];
    final historique = _commandeDetails!['historique'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Commande ${commande['reference']}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations générales
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Informations générales',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(commande['statut']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(commande['statut']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: 8),
                        Text('Client: ${commande['client_nom']}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 16),
                        const SizedBox(width: 8),
                        Text('Email: ${commande['client_email']}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Date: ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.parse(commande['date_commande']))}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.euro, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Montant: ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(double.tryParse(commande['montant_total'].toString()) ?? 0.0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Produits commandés
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Produits commandés',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...produits.map<Widget>((produit) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    produit['produit_nom'],
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'Quantité: ${produit['quantite']}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(double.tryParse(produit['prix_unitaire'].toString()) ?? 0.0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Adresse de livraison
            if (commande['adresse_livraison'] != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adresse de livraison',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(commande['adresse_livraison']),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
