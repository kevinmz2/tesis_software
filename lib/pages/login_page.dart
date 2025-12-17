import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _auth = AuthRepository();
  bool _loading = false;

  void _login() async {
    final user = _usernameCtrl.text.trim();
    final pin = _pinCtrl.text.trim();

    if (user.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Complete todos los campos')));
      return;
    }

    setState(() => _loading = true);
    final err = await _auth.login(user, pin);
    setState(() => _loading = false);

    if (err == null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ingreso')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _usernameCtrl, decoration: InputDecoration(labelText: 'Usuario')),
            TextField(controller: _pinCtrl, decoration: InputDecoration(labelText: 'PIN'), obscureText: true, keyboardType: TextInputType.number),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? CircularProgressIndicator() : Text('Ingresar')),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: Text('Registrar nuevo usuario')),
          ],
        ),
      ),
    );
  }
}
