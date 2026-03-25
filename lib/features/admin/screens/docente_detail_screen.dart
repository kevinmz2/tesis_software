import 'package:flutter/material.dart';
import 'package:app_academica_offline/features/admin/models/docente_model.dart';

class DocenteDetailScreen extends StatelessWidget {
  final Docente docente;

  const DocenteDetailScreen({
    super.key,
    required this.docente,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del docente'),
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
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: docente.activo
                          ? Colors.deepPurple.shade100
                          : Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        color: docente.activo
                            ? Colors.deepPurple.shade700
                            : Colors.grey.shade700,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        docente.nombre,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _item('Nombres y apellidos', docente.nombre),
                _item('Cédula', docente.cedula),
                _item('Edad', docente.edad.toString()),
                _item('Correo electrónico', docente.correo),
                _item('Teléfono', docente.telefono),
                _item('ID de institución', docente.institucionId),
                _item(
                  'Institución',
                  docente.institucionNombre.isEmpty
                      ? 'No registrada'
                      : docente.institucionNombre,
                ),
                _item(
                  'Estado',
                  docente.activo ? 'Activo' : 'Inactivo',
                ),
                _item(
                  'Pendiente de sincronización',
                  docente.pendienteSync ? 'Sí' : 'No',
                ),
                _item(
                  'Fecha de creación',
                  docente.fechaCreacion.isEmpty
                      ? 'No registrada'
                      : docente.fechaCreacion,
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
}

