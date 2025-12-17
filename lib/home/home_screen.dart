import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final Map usuario;

  const HomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenido estimado ${usuario['username']}"),
      ),
      body: const Center(
        child: Text(
          "Login correcto — Modo Offline",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
