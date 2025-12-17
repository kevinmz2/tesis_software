import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  Future<void> _login() async {
    final username = userController.text.trim();
    final pin = pinController.text.trim();

    if (username.isEmpty || pin.isEmpty) {
      _showMessage("Por favor complete todos los campos.");
      return;
    }

    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'usuarios',
        where: 'username = ?',
        whereArgs: [username],
        limit: 1,
      );

      if (result.isEmpty) {
        _showMessage("El usuario no fue encontrado.");
        return;
      }

      final user = result.first;

      if (pin != user['pin']) {
        _showMessage("el pin es incorrecto.");
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(usuario: user),
        ),
      );

    } catch (e) {
      _showMessage("Ocurri un error. Intenta nuevamente.");
      print("Error en login: $e");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Offline")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: userController,
              decoration: const InputDecoration(
                labelText: "Usuario",

                
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "PIN",
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Ingresar"),
            ),
          ],
        ),
      ),
    );
  }
}
