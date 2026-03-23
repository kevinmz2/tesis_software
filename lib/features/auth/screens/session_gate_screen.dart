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
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
