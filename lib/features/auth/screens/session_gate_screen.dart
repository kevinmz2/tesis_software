import 'package:flutter/material.dart';
import 'package:app_academica_offline/services/auth/session_local_service.dart';

class SessionGateScreen extends StatefulWidget {
  const SessionGateScreen({super.key});

  @override
  State<SessionGateScreen> createState() => _SessionGateScreenState();
}

class _SessionGateScreenState extends State<SessionGateScreen> {
  final SessionLocalService _sessionLocalService = SessionLocalService();

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final haySesion = await _sessionLocalService.haySesionActiva();

    if (!mounted) return;

    if (!haySesion) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final rol = await _sessionLocalService.obtenerRol();

    if (!mounted) return;

    if (rol == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin');
    } else if (rol == 'docente') {
      Navigator.pushReplacementNamed(context, '/docente');
    } else {
      await _sessionLocalService.limpiarSesion();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FA),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: Colors.deepPurple.shade100,
              child: Icon(
                Icons.school,
                size: 36,
                color: Colors.deepPurple.shade700,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.deepPurple.shade700,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Verificando sesión...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1C),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Espere un momento',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

