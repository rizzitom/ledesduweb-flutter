require("dotenv").config();
const express = require("express");
const mysql = require("mysql2");
const bodyParser = require("body-parser");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const rateLimit = require("express-rate-limit");
const validator = require("validator");
const helmet = require("helmet");

const app = express();
const port = process.env.PORT;

const cors = require("cors");
app.use(cors());

app.use(bodyParser.json());
app.use(helmet());

// --------------------------------------------------------------------------------------------------------------------- //

// Limitation des requêtes
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: "Trop de requêtes, veuillez réessayer plus tard.",
});
app.use(limiter);

// Configuration MySQL
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// Connexion à MySQL
db.connect((err) => {
  if (err) {
    console.error("Erreur de connexion à MySQL:", err);
    process.exit(1);
  }
  console.log("Connecté à la base de données MySQL");
});

// --------------------------------------------------------------------------------------------------------------------- //

// Endpoint pour l'inscription
app.post("/utilisateurs", async (req, res) => {
  const { email, username, password, nom, prenom } = req.body;

  if (!email || !username || !password || !nom || !prenom) {
    return res.status(400).send("Tous les champs sont requis.");
  }

  if (!validator.isEmail(email)) {
    return res.status(400).send("Email invalide.");
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const sql = `INSERT INTO utilisateurs (email, username, password, nom, prenom) VALUES (?, ?, ?, ?, ?)`;
    db.query(
      sql,
      [email, username, hashedPassword, nom, prenom],
      (err, result) => {
        if (err) {
          console.error("Erreur lors de l'insertion:", err);
          return res.status(500).send("Erreur interne du serveur.");
        }
        res.status(201).send("Utilisateur enregistré avec succès.");
      }
    );
  } catch (err) {
    console.error("Erreur lors du hachage du mot de passe:", err);
    res.status(500).send("Erreur interne du serveur.");
  }
});

// Endpoint pour la connexion
app.post("/login", async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).send("Identifiant et mot de passe sont requis.");
  }

  const column = validator.isEmail(username) ? "email" : "username";
  const sql = `SELECT * FROM utilisateurs WHERE ${column} = ?`;

  db.query(sql, [username], async (err, results) => {
    if (err) {
      console.error("Erreur lors de la recherche:", err);
      return res.status(500).send("Erreur interne du serveur.");
    }

    if (results.length === 0) {
      return res.status(401).send("Identifiants incorrects.");
    }

    const user = results[0];
    const validPassword = await bcrypt.compare(password, user.password);

    if (!validPassword) {
      return res.status(401).send("Mot de passe incorrect.");
    }

    const token = jwt.sign({ id: user.id, email: user.email }, "passwordKey", {
      expiresIn: "1h",
    });
    const { password: _, ...userWithoutPassword } = user;
    res.status(200).json({
      message: "Connexion réussie.",
      token,
      user: userWithoutPassword,
    });
  });
});

// --------------------------------------------------------------------------------------------------------------------- //

// Gestion des statistiques :

app.get("/statistiques", (req, res) => {
  const stats = {};

  // Utilisateurs actifs
  const activeUsersQuery = "SELECT COUNT(*) AS users FROM utilisateurs";
  db.query(activeUsersQuery, (err, results) => {
    if (err) {
      console.error(
        "Erreur lors de la récupération des utilisateurs actifs :",
        err
      );
      return res.status(500).json({ message: "Erreur interne du serveur." });
    }
    stats.activeUsers = results[0].users; // Changer de active_users à users

    // Nouveaux inscrits (par exemple, dans le mois)
    const newUsersQuery =
      "SELECT COUNT(*) AS new_users FROM utilisateurs WHERE date_inscription > DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)";
    db.query(newUsersQuery, (err, results) => {
      if (err) {
        console.error(
          "Erreur lors de la récupération des nouveaux inscrits :",
          err
        );
        return res.status(500).json({ message: "Erreur interne du serveur." });
      }
      stats.newUsers = results[0].new_users;

      // Produits en ligne
      const onlineProductsQuery = "SELECT COUNT(*) AS products FROM produits";
      db.query(onlineProductsQuery, (err, results) => {
        if (err) {
          console.error(
            "Erreur lors de la récupération des produits en ligne :",
            err
          );
          return res
            .status(500)
            .json({ message: "Erreur interne du serveur." });
        }
        stats.onlineProducts = results[0].products; // Changer de online_products à products

        // Commandes totales
        const totalOrdersQuery =
          "SELECT COUNT(*) AS total_orders FROM commandes";
        db.query(totalOrdersQuery, (err, results) => {
          if (err) {
            console.error(
              "Erreur lors de la récupération des commandes :",
              err
            );
            return res
              .status(500)
              .json({ message: "Erreur interne du serveur." });
          }
          stats.totalOrders = results[0].total_orders;

          res.status(200).json(stats);
        });
      });
    });
  });
});

