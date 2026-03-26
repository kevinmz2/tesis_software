import 'package:flutter/material.dart';
import 'package:app_academica_offline/services/local/asistencia_local_store.dart';
import 'package:app_academica_offline/services/local/estudiante_local_store.dart';
import 'package:app_academica_offline/features/docente/models/asistencia_model.dart';
import 'package:app_academica_offline/features/estudiantes/models/estudiante_model.dart';

class RegistrarAsistenciaScreen extends StatefulWidget {
  final String asignaturaId;
  final String nombreAsignatura;

  const RegistrarAsistenciaScreen({
    super.key,
    required this.asignaturaId,
    required this.nombreAsignatura,
  });

  @override
  State<RegistrarAsistenciaScreen> createState() =>
      _RegistrarAsistenciaScreenState();
}

class _RegistrarAsistenciaScreenState
    extends State<RegistrarAsistenciaScreen> {
  final EstudianteLocalStore _estudianteStore = EstudianteLocalStore();
  final AsistenciaLocalStore _asistenciaStore = AsistenciaLocalStore();

  List<Estudiante> estudiantes = [];
  Map<String, String> estados = {};
  Map<String, TextEditingController> observaciones = {};

  DateTime fechaSeleccionada = DateTime.now();
  bool cargando = true;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  String _formatearFecha(DateTime fecha) {
    final year = fecha.year.toString();
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _generarId(String asignaturaId, String estudianteId, String fecha) {
    return '${asignaturaId}_${estudianteId}_$fecha';
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

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  Future<void> _cargarDatos() async {
    setState(() => cargando = true);

    final listaEstudiantes =
        _estudianteStore.getByAsignatura(widget.asignaturaId);

    listaEstudiantes.sort(
      (a, b) => a.nombres.toLowerCase().compareTo(b.nombres.toLowerCase()),
    );

    final fechaTexto = _formatearFecha(fechaSeleccionada);

    final asistenciasGuardadas = _asistenciaStore.getByAsignaturaAndFecha(
      widget.asignaturaId,
      fechaTexto,
    );

    final Map<String, String> nuevosEstados = {};
    final Map<String, TextEditingController> nuevasObservaciones = {};

    for (final estudiante in listaEstudiantes) {
      Asistencia? asistenciaExistente;

      try {
        asistenciaExistente = asistenciasGuardadas.firstWhere(
          (a) => a.estudianteId == estudiante.id,
        );
      } catch (_) {
        asistenciaExistente = null;
      }

      nuevosEstados[estudiante.id] = asistenciaExistente?.estado ?? 'presente';
      nuevasObservaciones[estudiante.id] = TextEditingController(
        text: asistenciaExistente?.observacion ?? '',
      );
    }

    for (final controller in observaciones.values) {
      controller.dispose();
    }

    setState(() {
      estudiantes = listaEstudiantes;
      estados = nuevosEstados;
      observaciones = nuevasObservaciones;
      cargando = false;
    });
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        fechaSeleccionada = picked;
      });
      await _cargarDatos();
    }
  }

  Future<void> _guardarAsistencia() async {
    if (estudiantes.isEmpty) {
      _mostrarMensaje('No hay estudiantes en esta asignatura');
      return;
    }

    setState(() => guardando = true);

    try {
      final fechaTexto = _formatearFecha(fechaSeleccionada);

      final asistencias = estudiantes.map((estudiante) {
        final textoObservacion =
            observaciones[estudiante.id]?.text.trim() ?? '';

        return Asistencia(
          id: _generarId(widget.asignaturaId, estudiante.id, fechaTexto),
          asignaturaId: widget.asignaturaId,
          estudianteId: estudiante.id,
          fecha: fechaTexto,
          estado: estados[estudiante.id] ?? 'presente',
          observacion: textoObservacion.isEmpty ? null : textoObservacion,
        );
      }).toList();

      await _asistenciaStore.upsertMany(asistencias);

      if (!mounted) return;
      _mostrarMensaje('Asistencia guardada correctamente');
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('Error al guardar asistencia: $e');
    } finally {
      if (mounted) {
        setState(() => guardando = false);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in observaciones.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildEstadoDropdown(String estudianteId) {
    final estadoActual = estados[estudianteId] ?? 'presente';

    return DropdownButtonFormField<String>(
      value: estadoActual,
      decoration: const InputDecoration(
        labelText: 'Estado',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: 'presente',
          child: Text('Presente'),
        ),
        DropdownMenuItem(
          value: 'ausente',
          child: Text('Ausente'),
        ),
        DropdownMenuItem(
          value: 'atraso',
          child: Text('Atraso'),
        ),
        DropdownMenuItem(
          value: 'justificado',
          child: Text('Justificado'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          estados[estudianteId] = value ?? 'presente';
        });
      },
    );
  }

  Widget _encabezado() {
    final fechaTexto = _formatearFecha(fechaSeleccionada);

    return Padding(
      padding: const EdgeInsets.all(16),
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
              Text(
                'Estudiantes: ${estudiantes.length}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _seleccionarFecha,
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: const Text('Fecha de asistencia'),
                    subtitle: Text(fechaTexto),
                    trailing: const Icon(Icons.calendar_month),
                  ),
                ),
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
          Icon(Icons.people_outline, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay estudiantes registrados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Primero debe agregar estudiantes a esta asignatura',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildEstudianteCard(Estudiante estudiante) {
    final estadoActual = estados[estudiante.id] ?? 'presente';
    final colorEstado = _colorEstado(estadoActual);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorEstado.withOpacity(0.15),
                  child: Icon(
                    Icons.person,
                    color: colorEstado,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    estudiante.nombres,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _estadoTexto(estadoActual),
                  style: TextStyle(
                    color: colorEstado,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildEstadoDropdown(estudiante.id),
            const SizedBox(height: 12),
            TextField(
              controller: observaciones[estudiante.id],
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Observación',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asistencia - ${widget.nombreAsignatura}'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _encabezado(),
                Expanded(
                  child: estudiantes.isEmpty
                      ? _estadoVacio()
                      : ListView.builder(
                          itemCount: estudiantes.length,
                          itemBuilder: (context, index) {
                            return _buildEstudianteCard(estudiantes[index]);
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: guardando ? null : _guardarAsistencia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: guardando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Guardar asistencia',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

