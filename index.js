const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const path = require('path');
const multer = require('multer');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware de sécurité
app.use(helmet({
  contentSecurityPolicy: false,
  crossOriginEmbedderPolicy: false
}));

// Limitation du taux de requêtes
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 1000,
  message: 'Trop de requêtes depuis cette IP'
});
app.use(limiter);

app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(express.static('public'));

// Configuration de la base de données
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'ldw',
  charset: 'utf8mb4'
};

// Fonction pour créer une connexion à la base de données
async function createConnection() {
  try {
    const connection = await mysql.createConnection(dbConfig);
    return connection;
  } catch (error) {
    console.error('Erreur de connexion à la base de données:', error);
    throw error;
  }
}

// Middleware d'authentification
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Token d\'accès requis' });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'secret_key', (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Token invalide' });
    }
    req.user = user;
    next();
  });
};

// Middleware pour vérifier les droits admin
const requireAdmin = (req, res, next) => {
  if (req.user.idRole !== 1) {
    return res.status(403).json({ error: 'Accès administrateur requis' });
  }
  next();
};

// Configuration multer pour l'upload d'images
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'public/images/uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Seules les images sont autorisées'));
    }
  }
});

// ============ ROUTES D'AUTHENTIFICATION ============

/**
 * Connexion admin : accepte email OU username
 */
app.post('/api/auth/login', async (req, res) => {
  console.log('--- LOGIN ATTEMPT ---');
  console.log('Request body:', req.body);
  
  try {
    const { email, username, password } = req.body;
    
    // Vérifier que le mot de passe est fourni
    if (!password) {
      return res.status(400).json({ 
        success: false, 
        error: 'Mot de passe requis' 
      });
    }
    
    // Vérifier qu'au moins un identifiant est fourni
    if (!email && !username) {
      return res.status(400).json({ 
        success: false, 
        error: 'Email ou nom d\'utilisateur requis' 
      });
    }
    
    const connection = await createConnection();
    
    // Construire la requête selon l'identifiant fourni
    let query;
    let params;
    
    if (email) {
      query = 'SELECT * FROM utilisateurs WHERE email = ?';
      params = [email];
      console.log('Searching by email:', email);
    } else {
      query = 'SELECT * FROM utilisateurs WHERE username = ?';
      params = [username];
      console.log('Searching by username:', username);
    }
    
    const [users] = await connection.execute(query, params);
    
    if (users.length === 0) {
      await connection.end();
      console.log('User not found');
      return res.status(401).json({ 
        success: false, 
        error: 'Identifiants invalides' 
      });
    }
    
    const user = users[0];
    console.log('User found:', user.email, 'Role:', user.idRole);
    
    // Vérifier le mot de passe
    const validPassword = await bcrypt.compare(password, user.password);
    
    if (!validPassword) {
      await connection.end();
      console.log('Invalid password');
      return res.status(401).json({ 
        success: false, 
        error: 'Identifiants invalides' 
      });
    }
    
    // Vérifier que l'utilisateur est admin (role 1)
    if (user.idRole !== 1) {
      await connection.end();
      console.log('User is not admin, role:', user.idRole);
      return res.status(403).json({ 
        success: false, 
        error: 'Accès administrateur requis' 
      });
    }
    
    // Mettre à jour la dernière connexion
    await connection.execute(
      'UPDATE utilisateurs SET derniere_connexion = NOW() WHERE id = ?',
      [user.id]
    );
    
    // Enregistrer dans l'historique des connexions
    await connection.execute(`
      INSERT INTO historique_connexions (id_utilisateur, ip, user_agent, succes)
      VALUES (?, ?, ?, ?)
    `, [user.id, req.ip || 'unknown', req.get('User-Agent') || 'unknown', 1]);
    
    await connection.end();
    
    // Générer le token JWT
    const token = jwt.sign(
      { 
        id: user.id, 
        email: user.email, 
        username: user.username,
        idRole: user.idRole,
        nom: user.nom,
        prenom: user.prenom
      },
      process.env.JWT_SECRET || 'secret_key',
      { expiresIn: '24h' }
    );
    
    console.log('Login successful for user:', user.email);
    
    res.json({
      success: true,
      message: 'Connexion réussie',
      token,
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        nom: user.nom,
        prenom: user.prenom,
        idRole: user.idRole
      }
    });
    
  } catch (error) {
    console.error('❌ Error in login:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Erreur serveur lors de la connexion' 
    });
  }
});

