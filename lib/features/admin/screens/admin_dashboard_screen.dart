import 'package:flutter/material.dart';

// pantallas que YA tienes
import 'admin_home_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  // VISTAS DEL ADMIN
  final List<Widget> _screens = const [
    _AdminInicio(),
    AdminHomeScreen(), // 👉 tu CRUD de docentes
    _AdminPerfil(),
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
            icon: Icon(Icons.people),
            label: 'Docentes',
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
/// DASHBOARD (INICIO ADMIN)
/// ---------------------------
class _AdminInicio extends StatelessWidget {
  const _AdminInicio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrador'),
      ),
      body: const Center(
        child: Text(
          'Bienvenido al panel de administración',
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
/// PERFIL ADMIN (PLACEHOLDER)
/// ---------------------------
class _AdminPerfil extends StatelessWidget {
  const _AdminPerfil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: const Center(
        child: Text(
          'Perfil del administrador',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
