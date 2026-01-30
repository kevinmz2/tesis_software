import 'package:flutter/material.dart';
import 'estudiante_form_screen.dart';
import 'estudiante_detail_screen.dart';

class EstudiantesHomeScreen extends StatefulWidget {
  const EstudiantesHomeScreen({super.key});

  @override
  State<EstudiantesHomeScreen> createState() =>
      _EstudiantesHomeScreenState();
}

class _EstudiantesHomeScreenState extends State<EstudiantesHomeScreen> {
  final List<Map<String, dynamic>> _estudiantes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudiantes'),
      ),

      body: _estudiantes.isEmpty
          ? _estadoVacio()
          : _listaEstudiantes(),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Agregar estudiante'),
        onPressed: _abrirFormulario,
      ),
    );
  }

  /// ---------------------------
  /// ESTADO VACÍO
  /// ---------------------------
  Widget _estadoVacio() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school, size: 80),
          SizedBox(height: 16),
          Text(
            'No hay estudiantes registrados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text('Presione el botón para agregar estudiantes'),
        ],
      ),
    );
  }

  /// ---------------------------
  /// LISTA DE ESTUDIANTES
  /// ---------------------------
  Widget _listaEstudiantes() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _estudiantes.length,
      itemBuilder: (context, index) {
        final estudiante = _estudiantes[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(estudiante['nombre']),
            subtitle: Text(
              'Curso: ${estudiante['curso']}',
            ),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editarEstudiante(index),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _eliminarEstudiante(index),
                ),
              ],
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EstudianteDetailScreen(estudiante: estudiante),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// ---------------------------
  /// CREAR
  /// ---------------------------
  Future<void> _abrirFormulario() async {
    final nuevo = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EstudianteFormScreen(),
      ),
    );

    if (nuevo != null) {
      setState(() {
        _estudiantes.add(nuevo);
      });
    }
  }

  /// ---------------------------
  /// EDITAR
  /// ---------------------------
  Future<void> _editarEstudiante(int index) async {
    final actual = _estudiantes[index];

    final editado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EstudianteFormScreen(estudiante: actual),
      ),
    );

    if (editado != null) {
      setState(() {
        _estudiantes[index] = editado;
      });
    }
  }

  /// ---------------------------
  /// ELIMINAR
  /// ---------------------------
  void _eliminarEstudiante(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text(
          '¿Está seguro que desea eliminar este estudiante?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _estudiantes.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('SÍ'),
          ),
        ],
      ),
    );
  }
}
