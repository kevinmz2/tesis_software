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

  double? _promedioActual() {
    if (notasEstudiante.isEmpty) return null;
    return _promedioLista(notasEstudiante);
  }

  double? _notaFinal() {
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

    if (promediosComponentes.isEmpty) return null;

    final suma = promediosComponentes.fold<double>(
      0,
      (total, valor) => total + valor,
    );

    return suma / promediosComponentes.length;
  }

  String _estadoAcademico(double? notaFinal) {
    if (notaFinal == null) return 'Sin calificar';
    if (notaFinal >= 7) return 'Aprobado';
    if (notaFinal >= 5) return 'Supletorio';
    return 'Reprobado';
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Aprobado':
        return Colors.green;
      case 'Supletorio':
        return Colors.orange;
      case 'Reprobado':
        return Colors.red;
      case 'Sin calificar':
        return Colors.blueGrey;
      default:
        return Colors.black87;
    }
  }

  String _formatear(double valor) {
    return valor.toStringAsFixed(2);
  }

  String _formatearOpcional(double? valor) {
    if (valor == null) return '--';
    return valor.toStringAsFixed(2);
  }

  Widget _chipInfo(String label, String valor) {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $valor',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final promedioActual = _promedioActual();
    final notaFinal = _notaFinal();
    final estado = _estadoAcademico(notaFinal);

    final notasOrdenadas = [...notasEstudiante]
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle académico'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreEstudiante,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      children: [
                        _chipInfo(
                          'Actividades calificadas',
                          notasEstudiante.length.toString(),
                        ),
                        _chipInfo(
                          'Promedio actual',
                          _formatearOpcional(promedioActual),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Nota final: ${_formatearOpcional(notaFinal)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estado: $estado',
                      style: TextStyle(
                        color: _colorEstado(estado),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (notasEstudiante.isEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Este estudiante aún no tiene notas registradas.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: notasOrdenadas.isEmpty
                  ? const Center(
                      child: Text('No hay notas registradas'),
                    )
                  : ListView.builder(
                      itemCount: notasOrdenadas.length,
                      itemBuilder: (context, index) {
                        final nota = notasOrdenadas[index];
                        final observacion = (nota.observacion ?? '').trim();
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
                              _nombreActividad(nota.actividadId),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Tipo: ${_tipoTexto(nota.tipo)}\n'
                              'Fecha: ${nota.fecha}\n'
                              'Nota: ${_formatear(nota.nota)}'
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

