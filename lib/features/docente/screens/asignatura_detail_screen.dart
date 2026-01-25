import 'package:flutter/material.dart';

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
        backgroundColor: Colors.deepPurple.shade700,
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
            _item('Asignatura', asignatura['nombre']),
            _item('Curso', asignatura['curso']),
            _item('Docente', asignatura['docente'] ?? 'Docente asignado'),
            _item(
              'Número de estudiantes',
              asignatura['estudiantes']?.toString() ?? '0',
            ),
            const SizedBox(height: 30),

            /// BOTONES PLACEHOLDER
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // luego asistencia
                    },
                    icon: const Icon(Icons.checklist),
                    label: const Text('Asistencia'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // luego notas
                    },
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Notas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
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
