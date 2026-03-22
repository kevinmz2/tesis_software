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

  Widget _estadoVacio() {
    return const Center(
      child: Text('No hay notas registradas'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial - ${widget.nombreAsignatura}'),
      ),
      body: _notas.isEmpty
          ? _estadoVacio()
          : ListView.builder(
              itemCount: _notas.length,
              itemBuilder: (context, index) {
                final nota = _notas[index];

                final observacion = (nota.observacion ?? '').trim();
                final textoObservacion = observacion.isNotEmpty
                    ? '\nObs: $observacion'
                    : '';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.edit_note),
                    title: Text(_nombreEstudiante(nota.estudianteId)),
                    subtitle: Text(
                      'Actividad: ${_nombreActividad(nota.actividadId)}\n'
                      'Tipo: ${_tipoTexto(nota.tipo)}\n'
                      'Fecha: ${nota.fecha}\n'
                      'Nota: ${nota.nota}$textoObservacion',
                    ),
                  ),
                );
              },
            ),
    );
  }
}