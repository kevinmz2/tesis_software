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

    estudiantes.sort(
      (a, b) => a.nombres.toLowerCase().compareTo(b.nombres.toLowerCase()),
    );

    asistencias.sort((a, b) {
      final comparacionFecha = b.fecha.compareTo(a.fecha);
      if (comparacionFecha != 0) return comparacionFecha;

      final nombreA = _nombreEstudianteDesdeLista(estudiantes, a.estudianteId);
      final nombreB = _nombreEstudianteDesdeLista(estudiantes, b.estudianteId);
      return nombreA.toLowerCase().compareTo(nombreB.toLowerCase());
    });

    setState(() {
      _asistencias = asistencias;
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
                  _chipInfo('Asistencias', _asistencias.length.toString()),
                  _chipInfo('Estudiantes', _estudiantes.length.toString()),
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
          Icon(Icons.fact_check_outlined, size: 80, color: Colors.grey),
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
            'Primero debe registrar la asistencia de los estudiantes',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _listaAsistencias() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _asistencias.length,
      itemBuilder: (context, index) {
        final asistencia = _asistencias[index];
        final observacion = (asistencia.observacion ?? '').trim();
        final estadoTexto = _estadoTexto(asistencia.estado);
        final colorEstado = _colorEstado(asistencia.estado);

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
              backgroundColor: colorEstado.withOpacity(0.15),
              child: Icon(
                Icons.person,
                color: colorEstado,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de asistencias'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _asistencias.isEmpty
          ? _estadoVacio()
          : Column(
              children: [
                _encabezado(),
                Expanded(
                  child: _listaAsistencias(),
                ),
              ],
            ),
    );
  }
}

