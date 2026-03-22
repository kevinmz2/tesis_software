import 'package:flutter/material.dart';
import 'package:app_academica_offline/features/docente/models/nota_model.dart';
import 'package:app_academica_offline/features/estudiantes/models/estudiante_model.dart';
import 'package:app_academica_offline/services/local/nota_local_store.dart';
import 'package:app_academica_offline/services/local/estudiante_local_store.dart';

class ResumenNotasScreen extends StatefulWidget {
  final String asignaturaId;
  final String nombreAsignatura;

  const ResumenNotasScreen({
    super.key,
    required this.asignaturaId,
    required this.nombreAsignatura,
  });

  @override
  State<ResumenNotasScreen> createState() => _ResumenNotasScreenState();
}

class _ResumenNotasScreenState extends State<ResumenNotasScreen> {
  final NotaLocalStore _notaStore = NotaLocalStore();
  final EstudianteLocalStore _estudianteStore = EstudianteLocalStore();

  List<Nota> _notas = [];
  List<Estudiante> _estudiantes = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    final notas = _notaStore.getByAsignatura(widget.asignaturaId);
    final estudiantes = _estudianteStore.getByAsignatura(widget.asignaturaId);

    setState(() {
      _notas = notas;
      _estudiantes = estudiantes;
    });
  }

  List<Nota> _notasPorEstudiante(String estudianteId) {
    return _notas.where((n) => n.estudianteId == estudianteId).toList();
  }

  List<Nota> _notasPorEstudianteYTipo(String estudianteId, String tipo) {
    return _notas.where((n) {
      return n.estudianteId == estudianteId && n.tipo == tipo;
    }).toList();
  }

  double _promedioLista(List<Nota> notas) {
    if (notas.isEmpty) return 0;

    final suma = notas.fold<double>(
      0,
      (total, nota) => total + nota.nota,
    );

    return suma / notas.length;
  }

  double _promedioActual(String estudianteId) {
    final notasEstudiante = _notasPorEstudiante(estudianteId);
    return _promedioLista(notasEstudiante);
  }

  double _notaFinal(String estudianteId) {
    final promediosComponentes = <double>[];

    final tareas = _notasPorEstudianteYTipo(estudianteId, 'tarea');
    final examenes = _notasPorEstudianteYTipo(estudianteId, 'examen');
    final proyectos = _notasPorEstudianteYTipo(estudianteId, 'proyecto');
    final participaciones =
        _notasPorEstudianteYTipo(estudianteId, 'participacion');

    if (tareas.isNotEmpty) {
      promediosComponentes.add(_promedioLista(tareas));
    }

    if (examenes.isNotEmpty) {
      promediosComponentes.add(_promedioLista(examenes));
    }

    if (proyectos.isNotEmpty) {
      promediosComponentes.add(_promedioLista(proyectos));
    }

    if (participaciones.isNotEmpty) {
      promediosComponentes.add(_promedioLista(participaciones));
    }

    if (promediosComponentes.isEmpty) return 0;

    final suma = promediosComponentes.fold<double>(
      0,
      (total, valor) => total + valor,
    );

    return suma / promediosComponentes.length;
  }

  String _formatear(double valor) {
    return valor.toStringAsFixed(2);
  }

  Widget _estadoVacio() {
    return const Center(
      child: Text('No hay estudiantes o notas registradas'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noHayDatos = _estudiantes.isEmpty || _notas.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen de notas - ${widget.nombreAsignatura}'),
      ),
      body: noHayDatos
          ? _estadoVacio()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _estudiantes.length,
              itemBuilder: (context, index) {
                final estudiante = _estudiantes[index];
                final notasEstudiante = _notasPorEstudiante(estudiante.id);

                final promedioActual = _promedioActual(estudiante.id);
                final notaFinal = _notaFinal(estudiante.id);

                final promedioTareas = _promedioLista(
                  _notasPorEstudianteYTipo(estudiante.id, 'tarea'),
                );
                final promedioExamenes = _promedioLista(
                  _notasPorEstudianteYTipo(estudiante.id, 'examen'),
                );
                final promedioProyectos = _promedioLista(
                  _notasPorEstudianteYTipo(estudiante.id, 'proyecto'),
                );
                final promedioParticipacion = _promedioLista(
                  _notasPorEstudianteYTipo(estudiante.id, 'participacion'),
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estudiante.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Actividades calificadas: ${notasEstudiante.length}',
                        ),
                        Text(
                          'Promedio actual: ${_formatear(promedioActual)}',
                        ),
                        const SizedBox(height: 8),
                        Text('Tareas: ${_formatear(promedioTareas)}'),
                        Text('Exámenes: ${_formatear(promedioExamenes)}'),
                        Text('Proyectos: ${_formatear(promedioProyectos)}'),
                        Text(
                          'Participación: ${_formatear(promedioParticipacion)}',
                        ),
                        const Divider(height: 20),
                        Text(
                          'Nota final: ${_formatear(notaFinal)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}