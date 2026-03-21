import 'package:flutter/material.dart';

class ActividadDetailScreen extends StatelessWidget {
  final Map<String, dynamic> actividad;

  const ActividadDetailScreen({
    super.key,
    required this.actividad,
  });

  String _tipoTexto(String tipo) {
    switch (tipo) {
      case 'tarea':
        return 'Tarea';
      case 'examen':
        return 'Examen';
      case 'participacion':
        return 'Participación';
      case 'proyecto':
        return 'Proyecto';
      default:
        return tipo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final titulo = (actividad['titulo'] ?? '').toString();
    final descripcion = (actividad['descripcion'] ?? '').toString();
    final tipo = _tipoTexto((actividad['tipo'] ?? '').toString());
    final fecha = (actividad['fecha'] ?? '').toString();
    final puntajeMaximo = (actividad['puntajeMaximo'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Actividad'),
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
            _item('Título', titulo),
            _item(
              'Descripción',
              descripcion.isEmpty ? 'Sin descripción' : descripcion,
            ),
            _item('Tipo', tipo),
            _item('Fecha', fecha),
            _item('Puntaje máximo', puntajeMaximo),
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