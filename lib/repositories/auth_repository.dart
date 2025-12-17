import 'package:shared_preferences/shared_preferences.dart';
import '../data/local_db.dart';
import '../models/user_model.dart';
import '../utils/security.dart';

class AuthRepository {
  final LocalDB _db = LocalDB();

  Future<String?> register(String username, String pin, {String role = 'docente'}) async {
    final existing = await _db.getUserByUsername(username);
    if (existing != null) {
      return 'Usuario ya existe';
    }

    final salt = generateSalt();
    final pinHash = hashPin(pin, salt);
    final user = UserModel(
      username: username,
      pinHash: pinHash,
      salt: salt,
      role: role,
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      await _db.insertUser(user);
      return null; // null -> sin error
    } catch (e) {
      return 'Error al registrar usuario';
    }
  }

  Future<String?> login(String username, String pin) async {
    final user = await _db.getUserByUsername(username);
    if (user == null) return 'Usuario no encontrado';

    final inputHash = hashPin(pin, user.salt);
    if (inputHash == user.pinHash) {
      // guardar sesión local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', user.username);
      await prefs.setString('current_role', user.role);
      return null;
    } else {
      return 'PIN incorrecto';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    await prefs.remove('current_role');
  }

  Future<String?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_user');
  }
}
