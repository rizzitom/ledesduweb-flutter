#ledesignduweb

# 📦 **Application de Gestion Administrative pour Sites E-commerce**

Cette application permet de gérer efficacement un site e-commerce en centralisant les commandes, produits et analyses statistiques. Elle est conçue pour optimiser l'expérience administrative et faciliter la gestion des tâches quotidiennes.

---

## 🚀 **Fonctionnalités Actuelles :**

- **Gestion des commandes**  
  Suivi en temps réel des commandes, gestion des statuts et des expéditions.

- **Gestion des produits**  
  Ajout, modification, suppression et organisation des produits.

- **Analyse et statistiques**  
  Visualisation des performances via des graphiques et tableaux pour un suivi optimal.

---

## 🔮 **À venir :**

- **Nouvelles fonctionnalités**  
  Des options avancées de reporting, gestion des utilisateurs, et bien plus !

---

## 🛠️ **Technologies utilisées :**

- Flutter
- Javascript
- NodeJS
- MySQL

---

## 📜 **Installation :**

## Instructions d'Installation et de Lancement

Ces instructions vous guideront pour cloner le projet, installer les dépendances et lancer l'application sur votre environnement de développement.

### 1. Prérequis

Avant de commencer, assurez-vous d'avoir installé les outils suivants sur votre machine :

