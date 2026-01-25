import 'package:flutter/material.dart';

class DocenteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> docente;

  const DocenteDetailScreen({
    super.key,
    required this.docente,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Docente'),
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
            _item('Nombres y Apellidos', docente['nombre']),
            _item('Cédula', docente['cedula']),
            _item('Edad', docente['edad'].toString()),
            _item('Correo electrónico', docente['correo']),
            _item('Teléfono', docente['telefono']),
            _item('Institución', docente['institucion']),
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
