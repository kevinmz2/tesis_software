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
  State<EstudiantesHomeScreen> createState() => _EstudiantesHomeScreenState();
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
    final String asignaturaId = (widget.asignatura['id'] ?? '').toString();

    final lista = _repository.getByAsignatura(asignaturaId).toList()
      ..sort((a, b) {
        final apellidoA = a.apellidos.trim().toLowerCase();
        final apellidoB = b.apellidos.trim().toLowerCase();
        final cmpApellido = apellidoA.compareTo(apellidoB);
        if (cmpApellido != 0) return cmpApellido;

        final nombreA = a.nombres.trim().toLowerCase();
        final nombreB = b.nombres.trim().toLowerCase();
        return nombreA.compareTo(nombreB);
      });

    setState(() {
      _estudiantes = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nombreAsignatura =
        (widget.asignatura['nombre'] ?? '').toString();
    final cursoAsignatura =
        (widget.asignatura['curso'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        title: Text('Estudiantes - $nombreAsignatura'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asignatura: $nombreAsignatura',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Curso: $cursoAsignatura',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total de estudiantes: ${_estudiantes.length}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _estudiantes.isEmpty ? _estadoVacio() : _listaEstudiantes(),
          ),
        ],
      ),
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
        final nombreCompleto = estudiante.nombreCompleto.trim().isEmpty
            ? estudiante.nombres
            : estudiante.nombreCompleto;

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
            title: Text(
              '${index + 1}. $nombreCompleto',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (estudiante.edad > 0)
                  Text('Edad: ${estudiante.edad}'),
                if (estudiante.tipoSangre.trim().isNotEmpty)
                  Text('Tipo de sangre: ${estudiante.tipoSangre}'),
                if (estudiante.celular.trim().isNotEmpty)
                  Text('Celular: ${estudiante.celular}'),
              ],
            ),
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
                      'nombre': nombreCompleto,
                      'nombres': estudiante.nombres,
                      'apellidos': estudiante.apellidos,
                      'edad': estudiante.edad,
                      'celular': estudiante.celular,
                      'tipoSangre': estudiante.tipoSangre,
                      'contactoEmergenciaNombre':
                          estudiante.contactoEmergenciaNombre,
                      'contactoEmergenciaCelular':
                          estudiante.contactoEmergenciaCelular,
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

    if (nuevo == null) return;

    final String asignaturaId = (widget.asignatura['id'] ?? '').toString();
    final String cursoAsignatura =
        (widget.asignatura['curso'] ?? '').toString();

    final estudiante = Estudiante(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombres: (nuevo['nombres'] ?? '').toString(),
      apellidos: (nuevo['apellidos'] ?? '').toString(),
      edad: int.tryParse((nuevo['edad'] ?? '0').toString()) ?? 0,
      celular: (nuevo['celular'] ?? '').toString(),
      tipoSangre: (nuevo['tipoSangre'] ?? '').toString(),
      contactoEmergenciaNombre:
          (nuevo['contactoEmergenciaNombre'] ?? '').toString(),
      contactoEmergenciaCelular:
          (nuevo['contactoEmergenciaCelular'] ?? '').toString(),
      curso: cursoAsignatura,
      asignaturaId: asignaturaId,
    );

    await _repository.save(estudiante);
    _cargarEstudiantes();
  }

  Future<void> _editarEstudiante(Estudiante actual) async {
    final editado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EstudianteFormScreen(
          estudiante: {
            'nombres': actual.nombres,
            'apellidos': actual.apellidos,
            'edad': actual.edad,
            'celular': actual.celular,
            'tipoSangre': actual.tipoSangre,
            'contactoEmergenciaNombre': actual.contactoEmergenciaNombre,
            'contactoEmergenciaCelular': actual.contactoEmergenciaCelular,
          },
        ),
      ),
    );

    if (editado == null) return;

    final estudianteActualizado = Estudiante(
      id: actual.id,
      nombres: (editado['nombres'] ?? '').toString(),
      apellidos: (editado['apellidos'] ?? '').toString(),
      edad: int.tryParse((editado['edad'] ?? '0').toString()) ?? 0,
      celular: (editado['celular'] ?? '').toString(),
      tipoSangre: (editado['tipoSangre'] ?? '').toString(),
      contactoEmergenciaNombre:
          (editado['contactoEmergenciaNombre'] ?? '').toString(),
      contactoEmergenciaCelular:
          (editado['contactoEmergenciaCelular'] ?? '').toString(),
      curso: actual.curso,
      asignaturaId: actual.asignaturaId,
    );

    await _repository.save(estudianteActualizado);
    _cargarEstudiantes();
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

    if (confirmar != true) return;

    await _repository.delete(estudiante.id);
    _cargarEstudiantes();
  }
}
