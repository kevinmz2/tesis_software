import 'package:flutter/material.dart';
import 'asignatura_form_screen.dart';
import 'asignatura_detail_screen.dart';

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

      body: _asignaturas.isEmpty
          ? _estadoVacio()
          : _listaAsignaturas(),

      /// BOTÓN AGREGAR MÁS VISIBLE
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple.shade700,
        icon: const Icon(Icons.menu_book),
        label: const Text(
          'Agregar asignatura',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: _abrirFormulario,
      ),
    );
  }

  /// ---------------------------
  /// ESTADO VACÍO
  /// ---------------------------
  Widget _estadoVacio() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 90,
            color: Colors.deepPurple.shade200,
          ),
          const SizedBox(height: 16),
          const Text(
            'No tiene asignaturas registradas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Presione el botón para agregar una asignatura',
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
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.book),
            title: Text(asignatura['nombre']),
            subtitle: Text('Curso: ${asignatura['curso']}'),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Editar',
                  icon: Icon(
                    Icons.edit,
                    color: Colors.deepPurple.shade600,
                  ),
                  onPressed: () => _editarAsignatura(index),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _eliminarAsignatura(index),
                ),
              ],
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AsignaturaDetailScreen(asignatura: asignatura),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// ---------------------------
  /// FORMULARIO NUEVO
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
  /// EDITAR
  /// ---------------------------
  Future<void> _editarAsignatura(int index) async {
    final actual = _asignaturas[index];

    final editada = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AsignaturaFormScreen(asignatura: actual),
      ),
    );

    if (editada != null) {
      setState(() {
        _asignaturas[index] = editada;
      });
    }
  }

  /// ---------------------------
  /// ELIMINAR
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
              //colores
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
