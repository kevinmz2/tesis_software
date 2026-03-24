import 'package:flutter/material.dart';
import 'package:app_academica_offline/features/docente/models/asistencia_model.dart';
import 'package:app_academica_offline/features/estudiantes/models/estudiante_model.dart';
import 'package:app_academica_offline/services/local/asistencia_local_store.dart';
import 'package:app_academica_offline/services/local/estudiante_local_store.dart';

class HistorialAsistenciasScreen extends StatefulWidget {
  final String asignaturaId;
  final String nombreAsignatura;

  const HistorialAsistenciasScreen({
    super.key,
    required this.asignaturaId,
    required this.nombreAsignatura,
  });

  @override
  State<HistorialAsistenciasScreen> createState() =>
      _HistorialAsistenciasScreenState();
}

class _HistorialAsistenciasScreenState
    extends State<HistorialAsistenciasScreen> {
  final AsistenciaLocalStore _asistenciaStore = AsistenciaLocalStore();
  final EstudianteLocalStore _estudianteStore = EstudianteLocalStore();

  List<Asistencia> _asistencias = [];
  List<Estudiante> _estudiantes = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    final asistencias = _asistenciaStore.getByAsignatura(widget.asignaturaId);
    final estudiantes = _estudianteStore.getByAsignatura(widget.asignaturaId);

    asistencias.sort((a, b) => b.fecha.compareTo(a.fecha));

    setState(() {
      _asistencias = asistencias;
      _estudiantes = estudiantes;
    });
  }

  String _nombreEstudiante(String estudianteId) {
    try {
      return _estudiantes.firstWhere((e) => e.id == estudianteId).nombre;
    } catch (_) {
      return 'Estudiante no encontrado';
    }
  }

  String _estadoTexto(String estado) {
    switch (estado) {
      case 'presente':
        return 'Presente';
      case 'ausente':
        return 'Ausente';
      case 'atraso':
        return 'Atraso';
      case 'justificado':
        return 'Justificado';
      default:
        return estado;
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'presente':
        return Colors.green;
      case 'ausente':
        return Colors.red;
      case 'atraso':
        return Colors.orange;
      case 'justificado':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _estadoVacio() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay asistencias registradas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Todavía no se han guardado asistencias',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial - ${widget.nombreAsignatura}'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _asistencias.isEmpty
          ? _estadoVacio()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _asistencias.length,
              itemBuilder: (context, index) {
                final asistencia = _asistencias[index];
                final observacion = (asistencia.observacion ?? '').trim();
                final estadoTexto = _estadoTexto(asistencia.estado);

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                          _colorEstado(asistencia.estado).withValues(alpha: 0.15),
                      child: Icon(
                        Icons.person,
                        color: _colorEstado(asistencia.estado),
                      ),
                    ),
                    title: Text(
                      _nombreEstudiante(asistencia.estudianteId),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Fecha: ${asistencia.fecha}\n'
                      'Estado: $estadoTexto'
                      '${observacion.isNotEmpty ? '\nObs: $observacion' : ''}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}

