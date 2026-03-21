import 'package:flutter/material.dart';

class EstudianteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> estudiante;

  const EstudianteDetailScreen({
    super.key,
    required this.estudiante,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Estudiante'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _item(
              'Nombre',
              (estudiante['nombre'] ?? '').toString(),
            ),
            _item(
              'Curso',
              (estudiante['curso'] ?? '').toString(),
            ),
            _item(
              'Asignatura',
              (estudiante['asignaturaId'] ?? '').toString(),
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