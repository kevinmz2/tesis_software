import 'package:flutter/material.dart';

class EstudianteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> estudiante;

  const EstudianteDetailScreen({
    super.key,
    required this.estudiante,
  });

  @override
  Widget build(BuildContext context) {
    final nombres = (estudiante['nombres'] ?? '').toString();
    final apellidos = (estudiante['apellidos'] ?? '').toString();
    final nombreCompleto = (estudiante['nombre'] ?? '').toString().trim().isNotEmpty
        ? (estudiante['nombre'] ?? '').toString()
        : '$apellidos $nombres'.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del estudiante'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreCompleto,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _item('Apellidos', apellidos),
                _item('Nombres', nombres),
                _item('Edad', (estudiante['edad'] ?? '').toString()),
                _item('Celular', (estudiante['celular'] ?? '').toString()),
                _item(
                  'Tipo de sangre',
                  (estudiante['tipoSangre'] ?? '').toString(),
                ),
                _item(
                  'En caso de emergencia llamar a',
                  (estudiante['contactoEmergenciaNombre'] ?? '').toString(),
                ),
                _item(
                  'Número de emergencia',
                  (estudiante['contactoEmergenciaCelular'] ?? '').toString(),
                ),
                _item(
                  'Curso',
                  (estudiante['curso'] ?? '').toString(),
                ),
                _item(
                  'Asignatura',
                  (estudiante['asignaturaId'] ?? '').toString(),
                  showDivider: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(String label, String value, {bool showDivider = true}) {
    final texto = value.trim().isEmpty ? 'No registrado' : value;

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
            texto,
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
}
