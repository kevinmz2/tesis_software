import 'package:flutter/material.dart';

import 'package:app_academica_offline/features/estudiantes/screens/estudiantes_home_screen.dart';
import 'package:app_academica_offline/features/docente/screens/registrar_asistencia_screen.dart';
import 'package:app_academica_offline/features/docente/screens/actividades_screen.dart';
import 'package:app_academica_offline/features/docente/screens/notas_screen.dart';

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
        title: const Text('Detalle de Asignatura'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.people),
                label: const Text('Estudiantes'),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.checklist),
                label: const Text('Asistencias'),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.assignment),
                label: const Text('Actividades'),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.edit_note),
                label: const Text('Notas'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
          const Divider(),
        ],
      ),
    );
  }
}