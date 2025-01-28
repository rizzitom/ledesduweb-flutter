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

app.use(bodyParser.json());
app.use(helmet());

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

// Gestion des erreurs non gérées
app.use((err, req, res, next) => {
  console.error("Erreur non gérée :", err.stack);
  res.status(500).json({ message: "Erreur interne du serveur." });
});

// Démarrage du serveur
app.listen(port, () => {
  console.log(`Serveur API en écoute sur http://localhost:${port}`);
});
