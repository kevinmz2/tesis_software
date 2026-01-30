import 'package:flutter/material.dart';

class AsistenciaScreen extends StatefulWidget {
  const AsistenciaScreen({super.key});

  @override
  State<AsistenciaScreen> createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  /// Lista temporal de estudiantes
  final List<Map<String, dynamic>> _estudiantes = [
    {'nombre': 'Juan Pérez', 'asistencia': 'P'},
    {'nombre': 'María López', 'asistencia': 'F'},
    {'nombre': 'Carlos Torres', 'asistencia': 'P'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencias'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _estudiantes.length,
        itemBuilder: (context, index) {
          final estudiante = _estudiantes[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.grey.shade700,
              ),
              title: Text(
                estudiante['nombre'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              /// ACCIONES A LA DERECHA (COMO EDITAR / ELIMINAR)
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _accionAsistencia(
                    texto: 'P',
                    tooltip: 'Presente',
                    activo: estudiante['asistencia'] == 'P',
                    color: Colors.green,
                    onTap: () {
                      setState(() {
                        estudiante['asistencia'] = 'P';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _accionAsistencia(
                    texto: 'F',
                    tooltip: 'Falta',
                    activo: estudiante['asistencia'] == 'F',
                    color: Colors.redAccent,
                    onTap: () {
                      setState(() {
                        estudiante['asistencia'] = 'F';
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ---------------------------
  /// BOTÓN DE ACCIÓN (P / F)
  /// ---------------------------
  Widget _accionAsistencia({
    required String texto,
    required String tooltip,
    required bool activo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: activo ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            texto,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: activo ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}
