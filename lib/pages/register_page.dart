import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _auth = AuthRepository();
  bool _loading = false;

  void _register() async {
    final user = _usernameCtrl.text.trim();
    final pin = _pinCtrl.text.trim();

    if (user.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Complete todos los campos')));
      return;
    }
    if (pin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('El PIN debe tener al menos 4 dígitos')));
      return;
    }

    setState(() => _loading = true);
    final err = await _auth.register(user, pin);
    setState(() => _loading = false);

    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuario registrado')));
      Navigator.pop(context); // volver al login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar usuario')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _usernameCtrl, decoration: InputDecoration(labelText: 'Usuario')),
            TextField(controller: _pinCtrl, decoration: InputDecoration(labelText: 'PIN'), obscureText: true, keyboardType: TextInputType.number),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? CircularProgressIndicator() : Text('Registrar')),
          ],
        ),
      ),
    );
  }
}