* **Git :** Pour cloner le dépôt. ([Télécharger Git](https://git-scm.com/))
* **Flutter SDK (dernière version stable recommandée) :** Le kit de développement Flutter. ([Instructions d'installation Flutter](https://flutter.dev/docs/get-started/install))
    * Vérifiez que la commande `flutter` est accessible depuis votre terminal (exécutez `flutter doctor`).
* **Un IDE configuré pour Flutter :**
    * [Visual Studio Code](https://code.visualstudio.com/) avec l'extension [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter).
    * Ou [Android Studio](https://developer.android.com/studio) avec le plugin Flutter.
* **Un émulateur/simulateur ou un appareil physique :**
    * Pour Android : Un AVD (Android Virtual Device) créé via Android Studio.
    * Pour iOS : Xcode et un simulateur iOS, ou un appareil physique (nécessite un Mac).

### 2. Étapes d'Installation et de Lancement

1.  **Cloner le dépôt GitHub :**
    Ouvrez un terminal et exécutez la commande suivante dans le répertoire de votre choix :
    ```bash
    git clone [https://github.com/rizzitom/LDDW-Flutter.git](https://github.com/rizzitom/LDDW-Flutter.git)
    ```

2.  **Accéder au répertoire du projet :**
    Naviguez dans le dossier du projet nouvellement cloné :
    ```bash
    cd LDDW-Flutter
    ```

3.  **Installer les dépendances du projet :**
    Cette commande télécharge tous les packages Dart et Flutter requis par le projet (définis dans `pubspec.yaml`) :
    ```bash
    flutter pub get
    ```

4.  **Configuration de l'environnement (si applicable) :**
    * Certains projets peuvent nécessiter la configuration de variables d'environnement ou de fichiers de configuration spécifiques (par exemple, pour l'URL de l'API, des clés API, etc.).
    * Vérifiez la présence de fichiers `.env.example` ou `config.dart.example` et suivez les instructions qu'ils pourraient contenir pour créer vos propres fichiers de configuration (`.env` ou `config.dart`).
    * **Important :** L'URL de l'API REST doit être correctement configurée dans le code source de l'application pour qu'elle puisse communiquer avec le backend.

5.  **Préparation du backend (API REST et MySQL) :**
    Cette application mobile interagit avec une API REST (NodeJS) connectée à une base de données MySQL. **Le backend doit être opérationnel et accessible pour que l'application fonctionne pleinement.**
    * Assurez-vous que votre serveur API REST est démarré.
    * Vérifiez que votre instance MySQL est en cours d'exécution et accessible par l'API.
    * Si vous testez avec un émulateur Android, l'adresse `localhost` de votre machine de développement est généralement accessible via `10.0.2.2` depuis l'émulateur. Pour un simulateur iOS, `localhost` ou `127.0.0.1` devrait fonctionner directement.

6.  **Vérifier la configuration de l'environnement Flutter :**
    Exécutez cette commande pour diagnostiquer et résoudre les problèmes de configuration de votre environnement Flutter :
    ```bash
    flutter doctor
    ```
    Suivez les recommandations fournies par `flutter doctor` pour corriger d'éventuels soucis.

7.  **Sélectionner un appareil cible :**
    * Lancez un émulateur Android, un simulateur iOS, ou connectez un appareil physique (avec le mode développeur et le débogage USB activés).
    * Dans votre IDE (VS Code ou Android Studio), sélectionnez l'appareil cible sur lequel vous souhaitez exécuter l'application. Vous pouvez aussi lister les appareils connectés avec :
        ```bash
        flutter devices
        ```

8.  **Lancer l'application :**
    Une fois l'appareil cible prêt et sélectionné, lancez l'application en utilisant :
    ```bash
    flutter run
    ```
    Vous pouvez également lancer l'application directement depuis les options "Run" ou "Debug" de votre IDE.



```mermaid
erDiagram
    utilisateurs {
        INT id PK
        VARCHAR email "UNIQUE"
        VARCHAR username
        VARCHAR password
        VARCHAR nom
        VARCHAR prenom
        TEXT adresse
        VARCHAR code_postal
        VARCHAR ville
        VARCHAR telephone
        INT idRole FK
        TIMESTAMP date_inscription
        TIMESTAMP derniere_connexion
        VARCHAR two_factor_secret
        BOOLEAN two_factor_enabled
        VARCHAR backup_code
        BOOLEAN notif_new_connexion
        BOOLEAN notif_password_change
        BOOLEAN notif_failed_attempts
        BOOLEAN remember_devices
        BOOLEAN extended_session
        BOOLEAN confirm_order_by_email
        INT points_fidelite
        VARCHAR profile_picture
    }

    roles {
        INT id PK
        VARCHAR libelle
        TIMESTAMP created_at
    }

    adresses {
        INT id PK
        INT id_utilisateur FK
        VARCHAR nom_adresse
        VARCHAR type_adresse
        VARCHAR nom_complet
        VARCHAR rue
        VARCHAR complement
        VARCHAR code_postal
        VARCHAR ville
        VARCHAR pays
        VARCHAR telephone
        BOOLEAN is_default
        TIMESTAMP date_creation
        TIMESTAMP date_modification
    }

    categories {
        INT id PK
        VARCHAR nom
        TEXT description
        INT parent_id FK "Référence à categories.id (auto-référence)"
        VARCHAR image_url
        BOOLEAN est_actif
        VARCHAR slug "UNIQUE"
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    produits {
        INT id PK
        VARCHAR nom
        TEXT description
        VARCHAR description_courte
        DECIMAL prix
        DECIMAL prix_promo
        INT stock
        INT id_categorie FK
        VARCHAR image_url
        TEXT images_supplementaires
        TEXT caracteristiques
        BOOLEAN est_actif
        BOOLEAN est_featured
        VARCHAR slug "UNIQUE"
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    commandes {
        INT id PK
        INT id_utilisateur FK
        TIMESTAMP date_commande
        ENUM_statut statut "('en_attente','validee','en_preparation','expediee','livree','annulee')"
        DECIMAL montant_total
        DECIMAL frais_livraison
        DECIMAL tva
        VARCHAR pays_livraison
        VARCHAR mode_livraison
        VARCHAR point_relais_id
        VARCHAR point_relais_nom
        TEXT instructions_livraison
        TEXT adresse_livraison
        TEXT adresse_facturation
        VARCHAR methode_paiement
        VARCHAR reference "UNIQUE"
        TEXT notes
        VARCHAR motif_annulation
        TEXT commentaire_annulation
        INT note_client
        TEXT commentaire_client
    }

    commande_produit {
        INT id PK
        INT id_commande FK
        INT id_produit FK
        INT quantite
        DECIMAL prix_unitaire
    }

    factures {
        INT id PK
        INT id_commande FK
        VARCHAR numero_facture
        DATETIME date_emission
        DECIMAL montant_ht
        DECIMAL montant_tva
        DECIMAL montant_ttc
        TIMESTAMP date_creation
    }

    paiements {
        INT id PK
        INT id_commande FK
        VARCHAR payment_intent_id
        VARCHAR statut
        DECIMAL montant
        TEXT details
        DATETIME date_paiement
    }

    historique_commande {
        INT id PK
        INT id_commande FK
        INT id_utilisateur FK
        VARCHAR action
        TEXT details
        TIMESTAMP date_action
    }

    services {
        INT id PK
        VARCHAR nom
        TEXT description
        DECIMAL prix_base
        VARCHAR image_url
        BOOLEAN est_actif
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    devis {
        INT id PK
        INT id_utilisateur FK
        INT id_service FK
        TEXT description_demande
        ENUM_statut statut "('en_attente','en_cours','termine','rejete')"
        TIMESTAMP date_demande
        TIMESTAMP date_reponse
        DECIMAL montant_estime
        TEXT notes_admin
    }

    conversations {
        INT id PK
        INT id_utilisateur FK
        VARCHAR sujet
        ENUM_type type "('general','commande','devis','support')"
        INT reference_commande FK "Nullable"
        INT reference_devis FK "Nullable"
        ENUM_statut statut "('ouvert','en_attente','resolu','ferme')"
        TIMESTAMP date_creation
        TIMESTAMP date_derniere_activite
    }

    messages {
        INT id PK
        INT id_conversation FK
        INT id_utilisateur FK
        TEXT contenu
        BOOLEAN is_client
        BOOLEAN lu
        TIMESTAMP date_creation
    }

    pieces_jointes {
        INT id PK
        INT id_message FK
        INT id_conversation FK
        VARCHAR nom_fichier
        VARCHAR chemin_fichier
        TIMESTAMP date_creation
    }

    panier {
        INT id PK
        INT id_utilisateur FK
        INT id_produit FK
        INT quantite
        DATETIME date_ajout
        DATETIME date_modification
    }

    panier_temp {
        INT id PK
        VARCHAR session_id
        INT id_produit FK
        INT quantite
        DATETIME date_ajout
        DATETIME date_modification
    }

    historique_actions {
        INT id PK
        INT id_utilisateur FK
        VARCHAR type_action
        TEXT details
        TIMESTAMP date_action
    }

    historique_connexions {
        INT id PK
        INT id_utilisateur FK
        VARCHAR ip
        TEXT user_agent
        BOOLEAN succes
        TIMESTAMP date_connexion
    }

    sessions {
        INT id PK
        INT id_utilisateur FK
        VARCHAR session_token
        TEXT user_agent
        VARCHAR ip
        TIMESTAMP last_activity
    }

    utilisateurs ||--o{ adresses : "possède"
    utilisateurs ||--o{ commandes : "passe"
    utilisateurs ||--o{ devis : "demande"
    utilisateurs ||--o{ conversations : "participe à"
    utilisateurs ||--o{ messages : "envoie/reçoit"
    utilisateurs ||--o{ panier : "a un"
    utilisateurs ||--o{ historique_actions : "effectue"
    utilisateurs ||--o{ historique_connexions : "a des"
    utilisateurs ||--o{ sessions : "a des"
    utilisateurs ||--o{ historique_commande : "est concerné par"
    roles ||--o{ utilisateurs : "est assigné à"

    categories ||--o{ produits : "contient"
    categories }o--|| categories : "est sous-catégorie de (parent_id)"

    produits ||--o{ commande_produit : "est dans"
    produits ||--o{ panier : "contient"
    produits ||--o{ panier_temp : "contient"

    commandes ||--o{ commande_produit : "liste"
    commandes ||--o{ factures : "a pour"
    commandes ||--o{ paiements : "est payée via"
    commandes ||--o{ historique_commande : "a un"
    commandes ||--o{ conversations : "peut être référencée dans"

    services ||--o{ devis : "est pour"
    devis    ||--o{ conversations : "peut être référencée dans"

    conversations ||--o{ messages : "contient"
    conversations ||--o{ pieces_jointes : "contient"
    messages      ||--o{ pieces_jointes : "a des"





graph TD
    subgraph Tier_1 [Tier 1 : Client Mobile]
        A[<img src="https://img.icons8.com/color/48/000000/flutter.png" width="40" /><br>Application LDW Admin<br>(Flutter/Dart)]
    end

    subgraph Tier_2_3 [Tier 2 & 3 : Backend]
        B{<img src="https://img.icons8.com/fluency/48/000000/node-js.png" width="35" /><br>API REST & Serveur de Logique Métier<br>(NodeJS)}
    end

    subgraph Tier_4 [Tier 4 : Données]
        C[<img src="https://img.icons8.com/color/48/000000/mysql-logo.png" width="40" /><br>Base de Données<br>(MySQL - DBTom)]
    end

    A -- Requêtes HTTPS (JSON) --> B;
    B -- Réponses HTTPS (JSON) --> A;
    B -- Requêtes SQL / ORM --> C;
    C -- Données --> B;

    style Tier_1 fill:#ECEFF1,stroke:#607D8B
    style Tier_2_3 fill:#E3F2FD,stroke:#2196F3
    style Tier_4 fill:#E8F5E9,stroke:#4CAF50
