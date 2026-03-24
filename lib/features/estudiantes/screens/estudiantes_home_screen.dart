import 'package:flutter/material.dart';

import 'package:app_academica_offline/features/estudiantes/models/estudiante_model.dart';
import 'package:app_academica_offline/features/estudiantes/repositories/estudiante_repository.dart';
import 'package:app_academica_offline/features/estudiantes/screens/estudiante_form_screen.dart';
import 'package:app_academica_offline/features/estudiantes/screens/estudiante_detail_screen.dart';

class EstudiantesHomeScreen extends StatefulWidget {
  final Map<String, dynamic> asignatura;

  const EstudiantesHomeScreen({
    super.key,
    required this.asignatura,
  });

  @override
  State<EstudiantesHomeScreen> createState() =>
      _EstudiantesHomeScreenState();
}

class _EstudiantesHomeScreenState extends State<EstudiantesHomeScreen> {
  final EstudianteRepository _repository = EstudianteRepository();
  List<Estudiante> _estudiantes = [];

  @override
  void initState() {
    super.initState();
    _cargarEstudiantes();
  }

  void _cargarEstudiantes() {
    final String asignaturaId = (widget.asignatura['nombre'] ?? '').toString();

    setState(() {
      _estudiantes = _repository.getByAsignatura(asignaturaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final nombreAsignatura =
        (widget.asignatura['nombre'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        title: Text('Estudiantes - $nombreAsignatura'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _estudiantes.isEmpty ? _estadoVacio() : _listaEstudiantes(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Agregar estudiante',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: _abrirFormulario,
      ),
    );
  }

  Widget _estadoVacio() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay estudiantes registrados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Presione el botón para agregar estudiantes',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _listaEstudiantes() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _estudiantes.length,
      itemBuilder: (context, index) {
        final estudiante = _estudiantes[index];

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
              backgroundColor: Colors.deepPurple.shade100,
              child: Icon(
                Icons.person,
                color: Colors.deepPurple.shade700,
              ),
            ),
            title: Text(
              estudiante.nombre,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text('Curso: ${estudiante.curso}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit, color: Colors.deepPurple),
                  onPressed: () => _editarEstudiante(estudiante),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _eliminarEstudiante(estudiante),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EstudianteDetailScreen(
                    estudiante: {
                      'id': estudiante.id,
                      'nombre': estudiante.nombre,
                      'curso': estudiante.curso,
                      'asignaturaId': estudiante.asignaturaId,
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _abrirFormulario() async {
    final nuevo = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EstudianteFormScreen(),
      ),
    );

    if (nuevo != null) {
      final String asignaturaId = (widget.asignatura['nombre'] ?? '').toString();

      final estudiante = Estudiante(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nuevo['nombre'],
        curso: nuevo['curso'],
        asignaturaId: asignaturaId,
      );

      await _repository.save(estudiante);
      _cargarEstudiantes();
    }
  }

  Future<void> _editarEstudiante(Estudiante actual) async {
    final editado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EstudianteFormScreen(
          estudiante: {
            'nombre': actual.nombre,
            'curso': actual.curso,
          },
        ),
      ),
    );

    if (editado != null) {
      final estudianteActualizado = Estudiante(
        id: actual.id,
        nombre: editado['nombre'],
        curso: editado['curso'],
        asignaturaId: actual.asignaturaId,
      );

      await _repository.save(estudianteActualizado);
      _cargarEstudiantes();
    }
  }

  Future<void> _eliminarEstudiante(Estudiante estudiante) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text(
          '¿Está seguro que desea eliminar este estudiante?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NO'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SÍ'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _repository.delete(estudiante.id);
      _cargarEstudiantes();
    }
  }
}
