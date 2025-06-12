# Application Administration E-commerce LeDesignDuWeb

Une application mobile Flutter complète pour la gestion administrative d'un site e-commerce, avec backend Node.js et base de données MySQL.

## 🚀 Fonctionnalités

### 📱 Application Mobile Flutter
- **Authentification sécurisée** - Connexion administrateur avec JWT
- **Tableau de bord** - Statistiques en temps réel et vue d'ensemble
- **Gestion des produits** - CRUD complet avec recherche et filtres
- **Gestion des commandes** - Suivi et modification des statuts
- **Statistiques avancées** - Graphiques interactifs avec FL Chart
- **Interface moderne** - Design inspiré de ledesignduweb.com

### 🔧 Backend Node.js
- **API RESTful** complète
- **Upload d'images** avec Multer
- **Base de données MySQL** optimisée

## 🛠️ Installation

### Prérequis
- Node.js 16+
- Flutter 3.5+
- MySQL 5.7+
- Base de données DBTom importée

### 1. Installation du backend

```bash
# Installer les dépendances Node.js
npm install

# Configurer la base de données dans .env
cp .env.example .env
# Éditer .env avec vos paramètres MySQL
```

### 2. Installation de l'application Flutter

```bash
# Installer les dépendances Flutter
flutter pub get

# Générer les assets
flutter pub run build_runner build
```

## 🚀 Lancement

### 1. Démarrer le serveur backend

```bash
# Mode développement avec nodemon
npm run dev

# Ou mode production
npm start
```

Le serveur sera disponible sur `http://localhost:3000`

### 2. Lancer l'application Flutter

```bash
# Sur émulateur Android
flutter run

# Sur appareil physique
flutter run --release
```

## 📊 Structure de l'application

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── connexion.dart            # Écran de connexion
├── home_admin.dart           # Tableau de bord principal
├── gestions_produits.dart    # Gestion des produits
├── gestions_commandes.dart   # Gestion des commandes
├── Statistiques.dart         # Écran de statistiques
├── DetailsCommande.dart      # Détails d'une commande
└── services/
    └── api_service.dart      # Service API pour communiquer avec le backend
```

## 🎨 Design & Interface

L'application suit la charte graphique de LeDesignDuWeb avec :
- **Couleurs principales** : Dégradé bleu-violet (#667eea → #764ba2)
- **Composants** : Material Design 3 avec personnalisations
- **Navigation** : Bottom Navigation Bar avec 4 sections

## 📱 Écrans disponibles

### 1. Connexion
- Authentification sécurisée
- Validation des champs
- Gestion des erreurs
- Design moderne avec animations

### 2. Tableau de bord
- Statistiques clés (produits, commandes, clients, CA)
- Commandes récentes
- Actions rapides
- Graphiques de synthèse

### 3. Gestion des produits
- Liste paginée avec recherche
- Filtrage par catégorie
- Création/modification de produits
- Upload d'images
- Gestion du stock et des prix

### 4. Gestion des commandes
- Vue d'ensemble des commandes
- Filtrage par statut
- Modification des statuts
- Détails complets des commandes
- Historique des actions

### 5. Statistiques
- Graphiques interactifs (camembert, courbes, barres)
- Répartition des commandes par statut
- Évolution du chiffre d'affaires
- Top des produits vendus

## 🔐 Sécurité

- **Authentification JWT** avec expiration
- **Validation des entrées** côté client et serveur
- **Rate limiting** pour prévenir les abus
- **Helmet.js** pour sécuriser les headers HTTP
- **CORS** configuré selon l'environnement

## 🗄️ Base de données

L'application utilise la base de données `DBTom` avec les tables :
- `utilisateurs` - Gestion des comptes administrateurs
- `produits` - Catalogue produits
- `categories` - Organisation des produits
- `commandes` - Commandes clients
- `commande_produit` - Détails des commandes
- `factures` - Facturation
- `historique_*` - Traçabilité des actions

## 📞 API Endpoints

### Authentification
- `POST /api/auth/login` - Connexion administrateur

### Dashboard
- `GET /api/dashboard/stats` - Statistiques générales

### Produits
- `GET /api/produits` - Liste des produits (avec pagination)
- `POST /api/produits` - Créer un produit
- `PUT /api/produits/:id` - Modifier un produit
- `DELETE /api/produits/:id` - Supprimer un produit

### Commandes
- `GET /api/commandes` - Liste des commandes
- `GET /api/commandes/:id` - Détails d'une commande
- `PUT /api/commandes/:id/statut` - Modifier le statut

### Autres
- `GET /api/categories` - Liste des catégories
- `GET /api/utilisateurs` - Gestion des utilisateurs
- `GET /api/devis` - Gestion des devis

## 🔧 Configuration

### Variables d'environnement (.env)
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=DBTom
JWT_SECRET=ledesignduweb_secret_key_2025
PORT=3000
```

### Configuration Flutter
Modifier `lib/services/api_service.dart` pour ajuster l'URL de l'API :
```dart
static const String baseUrl = 'http://localhost:3000/api';
// ou pour un appareil physique :
// static const String baseUrl = 'http://10.0.2.2:3000/api';
```

## 🎯 Comptes de test

Utiliser un compte administrateur existant dans la base de données :
- Email : admin@ledesignduweb.com
- Mot de passe : admin123
