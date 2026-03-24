import 'package:flutter/material.dart';
import 'package:app_academica_offline/features/docente/models/nota_model.dart';
import 'package:app_academica_offline/features/docente/models/actividad_model.dart';
import 'package:app_academica_offline/features/estudiantes/models/estudiante_model.dart';
import 'package:app_academica_offline/services/local/estudiante_local_store.dart';
import 'package:app_academica_offline/services/local/nota_local_store.dart';
import 'package:app_academica_offline/services/local/actividad_local_store.dart';

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
  final ActividadLocalStore _actividadStore = ActividadLocalStore();

  List<Estudiante> estudiantes = [];
  List<Actividad> actividades = [];

  Map<String, TextEditingController> notasControllers = {};
  Map<String, TextEditingController> observacionControllers = {};

  String? actividadSeleccionadaId;

  bool cargando = true;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Actividad? _actividadActual() {
    if (actividadSeleccionadaId == null) return null;

    try {
      return actividades.firstWhere((a) => a.id == actividadSeleccionadaId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cargarDatos() async {
    setState(() => cargando = true);

    final listaEstudiantes =
        _estudianteStore.getByAsignatura(widget.asignaturaId);

    final listaActividades =
        _actividadStore.getByAsignatura(widget.asignaturaId);

    listaActividades.sort((a, b) => b.fecha.compareTo(a.fecha));

    String? nuevaActividadSeleccionada = actividadSeleccionadaId;

    if (listaActividades.isEmpty) {
      nuevaActividadSeleccionada = null;
    } else {
      final existe = listaActividades.any(
        (a) => a.id == nuevaActividadSeleccionada,
      );

      if (!existe) {
        nuevaActividadSeleccionada = listaActividades.first.id;
      }
    }

    List<Nota> notasGuardadas = [];

    if (nuevaActividadSeleccionada != null) {
      notasGuardadas = _notaStore.getByActividad(nuevaActividadSeleccionada);
    }

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
      actividades = listaActividades;
      actividadSeleccionadaId = nuevaActividadSeleccionada;
      notasControllers = nuevosNotasControllers;
      observacionControllers = nuevosObservacionControllers;
      cargando = false;
    });
  }

  Future<void> _guardarNotas() async {
    if (estudiantes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay estudiantes en esta asignatura')),
      );
      return;
    }

    final actividad = _actividadActual();

    if (actividad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar una actividad'),
        ),
      );
      return;
    }

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

      if (valor < 0 || valor > actividad.puntajeMaximo) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'La nota de ${estudiante.nombre} debe estar entre 0 y ${actividad.puntajeMaximo}',
            ),
          ),
        );
        return;
      }

      notasAGuardar.add(
        Nota(
          id: '${actividad.id}_${estudiante.id}',
          asignaturaId: widget.asignaturaId,
          estudianteId: estudiante.id,
          fecha: actividad.fecha,
          tipo: actividad.tipo,
          nota: valor,
          observacion: textoObs.isEmpty ? null : textoObs,
          actividadId: actividad.id,
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
            TextField(
              controller: notasControllers[estudiante.id],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Nota',
                border: OutlineInputBorder(),
                hintText: 'Ej: 8.50',
              ),
            ),
            const SizedBox(height: 12),
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
    final actividad = _actividadActual();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notas - ${widget.nombreAsignatura}'),
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
                  child: Column(
                    children: [
                      if (actividades.isEmpty)
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const ListTile(
                            title: Text('No hay actividades registradas'),
                            subtitle: Text(
                              'Primero debe crear una actividad para registrar notas',
                            ),
                          ),
                        )
                      else ...[
                        DropdownButtonFormField<String>(
                          key: ValueKey(actividadSeleccionadaId),
                          initialValue: actividadSeleccionadaId,
                          decoration: const InputDecoration(
                            labelText: 'Actividad',
                            border: OutlineInputBorder(),
                          ),
                          items: actividades.map((actividadItem) {
                            return DropdownMenuItem(
                              value: actividadItem.id,
                              child: Text(
                                '${actividadItem.titulo} (${_tipoTexto(actividadItem.tipo)})',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            setState(() {
                              actividadSeleccionadaId = value;
                            });
                            await _cargarDatos();
                          },
                        ),
                        const SizedBox(height: 12),
                        if (actividad != null)
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              title: Text(
                                actividad.titulo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Tipo: ${_tipoTexto(actividad.tipo)}\n'
                                'Fecha: ${actividad.fecha}\n'
                                'Puntaje máximo: ${actividad.puntajeMaximo}',
                              ),
                              isThreeLine: true,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: actividades.isEmpty
                      ? const Center(
                          child: Text('No hay actividades para calificar'),
                        )
                      : estudiantes.isEmpty
                          ? const Center(
                              child: Text('No hay estudiantes registrados'),
                            )
                          : ListView.builder(
                              itemCount: estudiantes.length,
                              itemBuilder: (context, index) {
                                return _buildEstudianteCard(
                                  estudiantes[index],
                                );
                              },
                            ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: guardando ? null : _guardarNotas,
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
                              'Guardar notas',
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
