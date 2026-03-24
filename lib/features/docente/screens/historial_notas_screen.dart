import 'package:flutter/material.dart';
import 'package:app_academica_offline/features/docente/models/nota_model.dart';
import 'package:app_academica_offline/features/docente/models/actividad_model.dart';
import 'package:app_academica_offline/features/estudiantes/models/estudiante_model.dart';
import 'package:app_academica_offline/services/local/nota_local_store.dart';
import 'package:app_academica_offline/services/local/actividad_local_store.dart';
import 'package:app_academica_offline/services/local/estudiante_local_store.dart';

class HistorialNotasScreen extends StatefulWidget {
  final String asignaturaId;
  final String nombreAsignatura;

  const HistorialNotasScreen({
    super.key,
    required this.asignaturaId,
    required this.nombreAsignatura,
  });

  @override
  State<HistorialNotasScreen> createState() => _HistorialNotasScreenState();
}

class _HistorialNotasScreenState extends State<HistorialNotasScreen> {
  final NotaLocalStore _notaStore = NotaLocalStore();
  final ActividadLocalStore _actividadStore = ActividadLocalStore();
  final EstudianteLocalStore _estudianteStore = EstudianteLocalStore();

  List<Nota> _notas = [];
  List<Actividad> _actividades = [];
  List<Estudiante> _estudiantes = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    final notas = _notaStore.getByAsignatura(widget.asignaturaId);
    final actividades = _actividadStore.getByAsignatura(widget.asignaturaId);
    final estudiantes = _estudianteStore.getByAsignatura(widget.asignaturaId);

    notas.sort((a, b) => b.fecha.compareTo(a.fecha));

    setState(() {
      _notas = notas;
      _actividades = actividades;
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

  String _nombreActividad(String actividadId) {
    try {
      return _actividades.firstWhere((a) => a.id == actividadId).titulo;
    } catch (_) {
      return 'Actividad no encontrada';
    }
  }

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
      case 'final':
        return 'Nota final';
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
      case 'final':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  Widget _estadoVacio() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_note, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay notas registradas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Todavía no se han guardado notas',
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
      body: _notas.isEmpty
          ? _estadoVacio()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notas.length,
              itemBuilder: (context, index) {
                final nota = _notas[index];
                final observacion = (nota.observacion ?? '').trim();
                final tipoTexto = _tipoTexto(nota.tipo);
                final colorTipo = _colorTipo(nota.tipo);

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
                      backgroundColor: colorTipo.withOpacity(0.15),
                      child: Icon(
                        Icons.edit_note,
                        color: colorTipo,
                      ),
                    ),
                    title: Text(
                      _nombreEstudiante(nota.estudianteId),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Actividad: ${_nombreActividad(nota.actividadId)}\n'
                      'Tipo: $tipoTexto\n'
                      'Fecha: ${nota.fecha}\n'
                      'Nota: ${nota.nota}'
                      '${observacion.isNotEmpty ? '\nObs: $observacion' : ''}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}

