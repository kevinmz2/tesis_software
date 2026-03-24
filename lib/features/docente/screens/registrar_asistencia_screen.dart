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

  Future<void> _cargarDatos() async {
    setState(() => cargando = true);

    debugPrint('========== REGISTRAR ASISTENCIA ==========');
    debugPrint('ASIGNATURA ID RECIBIDO: ${widget.asignaturaId}');
    debugPrint('NOMBRE ASIGNATURA: ${widget.nombreAsignatura}');

    final todosLosEstudiantes = _estudianteStore.getAll();
    debugPrint('TOTAL ESTUDIANTES GUARDADOS: ${todosLosEstudiantes.length}');

    for (final e in todosLosEstudiantes) {
      debugPrint(
        'ESTUDIANTE => id: ${e.id}, nombre: ${e.nombre}, curso: ${e.curso}, asignaturaId: ${e.asignaturaId}',
      );
    }

    final listaEstudiantes =
        _estudianteStore.getByAsignatura(widget.asignaturaId);

    debugPrint(
      'TOTAL ESTUDIANTES FILTRADOS POR ASIGNATURA: ${listaEstudiantes.length}',
    );

    final fechaTexto = _formatearFecha(fechaSeleccionada);

    final asistenciasGuardadas = _asistenciaStore.getByAsignaturaAndFecha(
      widget.asignaturaId,
      fechaTexto,
    );

    debugPrint(
      'TOTAL ASISTENCIAS GUARDADAS PARA ESTA FECHA: ${asistenciasGuardadas.length}',
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay estudiantes en esta asignatura')),
      );
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

      final verificadas = _asistenciaStore.getByAsignaturaAndFecha(
        widget.asignaturaId,
        fechaTexto,
      );

      debugPrint(
        'TOTAL ASISTENCIAS GUARDADAS DESPUÉS DE SAVE: ${verificadas.length}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asistencia guardada correctamente')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar asistencia: $e')),
      );
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
    return DropdownButtonFormField<String>(
      initialValue: estados[estudianteId] ?? 'presente',
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

  Widget _buildEstudianteCard(Estudiante estudiante) {
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
            Text(
              estudiante.nombre,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildEstadoDropdown(estudiante.id),
            const SizedBox(height: 12),
            TextField(
              controller: observaciones[estudiante.id],
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
    final fechaTexto = _formatearFecha(fechaSeleccionada);

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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      title: const Text('Fecha de asistencia'),
                      subtitle: Text(fechaTexto),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: _seleccionarFecha,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: estudiantes.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay estudiantes registrados para esta asignatura',
                          ),
                        )
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

