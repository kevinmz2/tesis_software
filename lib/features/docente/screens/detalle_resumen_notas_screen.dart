import 'package:flutter/material.dart';
import 'package:app_academica_offline/features/docente/models/nota_model.dart';
import 'package:app_academica_offline/features/docente/models/actividad_model.dart';

class DetalleResumenNotasScreen extends StatelessWidget {
  final String nombreEstudiante;
  final List<Nota> notasEstudiante;
  final List<Actividad> actividades;

  const DetalleResumenNotasScreen({
    super.key,
    required this.nombreEstudiante,
    required this.notasEstudiante,
    required this.actividades,
  });

  String _nombreActividad(String actividadId) {
    try {
      return actividades.firstWhere((a) => a.id == actividadId).titulo;
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

  double _promedioLista(List<Nota> notas) {
    if (notas.isEmpty) return 0;

    final suma = notas.fold<double>(
      0,
      (total, nota) => total + nota.nota,
    );

    return suma / notas.length;
  }

  List<Nota> _filtrarPorTipo(String tipo) {
    return notasEstudiante.where((n) => n.tipo == tipo).toList();
  }

  double _notaFinal() {
    final promediosComponentes = <double>[];

    final tareas = _filtrarPorTipo('tarea');
    final examenes = _filtrarPorTipo('examen');
    final proyectos = _filtrarPorTipo('proyecto');
    final participaciones = _filtrarPorTipo('participacion');

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

  String _estadoAcademico(double notaFinal) {
    if (notaFinal >= 7) return 'Aprobado';
    if (notaFinal >= 5) return 'Supletorio';
    return 'Reprobado';
  }

  String _formatear(double valor) {
    return valor.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final promedioActual = _promedioLista(notasEstudiante);
    final notaFinal = _notaFinal();
    final estado = _estadoAcademico(notaFinal);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle - $nombreEstudiante'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreEstudiante,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Promedio actual: ${_formatear(promedioActual)}'),
                    Text('Nota final: ${_formatear(notaFinal)}'),
                    Text('Estado: $estado'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: notasEstudiante.isEmpty
                  ? const Center(
                      child: Text('No hay notas registradas'),
                    )
                  : ListView.builder(
                      itemCount: notasEstudiante.length,
                      itemBuilder: (context, index) {
                        final nota = notasEstudiante[index];
                        final observacion = (nota.observacion ?? '').trim();

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const Icon(Icons.edit_note),
                            title: Text(_nombreActividad(nota.actividadId)),
                            subtitle: Text(
                              'Tipo: ${_tipoTexto(nota.tipo)}\n'
                              'Fecha: ${nota.fecha}\n'
                              'Nota: ${nota.nota}'
                              '${observacion.isNotEmpty ? '\nObs: $observacion' : ''}',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}