import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  _InscriptionScreenState createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isvalidcheck = false;

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void enregistrementvalidation() {
    emailController.text = emailController.text.trim();

    if (nomController.text.isEmpty ||
        prenomController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    if (!isValidEmail(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email ou numéro de téléphone invalide.')),
      );
      return;
    }

    if (!isValidPassword(passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Le mot de passe doit contenir au moins 8 caractères, une majuscule, un chiffre et un caractère spécial.')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Les mots de passe ne correspondent pas.')),
      );
      return;
    }

    enregistrerUtilisateur();
  }

  bool isValidEmail(String input) {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (emailRegex.hasMatch(input)) {
      debugPrint("L'entrée est un email valide : $input");
      return true;
    }

    debugPrint("Entrée invalide : $input");
    return false;
  }

  bool isValidPassword(String password) {
    final passwordRegex =
        RegExp(r"^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$");
    return passwordRegex.hasMatch(password);
  }

  Future<void> enregistrerUtilisateur() async {
    if (!isValidEmail(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un email valide.')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:3000/utilisateurs');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nom': nomController.text,
          'prenom': prenomController.text,
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'idRole': 2,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription réussie.')),
        );
        Navigator.pushNamed(context, '/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  Widget gradientInput({
    required String label,
    bool isPassword = false,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5, bottom: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: const LinearGradient(
              colors: [Color(0xFF7e57c2), Color(0xFF6200b3)],
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: const InputDecoration(
              fillColor: Color.fromARGB(255, 54, 53, 53),
              filled: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 15),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2d2c2e),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/img/picto/profil.png'),
              ),
              const SizedBox(height: 10),
              const Text(
                "Photo de profil",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 15),
              gradientInput(label: "Nom :", controller: nomController),
              gradientInput(label: "Prénom :", controller: prenomController),
              gradientInput(
                  label: "Nom d'utilisateur :", controller: usernameController),
              gradientInput(label: "Email :", controller: emailController),
              gradientInput(
                  label: "Mot de passe :",
                  isPassword: true,
                  controller: passwordController),
              gradientInput(
                label: "Confirmation mot de passe :",
                isPassword: true,
                controller: confirmPasswordController,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  enregistrementvalidation();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7e57c2), Color(0xFF6200b3)],
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                  alignment: Alignment.center,
                  child: const Text(
                    "Créer mon compte",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
