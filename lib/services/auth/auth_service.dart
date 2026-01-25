//para el login, servicio de autenticacion por email 

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Login con correo y contraseña
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  /// Registro de docente
  Future<User?> register({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  /// Usuario actualmente autenticado
  User? get currentUser => _auth.currentUser;

  /// Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }
}