// --------------------------------------------------------------------------------------------------------------------- //

// Gestion des produtis :

// Endpoint pour ajouter un produit
app.post("/produits", (req, res) => {
  const {
    nom,
    description,
    prix,
    stock,
    categorie,
    marque,
    modele,
    image_url,
  } = req.body;
  if (!nom || !prix || stock === undefined) {
    return res
      .status(400)
      .json({ message: "Les champs nom, prix et stock sont obligatoires." });
  }
  const sql = `INSERT INTO produits (nom, description, prix, stock, categorie, marque, modele, image_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`;
  db.query(
    sql,
    [nom, description, prix, stock, categorie, marque, modele, image_url],
    (err, result) => {
      if (err) {
        console.error("Erreur lors de l'ajout du produit :", err);
        return res.status(500).json({ message: "Erreur interne du serveur." });
      }
      res
        .status(201)
        .json({ message: "Produit ajouté avec succès.", id: result.insertId });
    }
  );
});

// Endpoint pour récupérer tous les produits
app.get("/produits", (req, res) => {
  const sql = "SELECT * FROM produits WHERE est_actif = TRUE";
  db.query(sql, (err, results) => {
    if (err) {
      console.error("Erreur lors de la récupération des produits :", err);
      return res.status(500).json({ message: "Erreur interne du serveur." });
    }
    res.status(200).json(results);
  });
});

// Endpoint pour récupérer un produit par ID
app.get("/produits/:id", (req, res) => {
  const { id } = req.params;
  const sql = "SELECT * FROM produits WHERE id = ?";
  db.query(sql, [id], (err, results) => {
    if (err) {
      console.error("Erreur lors de la récupération du produit :", err);
      return res.status(500).json({ message: "Erreur interne du serveur." });
    }
    if (results.length === 0) {
      return res.status(404).json({ message: "Produit non trouvé." });
    }
    res.status(200).json(results[0]);
  });
});

// Endpoint pour mettre à jour un produit
app.put("/produits/:id", (req, res) => {
  const { id } = req.params;
  const {
    nom,
    description,
    prix,
    stock,
    categorie,
    marque,
    modele,
    image_url,
  } = req.body;
  const sql = `UPDATE produits SET nom=?, description=?, prix=?, stock=?, categorie=?, marque=?, modele=?, image_url=? WHERE id=?`;
  db.query(
    sql,
    [nom, description, prix, stock, categorie, marque, modele, image_url, id],
    (err, result) => {
      if (err) {
        console.error("Erreur lors de la mise à jour du produit :", err);
        return res.status(500).json({ message: "Erreur interne du serveur." });
      }
      res.status(200).json({ message: "Produit mis à jour avec succès." });
    }
  );
});

// Endpoint pour supprimer un produit
app.delete("/produits/:id", (req, res) => {
  const { id } = req.params;
  const sql = "UPDATE produits SET est_actif = FALSE WHERE id = ?";
  db.query(sql, [id], (err, result) => {
    if (err) {
      console.error("Erreur lors de la suppression du produit :", err);
      return res.status(500).json({ message: "Erreur interne du serveur." });
    }
    res.status(200).json({ message: "Produit supprimé avec succès." });
  });
});

// --------------------------------------------------------------------------------------------------------------------- //

// Commandes faites

app.get("/commandes", (req, res) => {
  const query = "SELECT * FROM commandes";

  db.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({
        message: "Erreur lors de la récupération des commandes",
        error: err,
      });
    }
    res.status(200).json(results);
  });
});

// Endpoint pour récupérer les détails d'une commande spécifique
app.get("/commande/:id", (req, res) => {
  const commandeId = req.params.id;
  const query = "SELECT * FROM commandes WHERE id = ?";

  db.query(query, [commandeId], (err, results) => {
    if (err) {
      return res.status(500).json({
        message: "Erreur lors de la récupération de la commande",
        error: err,
      });
    }
    if (results.length === 0) {
      return res.status(404).json({ message: "Commande non trouvée" });
    }
    res.status(200).json(results[0]);
  });
});

// Endpoint pour ajouter une nouvelle commande

// --------------------------------------------------------------------------------------------------------------------- //

// Gestion des erreurs non gérées
app.use((err, req, res, next) => {
  console.error("Erreur non gérée :", err.stack);
  res.status(500).json({ message: "Erreur interne du serveur." });
});

// Démarrage du serveur
app.listen(port, () => {
  console.log(`Serveur API en écoute sur http://localhost:${port}`);
});
