import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'services/api_service.dart';

class GestionProduitsScreen extends StatefulWidget {
  @override
  _GestionProduitsScreenState createState() => _GestionProduitsScreenState();
}

class _GestionProduitsScreenState extends State<GestionProduitsScreen> {
  List<dynamic> _produits = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  String _selectedCategory = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadProduits(),
      _loadCategories(),
    ]);
  }

  Future<void> _loadProduits({bool reset = false}) async {
    if (reset) {
      setState(() {
        _currentPage = 1;
        _produits.clear();
      });
    }

    try {
      setState(() {
        if (reset) _isLoading = true;
        _error = null;
      });

      final data = await ApiService.getProduits(
        page: _currentPage,
        search: _searchQuery,
        categorie: _selectedCategory,
      );

      setState(() {
        if (reset) {
          _produits = data['produits'];
        } else {
          _produits.addAll(data['produits']);
        }
        _totalPages = data['pagination']['pages'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Erreur chargement catégories: $e');
    }
  }

  Future<void> _deleteProduit(int id) async {
    try {
      await ApiService.deleteProduit(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produit supprimé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      _loadProduits(reset: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(Map<String, dynamic> produit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer le produit'),
          content:
              Text('Êtes-vous sûr de vouloir supprimer "${produit['nom']}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduit(produit['id']);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showProduitDialog({Map<String, dynamic>? produit}) {
    final isEdit = produit != null;
    final formKey = GlobalKey<FormState>();

    final nomController = TextEditingController(text: produit?['nom'] ?? '');
    final descriptionController =
        TextEditingController(text: produit?['description'] ?? '');
    final descriptionCourteController =
        TextEditingController(text: produit?['description_courte'] ?? '');
    final prixController =
        TextEditingController(text: produit?['prix']?.toString() ?? '');
    final prixPromoController =
        TextEditingController(text: produit?['prix_promo']?.toString() ?? '');
    final stockController =
        TextEditingController(text: produit?['stock']?.toString() ?? '');

    int selectedCategoryId = produit?['id_categorie'] ??
        (_categories.isNotEmpty ? _categories.first['id'] : 1);
    bool estActif = produit?['est_actif'] == 1 || produit == null;
    bool estFeatured = produit?['est_featured'] == 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Modifier le produit' : 'Nouveau produit'),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nomController,
                          decoration: const InputDecoration(
                            labelText: 'Nom du produit',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir un nom';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionCourteController,
                          decoration: const InputDecoration(
                            labelText: 'Description courte',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description détaillée',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: prixController,
                                decoration: const InputDecoration(
                                  labelText: 'Prix (€)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Prix requis';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Prix invalide';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: prixPromoController,
                                decoration: const InputDecoration(
                                  labelText: 'Prix promo (€)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: stockController,
                          decoration: const InputDecoration(
                            labelText: 'Stock',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Stock requis';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Stock invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Catégorie',
                            border: OutlineInputBorder(),
                          ),
                          items: _categories
                              .map<DropdownMenuItem<int>>((category) {
                            return DropdownMenuItem<int>(
                              value: category['id'],
                              child: Text(category['nom']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedCategoryId = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: const Text('Actif'),
                                value: estActif,
                                onChanged: (value) {
                                  setDialogState(() {
                                    estActif = value ?? false;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                title: const Text('Mis en avant'),
                                value: estFeatured,
                                onChanged: (value) {
                                  setDialogState(() {
                                    estFeatured = value ?? false;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        final produitData = {
                          'nom': nomController.text,
                          'description': descriptionController.text,
                          'description_courte':
                              descriptionCourteController.text,
                          'prix': double.parse(prixController.text),
                          'prix_promo': prixPromoController.text.isNotEmpty
                              ? double.parse(prixPromoController.text)
                              : null,
                          'stock': int.parse(stockController.text),
                          'id_categorie': selectedCategoryId,
                          'est_actif': estActif,
                          'est_featured': estFeatured,
                        };

                        if (isEdit) {
                          await ApiService.updateProduit(
                              produit['id'], produitData);
                        } else {
                          await ApiService.createProduit(produitData);
                        }

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEdit
                                ? 'Produit modifié avec succès'
                                : 'Produit créé avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _loadProduits(reset: true);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(isEdit ? 'Modifier' : 'Créer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _performSearch() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _loadProduits(reset: true);
  }

  // Helper method to safely parse numeric values that might come as strings
  double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Widget _buildProduitCard(Map<String, dynamic> produit) {
    // Safely convert prix_promo to double for comparison
    double? prixPromo;
    if (produit['prix_promo'] != null) {
      if (produit['prix_promo'] is String) {
        prixPromo = double.tryParse(produit['prix_promo']);
      } else if (produit['prix_promo'] is num) {
        prixPromo = produit['prix_promo'].toDouble();
      }
    }
    final hasPromo = prixPromo != null && prixPromo > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image du produit
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: produit['image_url'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl:
                                'http://10.0.2.2:3000${produit['image_url']}',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 40,
                        ),
                ),

                const SizedBox(width: 16),

                // Informations du produit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              produit['nom'] ?? 'Nom non disponible',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (produit['est_featured'] == 1)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'VEDETTE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        produit['categorie_nom'] ?? 'Catégorie inconnue',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Prix
                      Row(
                        children: [
                          if (hasPromo) ...[
                            Text(
                              '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(prixPromo!)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(_safeParseDouble(produit['prix']))}',
                              style: const TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          ] else ...[
                            Text(
                              '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(_safeParseDouble(produit['prix']))}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Stock et statut
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: produit['stock'] > 0
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Stock: ${produit['stock']}',
                              style: TextStyle(
                                color: produit['stock'] > 0
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: produit['est_actif'] == 1
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              produit['est_actif'] == 1 ? 'ACTIF' : 'INACTIF',
                              style: TextStyle(
                                color: produit['est_actif'] == 1
                                    ? Colors.blue[700]
                                    : Colors.grey[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showProduitDialog(produit: produit),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Modifier'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showDeleteDialog(produit),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Supprimer'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestion des produits',
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
          // Barre de recherche et filtres
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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un produit...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _performSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Filtre par catégorie
                if (_categories.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedCategory.isEmpty ? null : _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Filtrer par catégorie',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Toutes les catégories'),
                      ),
                      ..._categories.map<DropdownMenuItem<String>>((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'].toString(),
                          child: Text(category['nom']),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value ?? '';
                      });
                      _loadProduits(reset: true);
                    },
                  ),
              ],
            ),
          ),

          // Liste des produits
          Expanded(
            child: _isLoading && _produits.isEmpty
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
                              onPressed: () => _loadProduits(reset: true),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : _produits.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Aucun produit trouvé',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _produits.length,
                            itemBuilder: (context, index) {
                              return _buildProduitCard(_produits[index]);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProduitDialog(),
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