// ============ ROUTES DASHBOARD ============

// Statistiques du tableau de bord
app.get('/api/dashboard/stats', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const connection = await createConnection();
    
    // Statistiques générales
    const [totalProduits] = await connection.execute('SELECT COUNT(*) as count FROM produits WHERE est_actif = 1');
    const [totalCommandes] = await connection.execute('SELECT COUNT(*) as count FROM commandes');
    const [totalClients] = await connection.execute('SELECT COUNT(*) as count FROM utilisateurs WHERE idRole = 2');
    const [chiffreAffaires] = await connection.execute('SELECT SUM(montant_total) as total FROM commandes WHERE statut != "annulee"');
    
    // Commandes par statut
    const [commandesParStatut] = await connection.execute(`
      SELECT statut, COUNT(*) as count 
      FROM commandes 
      GROUP BY statut
    `);
    
    // Ventes par mois (6 derniers mois)
    const [ventesParMois] = await connection.execute(`
      SELECT 
        DATE_FORMAT(date_commande, '%Y-%m') as mois,
        COUNT(*) as commandes,
        SUM(montant_total) as chiffre_affaires
      FROM commandes 
      WHERE date_commande >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
        AND statut != 'annulee'
      GROUP BY DATE_FORMAT(date_commande, '%Y-%m')
      ORDER BY mois DESC
    `);
    
    // Produits les plus vendus
    const [topProduits] = await connection.execute(`
      SELECT 
        p.nom,
        p.image_url,
        SUM(cp.quantite) as total_vendu,
        SUM(cp.quantite * cp.prix_unitaire) as chiffre_affaires
      FROM commande_produit cp
      JOIN produits p ON cp.id_produit = p.id
      JOIN commandes c ON cp.id_commande = c.id
      WHERE c.statut != 'annulee'
      GROUP BY p.id, p.nom, p.image_url
      ORDER BY total_vendu DESC
      LIMIT 5
    `);
    
    // Commandes récentes
    const [commandesRecentes] = await connection.execute(`
      SELECT 
        c.id,
        c.reference,
        c.date_commande,
        c.statut,
        c.montant_total,
        CONCAT(u.prenom, ' ', u.nom) as client
      FROM commandes c
      JOIN utilisateurs u ON c.id_utilisateur = u.id
      ORDER BY c.date_commande DESC
      LIMIT 10
    `);
    
    await connection.end();
    
    res.json({
      success: true,
      data: {
        stats: {
          totalProduits: totalProduits[0].count,
          totalCommandes: totalCommandes[0].count,
          totalClients: totalClients[0].count,
          chiffreAffaires: chiffreAffaires[0].total || 0
        },
        commandesParStatut,
        ventesParMois,
        topProduits,
        commandesRecentes
      }
    });
  } catch (error) {
    console.error('Erreur dashboard:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ============ ROUTES PRODUITS ============

// Récupérer tous les produits avec pagination
app.get('/api/produits', authenticateToken, requireAdmin, async (req, res) => {
  try {
    let page = parseInt(req.query.page, 10) || 1;
    if (page < 1) page = 1;

    let limit = parseInt(req.query.limit, 10) || 10;
    if (limit < 1) limit = 10;
    if (limit > 100) limit = 100;
    
    let offset = (page - 1) * limit;
    if (offset < 0) offset = 0;
    
    const search = req.query.search || '';
    const categorie = req.query.categorie || '';
    
    const connection = await createConnection();
    
    let whereClause = 'WHERE 1=1';
    let queryParams = [];
    
    if (search) {
      whereClause += ' AND (p.nom LIKE ? OR p.description LIKE ?)';
      queryParams.push(`%${search}%`, `%${search}%`);
    }
    
    if (categorie) {
      whereClause += ' AND p.id_categorie = ?';
      queryParams.push(parseInt(categorie, 10));
    }
    
    // Construire la requête avec LIMIT et OFFSET directement
    const [produits] = await connection.execute(`
      SELECT 
        p.*,
        c.nom as categorie_nom
      FROM produits p
      LEFT JOIN categories c ON p.id_categorie = c.id
      ${whereClause}
      ORDER BY p.created_at DESC
      LIMIT ${limit} OFFSET ${offset}
    `, queryParams);
    
    const [total] = await connection.execute(`
      SELECT COUNT(*) as count
      FROM produits p
      ${whereClause}
    `, queryParams);
    
    await connection.end();
    
    res.json({
      success: true,
      data: {
        produits,
        pagination: {
          page,
          limit,
          total: total[0].count,
          pages: Math.ceil(total[0].count / limit)
        }
      }
    });
  } catch (error) {
    console.error('Erreur récupération produits:', error);
    res.status(500).json({ success: false, error: 'Erreur serveur' });
  }
});

// Créer un nouveau produit
app.post('/api/produits', authenticateToken, requireAdmin, upload.single('image'), async (req, res) => {
  try {
    const {
      nom,
      description,
      description_courte,
      prix,
      prix_promo,
      stock,
      id_categorie,
      caracteristiques,
      est_actif,
      est_featured
    } = req.body;
    
    const connection = await createConnection();
    
    // Générer un slug
    const slug = nom.toLowerCase()
      .replace(/[^\w\s-]/g, '')
      .replace(/\s+/g, '-');
    
    const image_url = req.file ? `/images/uploads/${req.file.filename}` : null;
    
    const [result] = await connection.execute(`
      INSERT INTO produits (
        nom, description, description_courte, prix, prix_promo, stock,
        id_categorie, image_url, caracteristiques, est_actif, est_featured, slug
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      nom, description, description_courte, prix, prix_promo || null, stock,
      id_categorie, image_url, caracteristiques || null, 
      est_actif ? 1 : 0, est_featured ? 1 : 0, slug
    ]);
    
    await connection.end();
    
    res.status(201).json({
      success: true,
      message: 'Produit créé avec succès',
      data: { id: result.insertId }
    });
  } catch (error) {
    console.error('Erreur création produit:', error);
    res.status(500).json({ success: false, error: 'Erreur serveur' });
  }
});

// Mettre à jour un produit
app.put('/api/produits/:id', authenticateToken, requireAdmin, upload.single('image'), async (req, res) => {
  try {
    const { id } = req.params;
    const {
      nom,
      description,
      description_courte,
      prix,
      prix_promo,
      stock,
      id_categorie,
      caracteristiques,
      est_actif,
      est_featured
    } = req.body;
    
    const connection = await createConnection();
    
    const slug = nom.toLowerCase()
      .replace(/[^\w\s-]/g, '')
      .replace(/\s+/g, '-');
    
    let updateQuery = `
      UPDATE produits SET
        nom = ?, description = ?, description_courte = ?, prix = ?, 
        prix_promo = ?, stock = ?, id_categorie = ?, caracteristiques = ?,
        est_actif = ?, est_featured = ?, slug = ?, updated_at = NOW()
    `;
    let params = [
      nom, description, description_courte, prix, prix_promo || null, stock,
      id_categorie, caracteristiques || null, est_actif ? 1 : 0, est_featured ? 1 : 0, slug
    ];
    
    if (req.file) {
      updateQuery += ', image_url = ?';
      params.push(`/images/uploads/${req.file.filename}`);
    }
    
    updateQuery += ' WHERE id = ?';
    params.push(id);
    
    await connection.execute(updateQuery, params);
    await connection.end();
    
    res.json({ 
      success: true,
      message: 'Produit mis à jour avec succès' 
    });
  } catch (error) {
    console.error('Erreur mise à jour produit:', error);
    res.status(500).json({ success: false, error: 'Erreur serveur' });
  }
});

// Supprimer un produit
app.delete('/api/produits/:id', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const connection = await createConnection();
    
    await connection.execute('DELETE FROM produits WHERE id = ?', [id]);
    await connection.end();
    
    res.json({ 
      success: true,
      message: 'Produit supprimé avec succès' 
    });
  } catch (error) {
    console.error('Erreur suppression produit:', error);
    res.status(500).json({ success: false, error: 'Erreur serveur' });
  }
});

// ============ ROUTES COMMANDES ============

// Récupérer toutes les commandes
app.get('/api/commandes', authenticateToken, requireAdmin, async (req, res) => {
  try {
    let page = parseInt(req.query.page, 10) || 1;
    if (page < 1) page = 1;

    let limit = parseInt(req.query.limit, 10) || 10;
    if (limit < 1) limit = 10;
    if (limit > 100) limit = 100;
    
    let offset = (page - 1) * limit;
    if (offset < 0) offset = 0;
    
    const statut = req.query.statut || '';
    
    const connection = await createConnection();
    
    let whereClause = 'WHERE 1=1';
    let queryParams = [];
    
    if (statut) {
      whereClause += ' AND c.statut = ?';
      queryParams.push(statut);
    }
    
    const [commandes] = await connection.execute(`
      SELECT 
        c.*,
        CONCAT(u.prenom, ' ', u.nom) as client_nom,
        u.email as client_email
      FROM commandes c
      JOIN utilisateurs u ON c.id_utilisateur = u.id
      ${whereClause}
      ORDER BY c.date_commande DESC
      LIMIT ${limit} OFFSET ${offset}
    `, queryParams);
    
    const [total] = await connection.execute(`
      SELECT COUNT(*) as count
      FROM commandes c
      ${whereClause}
    `, queryParams);
    
    await connection.end();
    
    res.json({
      success: true,
      data: {
        commandes,
        pagination: {
          page,
          limit,
          total: total[0].count,
          pages: Math.ceil(total[0].count / limit)
        }
      }
    });
  } catch (error) {
    console.error('Erreur récupération commandes:', error);
    res.status(500).json({ success: false, error: 'Erreur serveur' });
  }
});

// Récupérer une commande avec ses produits
app.get('/api/commandes/:id', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const connection = await createConnection();
    
    const [commandes] = await connection.execute(`
      SELECT 
        c.*,
        CONCAT(u.prenom, ' ', u.nom) as client_nom,
        u.email as client_email,
        u.telephone as client_telephone
      FROM commandes c
      JOIN utilisateurs u ON c.id_utilisateur = u.id
      WHERE c.id = ?
    `, [id]);
    
    if (commandes.length === 0) {
      await connection.end();
      return res.status(404).json({ success: false, error: 'Commande non trouvée' });
    }
    
    const [produits] = await connection.execute(`
      SELECT 
        cp.*,
        p.nom as produit_nom,
        p.image_url
      FROM commande_produit cp
      JOIN produits p ON cp.id_produit = p.id
      WHERE cp.id_commande = ?
    `, [id]);
    
    const [historique] = await connection.execute(`
      SELECT 
        h.*,
        CONCAT(u.prenom, ' ', u.nom) as utilisateur_nom
      FROM historique_commande h
      LEFT JOIN utilisateurs u ON h.id_utilisateur = u.id
      WHERE h.id_commande = ?
      ORDER BY h.date_action DESC
    `, [id]);
    
    await connection.end();
    
    res.json({
      success: true,
      data: {
        commande: commandes[0],
        produits,
        historique
      }
    });
  } catch (error) {
    console.error('Erreur récupération commande:', error);
    res.status(500).json({ success: false, error: 'Erreur serveur' });
  }
});

// Mettre à jour le statut d'une commande
app.put('/api/commandes/:id/statut', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { statut, notes } = req.body;
    
    const connection = await createConnection();
    
    await connection.execute(
      'UPDATE commandes SET statut = ? WHERE id = ?',
      [statut, id]
    );
    
    // Ajouter à l'historique
    await connection.execute(`
      INSERT INTO historique_commande (id_commande, id_utilisateur, action, details)
      VALUES (?, ?, ?, ?)
    `, [id, req.user.id, 'changement_statut', `Statut changé vers: ${statut}${notes ? '. Notes: ' + notes : ''}`]);
    
    await connection.end();
    
    res.json({ 
      success: true,
      message: 'Statut de la commande mis à jour' 
    });
  } catch (error) {
    console.error('Erreur mise à jour statut:', error);
    res.status(500).json({ success: false, error: 'Erreur serveur' });
  }
});

// ============ ROUTES CATÉGORIES ============

// Récupérer toutes les catégories
app.get('/api/categories', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const connection = await createConnection();
    
    const [categories] = await connection.execute(`
      SELECT 
        c.*,
        p.nom as parent_nom,
        (SELECT COUNT(*) FROM produits WHERE id_categorie = c.id) as nombre_produits
      FROM categories c
      LEFT JOIN categories p ON c.parent_id = p.id
      ORDER BY c.nom
    `);
    
    await connection.end();
    res.json({
      success: true,
      data: categories
    });
  } catch (error) {
    console.error('Erreur récupération catégories:', error);
    res.status(500).json({ success: false, error: 'Erreur serveur' });
  }
});

// ============ ROUTES UTILISATEURS ============

// Récupérer tous les utilisateurs
app.get('/api/utilisateurs', authenticateToken, requireAdmin, async (req, res) => {
  try {
    let page = parseInt(req.query.page, 10) || 1;
    if (page < 1) page = 1;

    let limit = parseInt(req.query.limit, 10) || 10;
    if (limit < 1) limit = 10;
    if (limit > 100) limit = 100;
    
    let offset = (page - 1) * limit;
    if (offset < 0) offset = 0;
    
    const role = req.query.role || '';
    
    const connection = await createConnection();
    
    let whereClause = 'WHERE 1=1';
    let queryParams = [];
    
    if (role) {
      whereClause += ' AND u.idRole = ?';
      queryParams.push(parseInt(role, 10));
    }
    
    const [utilisateurs] = await connection.execute(`
      SELECT 
        u.id,
        u.email,
        u.username,
        u.nom,
        u.prenom,
        u.telephone,
        u.date_inscription,
        u.derniere_connexion,
        u.points_fidelite,
        r.libelle as role_nom,
        (SELECT COUNT(*) FROM commandes WHERE id_utilisateur = u.id) as nombre_commandes
      FROM utilisateurs u
      JOIN roles r ON u.idRole = r.id
      ${whereClause}
      ORDER BY u.date_inscription DESC
      LIMIT ${limit} OFFSET ${offset}
    `, queryParams);
    
    const [total] = await connection.execute(`
      SELECT COUNT(*) as count
      FROM utilisateurs u
      ${whereClause}
    `, queryParams);
    
    await connection.end();
    
    res.json({
      success: true,
      data: {
        utilisateurs,
        pagination: {
          page,
          limit,
          total: total[0].count,
          pages: Math.ceil(total[0].count / limit)
        }
      }
    });
  } catch (error) {
    console.error('Erreur récupération utilisateurs:', error);
    res.status(500).json({ success: false, error: 'Erreur serveur' });
  }
});

// ============ ROUTES SERVICES ET DEVIS ============

// Récupérer tous les devis
app.get('/api/devis', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const connection = await createConnection();
    
    const [devis] = await connection.execute(`
      SELECT 
        d.*,
        s.nom as service_nom,
        CONCAT(u.prenom, ' ', u.nom) as client_nom,
        u.email as client_email
      FROM devis d
      JOIN services s ON d.id_service = s.id
      JOIN utilisateurs u ON d.id_utilisateur = u.id
      ORDER BY d.date_demande DESC
    `);
    
    await connection.end();
    res.json({
      success: true,
      data: devis
    });
  } catch (error) {
    console.error('Erreur récupération devis:', error);
    res.status(500).json({ success: false, error: 'Erreur serveur' });
  }
});

// Mettre à jour un devis
app.put('/api/devis/:id', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { statut, montant_estime, notes_admin } = req.body;
    
    const connection = await createConnection();
    
    await connection.execute(`
      UPDATE devis SET
        statut = ?,
        montant_estime = ?,
        notes_admin = ?,
        date_reponse = NOW()
      WHERE id = ?
    `, [statut, montant_estime, notes_admin, id]);
    
    await connection.end();
    
    res.json({ 
      success: true,
      message: 'Devis mis à jour avec succès' 
    });
  } catch (error) {
    console.error('Erreur mise à jour devis:', error);
    res.status(500).json({ success: false, error: 'Erreur serveur' });
  }
});

// Route simple pour tester l'API
app.get('/', (req, res) => {
  res.json({
    message: 'API LeDesignDuWeb E-commerce Administration',
    version: '1.0.0',
    status: 'Running'
  });
});

// Démarrage du serveur
app.listen(PORT, () => {
  console.log(`Serveur démarré sur le port ${PORT}`);
  console.log(`API disponible sur: http://localhost:${PORT}`);
});

module.exports = app;
