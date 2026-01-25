import 'package:flutter/material.dart';
import 'asignatura_form_screen.dart';
import 'asignatura_detail_screen.dart'; // para mostrar los detalles de la asignatura


class DocenteHomeScreen extends StatefulWidget {
  const DocenteHomeScreen({super.key});

  @override
  State<DocenteHomeScreen> createState() => _DocenteHomeScreenState();
}

class _DocenteHomeScreenState extends State<DocenteHomeScreen> {
  final List<Map<String, dynamic>> _asignaturas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Asignaturas'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: _asignaturas.isEmpty ? _estadoVacio() : _listaAsignaturas(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple.shade700,
        onPressed: _abrirFormulario,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// ---------------------------
  /// CUANDO NO HAY ASIGNATURAS
  /// ---------------------------
  Widget _estadoVacio() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No tiene asignaturas registradas',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Presione + para agregar una asignatura',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  /// ---------------------------
  /// LISTA DE ASIGNATURAS
  /// ---------------------------
  Widget _listaAsignaturas() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _asignaturas.length,
      itemBuilder: (context, index) {
        final asignatura = _asignaturas[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.book),
            title: Text(asignatura['nombre']),
            subtitle: Text('Curso: ${asignatura['curso']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.deepPurple),
                  onPressed: () => _editarAsignatura(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminarAsignatura(index),
                ),
              ],
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AsignaturaDetailScreen(
                    asignatura: {
                      ...asignatura,
                      'docente': 'Docente actual',
                      'estudiantes': 30,
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

  /// ---------------------------
  /// ABRIR FORMULARIO (NUEVO)
  /// ---------------------------
  Future<void> _abrirFormulario() async {
    final nuevaAsignatura = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AsignaturaFormScreen(),
      ),
    );

    if (nuevaAsignatura != null) {
      setState(() {
        _asignaturas.add(nuevaAsignatura);
      });
    }
  }

  /// ---------------------------
  /// EDITAR ASIGNATURA
  /// ---------------------------
  Future<void> _editarAsignatura(int index) async {
    final asignaturaActual = _asignaturas[index];

    final asignaturaEditada = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AsignaturaFormScreen(
          asignatura: asignaturaActual,
        ),
      ),
    );

    if (asignaturaEditada != null) {
      setState(() {
        _asignaturas[index] = asignaturaEditada;
      });
    }
  }

  /// ---------------------------
  /// ELIMINAR ASIGNATURA
  /// ---------------------------
  void _eliminarAsignatura(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text(
          '¿Está seguro que desea eliminar esta asignatura?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () {
              setState(() {
                _asignaturas.removeAt(index);
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
