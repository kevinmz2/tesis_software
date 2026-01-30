import 'package:flutter/material.dart';

// pantallas que YA tienes
import 'docente_home_screen.dart';

class DocenteDashboardScreen extends StatefulWidget {
  const DocenteDashboardScreen({super.key});

  @override
  State<DocenteDashboardScreen> createState() =>
      _DocenteDashboardScreenState();
}

class _DocenteDashboardScreenState
    extends State<DocenteDashboardScreen> {
  int _currentIndex = 0;

  // VISTAS DEL DOCENTE
  final List<Widget> _screens = const [
    _DocenteInicio(),
    DocenteHomeScreen(), // 👉 tu lista de asignaturas
    _DocentePerfil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Asignaturas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

/// ---------------------------
/// DASHBOARD DOCENTE
/// ---------------------------
class _DocenteInicio extends StatelessWidget {
  const _DocenteInicio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Docente'),
      ),
      body: const Center(
        child: Text(
          'Bienvenido al panel del docente',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------
/// PERFIL DOCENTE (PLACEHOLDER)
/// ---------------------------
class _DocentePerfil extends StatelessWidget {
  const _DocentePerfil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: const Center(
        child: Text(
          'Perfil del docente',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
