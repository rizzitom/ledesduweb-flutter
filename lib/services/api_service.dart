import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; 
  
  static String? _token;
  
  // Headers pour les requêtes
  static Map<String, String> get headers {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // Sauvegarder le token
  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Charger le token
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Supprimer le token
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Vérifier si l'utilisateur est connecté
  static bool get isLoggedIn => _token != null;

  // ============ AUTHENTIFICATION ============

  static Future<Map<String, dynamic>> login(String emailOrUsername, String password) async { // Parameter name changed for clarity
    try {
      // Determine if the input is likely an email
      final bool isEmail = emailOrUsername.contains('@');

      final Map<String, String> payload = {
        'password': password,
      };
      if (isEmail) {
        payload['email'] = emailOrUsername;
      } else {
        payload['username'] = emailOrUsername;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await saveToken(data['token']);
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Erreur de connexion'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  static Future<void> logout() async {
    await clearToken();
  }

  // ============ DASHBOARD ============

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/stats'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Erreur lors du chargement des statistiques');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ============ PRODUITS ============

  static Future<Map<String, dynamic>> getProduits({
    int page = 1,
    int limit = 10,
    String search = '',
    String categorie = '',
  }) async {
    try {
      String url = '$baseUrl/produits?page=$page&limit=$limit';
      if (search.isNotEmpty) url += '&search=$search';
      if (categorie.isNotEmpty) url += '&categorie=$categorie';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Erreur lors du chargement des produits');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Map<String, dynamic>> createProduit(Map<String, dynamic> produitData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/produits'),
        headers: headers,
        body: jsonEncode(produitData),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Erreur lors de la création du produit');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Map<String, dynamic>> updateProduit(int id, Map<String, dynamic> produitData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/produits/$id'),
        headers: headers,
        body: jsonEncode(produitData),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Erreur lors de la mise à jour du produit');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteProduit(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/produits/$id'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Erreur lors de la suppression du produit');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ============ COMMANDES ============

  static Future<Map<String, dynamic>> getCommandes({
    int page = 1,
    int limit = 10,
    String statut = '',
  }) async {
    try {
      String url = '$baseUrl/commandes?page=$page&limit=$limit';
      if (statut.isNotEmpty) url += '&statut=$statut';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Erreur lors du chargement des commandes');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Map<String, dynamic>> getCommandeDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/commandes/$id'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Erreur lors du chargement des détails de la commande');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Map<String, dynamic>> updateCommandeStatut(int id, String statut, {String? notes}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/commandes/$id/statut'),
        headers: headers,
        body: jsonEncode({
          'statut': statut,
          'notes': notes,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Erreur lors de la mise à jour du statut');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ============ CATÉGORIES ============

  static Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Erreur lors du chargement des catégories');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ============ UTILISATEURS ============

  static Future<Map<String, dynamic>> getUtilisateurs({
    int page = 1,
    int limit = 10,
    String role = '',
  }) async {
    try {
      String url = '$baseUrl/utilisateurs?page=$page&limit=$limit';
      if (role.isNotEmpty) url += '&role=$role';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Erreur lors du chargement des utilisateurs');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ============ DEVIS ============

  static Future<List<dynamic>> getDevis() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/devis'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Erreur lors du chargement des devis');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Map<String, dynamic>> updateDevis(int id, String statut, double? montantEstime, String? notesAdmin) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/devis/$id'),
        headers: headers,
        body: jsonEncode({
          'statut': statut,
          'montant_estime': montantEstime,
          'notes_admin': notesAdmin,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Erreur lors de la mise à jour du devis');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}
