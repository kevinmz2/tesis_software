//este va ser un archivo temporal, luego se lo debe borrar si 

import 'package:flutter/material.dart';
import '../services/auth/auth_service.dart';
//import '../services/auth/auth_service.dart';
//import '../features/auth/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema Académico'),
      ),
      body: Center(
        child: Text(
          'Bienvenido ${user?.email}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}



