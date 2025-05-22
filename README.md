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

### Résumé des Commandes Principales
`bash
# Cloner le dépôt
git clone [https://github.com/rizzitom/LDDW-Flutter.git](https://github.com/rizzitom/LDDW-Flutter.git)

# Accéder au répertoire
cd LDDW-Flutter

# Installer les dépendances
flutter pub get

# (Assurez-vous que le backend est démarré et configuré)
# (Assurez-vous qu'un émulateur/appareil est prêt)

# Lancer l'application
flutter run


mermaid
graph TD
    subgraph "Utilisateur"
        A[<img src="[https://img.icons8.com/ios-glyphs/50/000000/user-male-circle.png](https://img.icons8.com/ios-glyphs/50/000000/user-male-circle.png)" width="40" /><br>Administrateur]
    end
    subgraph "Frontend"
        B[<img src="[https://img.icons8.com/color/48/000000/flutter.png](https://img.icons8.com/color/48/000000/flutter.png)" width="40" /><br>Application Mobile<br>(Flutter / Dart)]
    end
    subgraph "Backend"
        C{<img src="[https://img.icons8.com/fluency/48/000000/node-js.png](https://img.icons8.com/fluency/48/000000/node-js.png)" width="35" /><br>API REST<br>(NodeJS)}
        D[<img src="[https://img.icons8.com/color/48/000000/mysql-logo.png](https://img.icons8.com/color/48/000000/mysql-logo.png)" width="40" /><br>Base de Données<br>(MySQL)]
    end
    A -- Interaction --> B
    B -- Requêtes HTTP <br> (GET, POST, PUT, DELETE) --> C
    C -- Réponses HTTP <br> (JSON) --> B
    C -- Requêtes SQL <br> (SELECT, INSERT, UPDATE, DELETE) --> D
    D -- Données Brutes --> C
    %% Styles (optionnel, pour améliorer l'apparence si supporté)
    style A fill:#f4f4f4,stroke:#333,stroke-width:2px,color:#333
    style B fill:#D6EAF8,stroke:#2980B9,stroke-width:2px,color:#000
    style C fill:#D5F5E3,stroke:#2ECC71,stroke-width:2px,color:#000
    style D fill:#FCF3CF,stroke:#F1C40F,stroke-width:2px,color:#000
