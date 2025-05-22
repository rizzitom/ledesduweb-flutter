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
