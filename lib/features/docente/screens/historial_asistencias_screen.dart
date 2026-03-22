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

  Widget _estadoVacio() {
    return const Center(
      child: Text('No hay asistencias registradas'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial - ${widget.nombreAsignatura}'),
      ),
      body: _asistencias.isEmpty
          ? _estadoVacio()
          : ListView.builder(
              itemCount: _asistencias.length,
              itemBuilder: (context, index) {
                final asistencia = _asistencias[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(_nombreEstudiante(asistencia.estudianteId)),
                    subtitle: Text(
                      'Fecha: ${asistencia.fecha}\n'
                      'Estado: ${_estadoTexto(asistencia.estado)}'
                      '${(asistencia.observacion ?? '').trim().isNotEmpty ? '\nObs: ${asistencia.observacion}' : ''}',
                    ),
                    isThreeLine:
                        (asistencia.observacion ?? '').trim().isNotEmpty,
                  ),
                );
              },
            ),
    );
  }
}