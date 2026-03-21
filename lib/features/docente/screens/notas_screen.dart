import 'package:flutter/material.dart';
import 'package:app_academica_offline/features/docente/models/nota_model.dart';
import 'package:app_academica_offline/features/estudiantes/models/estudiante_model.dart';
import 'package:app_academica_offline/services/local/estudiante_local_store.dart';
import 'package:app_academica_offline/services/local/nota_local_store.dart';

class NotasScreen extends StatefulWidget {
  final String asignaturaId;
  final String nombreAsignatura;

  const NotasScreen({
    super.key,
    required this.asignaturaId,
    required this.nombreAsignatura,
  });

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  final EstudianteLocalStore _estudianteStore = EstudianteLocalStore();
  final NotaLocalStore _notaStore = NotaLocalStore();

  List<Estudiante> estudiantes = [];
  Map<String, TextEditingController> notasControllers = {};
  Map<String, TextEditingController> observacionControllers = {};

  DateTime fechaSeleccionada = DateTime.now();
  String tipoSeleccionado = 'tarea';

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

  String _generarId(
    String asignaturaId,
    String estudianteId,
    String fecha,
    String tipo,
  ) {
    return '${asignaturaId}_${estudianteId}_${fecha}_$tipo';
  }

  Future<void> _cargarDatos() async {
    setState(() => cargando = true);

    final listaEstudiantes =
        _estudianteStore.getByAsignatura(widget.asignaturaId);

    final fechaTexto = _formatearFecha(fechaSeleccionada);

    final notasGuardadas = _notaStore.getByAsignaturaFechaTipo(
      widget.asignaturaId,
      fechaTexto,
      tipoSeleccionado,
    );

    final Map<String, TextEditingController> nuevosNotasControllers = {};
    final Map<String, TextEditingController> nuevosObservacionControllers = {};

    for (final estudiante in listaEstudiantes) {
      Nota? notaExistente;

      try {
        notaExistente = notasGuardadas.firstWhere(
          (n) => n.estudianteId == estudiante.id,
        );
      } catch (_) {
        notaExistente = null;
      }

      nuevosNotasControllers[estudiante.id] = TextEditingController(
        text: notaExistente != null ? notaExistente.nota.toString() : '',
      );

      nuevosObservacionControllers[estudiante.id] = TextEditingController(
        text: notaExistente?.observacion ?? '',
      );
    }

    for (final c in notasControllers.values) {
      c.dispose();
    }
    for (final c in observacionControllers.values) {
      c.dispose();
    }

    setState(() {
      estudiantes = listaEstudiantes;
      notasControllers = nuevosNotasControllers;
      observacionControllers = nuevosObservacionControllers;
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

  Future<void> _guardarNotas() async {
    if (estudiantes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay estudiantes en esta asignatura')),
      );
      return;
    }

    final fechaTexto = _formatearFecha(fechaSeleccionada);
    final List<Nota> notasAGuardar = [];

    for (final estudiante in estudiantes) {
      final textoNota = notasControllers[estudiante.id]?.text.trim() ?? '';
      final textoObs =
          observacionControllers[estudiante.id]?.text.trim() ?? '';

      if (textoNota.isEmpty) {
        continue;
      }

      final valor = double.tryParse(textoNota);

      if (valor == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La nota de ${estudiante.nombre} no es válida'),
          ),
        );
        return;
      }

      if (valor < 0 || valor > 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'La nota de ${estudiante.nombre} debe estar entre 0 y 10',
            ),
          ),
        );
        return;
      }

      notasAGuardar.add(
        Nota(
          id: _generarId(
            widget.asignaturaId,
            estudiante.id,
            fechaTexto,
            tipoSeleccionado,
          ),
          asignaturaId: widget.asignaturaId,
          estudianteId: estudiante.id,
          fecha: fechaTexto,
          tipo: tipoSeleccionado,
          nota: valor,
          observacion: textoObs.isEmpty ? null : textoObs,
        ),
      );
    }

    if (notasAGuardar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese al menos una nota para guardar'),
        ),
      );
      return;
    }

    setState(() => guardando = true);

    try {
      await _notaStore.upsertMany(notasAGuardar);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notas guardadas correctamente')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar notas: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => guardando = false);
      }
    }
  }

  @override
  void dispose() {
    for (final c in notasControllers.values) {
      c.dispose();
    }
    for (final c in observacionControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildEstudianteCard(Estudiante estudiante) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            TextField(
              controller: notasControllers[estudiante.id],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Nota',
                border: OutlineInputBorder(),
                hintText: 'Ej: 8.50',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: observacionControllers[estudiante.id],
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
        title: Text('Notas - ${widget.nombreAsignatura}'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        child: ListTile(
                          title: const Text('Fecha'),
                          subtitle: Text(fechaTexto),
                          trailing: IconButton(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: _seleccionarFecha,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: tipoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de nota',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'tarea',
                            child: Text('Tarea'),
                          ),
                          DropdownMenuItem(
                            value: 'examen',
                            child: Text('Examen'),
                          ),
                          DropdownMenuItem(
                            value: 'final',
                            child: Text('Nota Final'),
                          ),
                        ],
                        onChanged: (value) async {
                          setState(() {
                            tipoSeleccionado = value ?? 'tarea';
                          });
                          await _cargarDatos();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: estudiantes.isEmpty
                      ? const Center(
                          child: Text('No hay estudiantes registrados'),
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
                      onPressed: guardando ? null : _guardarNotas,
                      child: guardando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar notas'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}