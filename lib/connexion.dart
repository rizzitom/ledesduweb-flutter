import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({super.key});

  @override
  _ConnexionScreenState createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> login(BuildContext context) async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://10.0.2.2:3000/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(responseData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connexion réussie')),
      );
      Navigator.pushNamed(context, '/home_admin');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nom utilisateur ou mot de passe incorrect')),
      );
    }
  }

  static const Color textColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2d2c2e),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/img/logo/logo.png',
                width: 150,
                height: 150,
              ),
              const Text(
                'Le Design Du Web',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 50),
              buildTextField(
                _usernameController,
                'Identifiant :',
              ),
              buildTextField(
                _passwordController,
                'Mot de passe :',
                obscureText: true,
              ),
              GestureDetector(
                onTap: _isLoading ? null : () => login(context),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7e57c2), Color(0xFF6200b3)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Center(
                          child: Text(
                            'Connexion',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 19,
                            ),
                          ),
                        ),
                ),
              ),
              GestureDetector(
                onTap: () => forgotPassword(context),
                child: const Text(
                  'Mot de passe oublié ?',
                  style: TextStyle(color: textColor),
                ),
              ),
              const SizedBox(height: 60),
              buildButton(context, 'Créer un compte',
                  onTap: () => createAccount(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey[400],
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF6200b3), width: 2),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromARGB(255, 72, 36, 134), width: 2),
          ),
        ),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, String text,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7e57c2), Color(0xFF6200b3)],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  void forgotPassword(BuildContext context) {
    Navigator.pushNamed(context, '/mdpforget');
  }

  void createAccount(BuildContext context) {
    Navigator.pushNamed(context, '/inscription');
  }
}
