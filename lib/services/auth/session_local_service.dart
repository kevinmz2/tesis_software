import 'package:shared_preferences/shared_preferences.dart';

class SessionLocalService {
  static const String _keySesionActiva = 'sesion_activa';
  static const String _keyUid = 'uid';
  static const String _keyEmail = 'email';
  static const String _keyNombre = 'nombre';
  static const String _keyRol = 'rol';

  Future<void> guardarSesion({
    required String uid,
    required String email,
    required String nombre,
    required String rol,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keySesionActiva, true);
    await prefs.setString(_keyUid, uid);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyNombre, nombre);
    await prefs.setString(_keyRol, rol);
  }

  Future<bool> haySesionActiva() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySesionActiva) ?? false;
  }

  Future<String?> obtenerUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUid);
  }

  Future<String?> obtenerEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  Future<String?> obtenerNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNombre);
  }

  Future<String?> obtenerRol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRol);
  }

  Future<void> limpiarSesion() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keySesionActiva);
    await prefs.remove(_keyUid);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyNombre);
    await prefs.remove(_keyRol);
  }
}