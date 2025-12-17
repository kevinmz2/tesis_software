import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';

class HomePage extends StatelessWidget {
  final _auth = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _auth.currentUser(),
      builder: (context, snap) {
        final user = snap.data ?? 'Usuario';
        return Scaffold(
          appBar: AppBar(
            title: Text('Bienvenido, $user'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await _auth.logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
              )
            ],
          ),
          body: Center(child: Text('Página principal del sistema')),
        );
      },
    );
  }
}
