import 'package:flutter/material.dart';

import 'package:app_academica_offline/features/estudiantes/screens/estudiantes_home_screen.dart';
import 'package:app_academica_offline/features/docente/screens/registrar_asistencia_screen.dart';
import 'package:app_academica_offline/features/docente/screens/historial_asistencias_screen.dart';
import 'package:app_academica_offline/features/docente/screens/actividades_screen.dart';
import 'package:app_academica_offline/features/docente/screens/notas_screen.dart';
import 'package:app_academica_offline/features/docente/screens/historial_notas_screen.dart';
import 'package:app_academica_offline/features/docente/screens/resumen_notas_screen.dart';

class AsignaturaDetailScreen extends StatelessWidget {
  final Map<String, dynamic> asignatura;

  const AsignaturaDetailScreen({
    super.key,
    required this.asignatura,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('ASIGNATURA DETAIL: $asignatura');

    final String asignaturaId = (asignatura['nombre'] ?? '').toString();
    final String nombreAsignatura = (asignatura['nombre'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de asignatura'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombreAsignatura,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Información general y accesos rápidos',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _item('Asignatura', nombreAsignatura),
                    _item('Curso', (asignatura['curso'] ?? '').toString()),
                    _item(
                      'Docente',
                      (asignatura['docente'] ?? 'Docente asignado').toString(),
                    ),
                    _item(
                      'Número de estudiantes',
                      (asignatura['numeroEstudiantes'] ?? 0).toString(),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Módulos disponibles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),

            _botonModulo(
              context: context,
              icon: Icons.people,
              texto: 'Estudiantes',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EstudiantesHomeScreen(
                      asignatura: asignatura,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _botonModulo(
              context: context,
              icon: Icons.checklist,
              texto: 'Asistencias',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegistrarAsistenciaScreen(
                      asignaturaId: asignaturaId,
                      nombreAsignatura: nombreAsignatura,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _botonModulo(
              context: context,
              icon: Icons.history,
              texto: 'Historial de asistencias',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistorialAsistenciasScreen(
                      asignaturaId: asignaturaId,
                      nombreAsignatura: nombreAsignatura,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _botonModulo(
              context: context,
              icon: Icons.assignment,
              texto: 'Actividades',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActividadesScreen(
                      asignaturaId: asignaturaId,
                      nombreAsignatura: nombreAsignatura,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _botonModulo(
              context: context,
              icon: Icons.edit_note,
              texto: 'Notas',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotasScreen(
                      asignaturaId: asignaturaId,
                      nombreAsignatura: nombreAsignatura,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _botonModulo(
              context: context,
              icon: Icons.menu_book,
              texto: 'Historial de notas',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistorialNotasScreen(
                      asignaturaId: asignaturaId,
                      nombreAsignatura: nombreAsignatura,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _botonModulo(
              context: context,
              icon: Icons.calculate,
              texto: 'Resumen de notas',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResumenNotasScreen(
                      asignaturaId: asignaturaId,
                      nombreAsignatura: nombreAsignatura,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(String label, String value, {bool showDivider = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
          if (showDivider) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  Widget _botonModulo({
    required BuildContext context,
    required IconData icon,
    required String texto,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

