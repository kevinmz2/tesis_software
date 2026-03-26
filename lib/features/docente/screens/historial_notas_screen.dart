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

    estudiantes.sort(
      (a, b) => a.nombres.toLowerCase().compareTo(b.nombres.toLowerCase()),
    );

    notas.sort((a, b) {
      final comparacionFecha = b.fecha.compareTo(a.fecha);
      if (comparacionFecha != 0) return comparacionFecha;

      final nombreA = _nombreEstudianteDesdeLista(estudiantes, a.estudianteId);
      final nombreB = _nombreEstudianteDesdeLista(estudiantes, b.estudianteId);
      return nombreA.toLowerCase().compareTo(nombreB.toLowerCase());
    });

    setState(() {
      _notas = notas;
      _actividades = actividades;
      _estudiantes = estudiantes;
    });
  }

  String _nombreEstudianteDesdeLista(
    List<Estudiante> estudiantes,
    String estudianteId,
  ) {
    try {
      return estudiantes.firstWhere((e) => e.id == estudianteId).nombres;
    } catch (_) {
      return 'Estudiante no encontrado';
    }
  }

  String _nombreEstudiante(String estudianteId) {
    try {
      return _estudiantes.firstWhere((e) => e.id == estudianteId).nombres;
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

  String _formatearNota(double valor) {
    return valor.toStringAsFixed(2);
  }

  Widget _chipInfo(String label, String valor) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
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

  Widget _encabezado() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
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
                widget.nombreAsignatura,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                children: [
                  _chipInfo('Notas', _notas.length.toString()),
                  _chipInfo('Estudiantes', _estudiantes.length.toString()),
                  _chipInfo('Actividades', _actividades.length.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
            'Primero debe registrar actividades y notas',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _listaNotas() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
              'Nota: ${_formatearNota(nota.nota)}'
              '${observacion.isNotEmpty ? '\nObs: $observacion' : ''}',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de notas'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _notas.isEmpty
          ? _estadoVacio()
          : Column(
              children: [
                _encabezado(),
                Expanded(
                  child: _listaNotas(),
                ),
              ],
            ),
    );
  }
}

