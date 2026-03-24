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

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case 'tarea':
        return Colors.blue;
      case 'examen':
        return Colors.red;
      case 'participacion':
        return Colors.orange;
      case 'proyecto':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final titulo = (actividad['titulo'] ?? '').toString();
    final descripcion = (actividad['descripcion'] ?? '').toString();
    final tipoOriginal = (actividad['tipo'] ?? '').toString();
    final tipo = _tipoTexto(tipoOriginal);
    final fecha = (actividad['fecha'] ?? '').toString();
    final puntajeMaximo = (actividad['puntajeMaximo'] ?? '').toString();
    final colorTipo = _colorTipo(tipoOriginal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de actividad'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
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
                      backgroundColor: colorTipo.withOpacity(0.15),
                      child: Icon(
                        Icons.assignment,
                        color: colorTipo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _item(
                  'Descripción',
                  descripcion.isEmpty ? 'Sin descripción' : descripcion,
                ),
                _item('Tipo', tipo),
                _item('Fecha', fecha),
                _item('Puntaje máximo', puntajeMaximo, showDivider: false),
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

