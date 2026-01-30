import 'package:flutter/material.dart';

// placeholders
import '../../estudiantes/screens/estudiantes_home_screen.dart';
import 'asistencia_screen.dart';
import 'notas_screen.dart';

class AsignaturaDetailScreen extends StatelessWidget {
  final Map<String, dynamic> asignatura;

  const AsignaturaDetailScreen({
    super.key,
    required this.asignatura,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Asignatura'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------------------------
            /// INFO DE LA ASIGNATURA
            /// ---------------------------
            Text(
              asignatura['nombre'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Curso: ${asignatura['curso']}'),
            const SizedBox(height: 4),
            Text('Docente: ${asignatura['docente']}'),
            const SizedBox(height: 4),
            Text(
              'Estudiantes: ${asignatura['numeroEstudiantes']}',
            ),

            const SizedBox(height: 30),

            /// ---------------------------
            /// BOTONES
            /// ---------------------------
            _boton(
              context,
              icon: Icons.people,
              texto: 'Estudiantes',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const EstudiantesHomeScreen(),
                  ),
                );
              },
            ),

            _boton(
              context,
              icon: Icons.check_circle_outline,
              texto: 'Asistencias',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AsistenciaScreen(),
                  ),
                );
              },
            ),

            _boton(
              context,
              icon: Icons.grade,
              texto: 'Notas',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const NotasScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------------------
  /// BOTÓN REUTILIZABLE
  /// ---------------------------
  Widget _boton(
    BuildContext context, {
    required IconData icon,
    required String texto,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          icon: Icon(icon),
          label: Text(texto),
          onPressed: onTap,
        ),
      ),
    );
  }
}
