import 'package:flutter/material.dart';
import 'docente_form_screen.dart';
import 'docente_detail_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final List<Map<String, dynamic>> _docentes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Docentes'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: _docentes.isEmpty ? _estadoVacio() : _listaDocentes(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple.shade700,
        onPressed: _abrirFormulario,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// ---------------------------
  /// UI CUANDO NO HAY DOCENTES
  /// ---------------------------
  Widget _estadoVacio() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay docentes registrados',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Presione + para agregar un docente',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  /// ---------------------------
  /// LISTA DE DOCENTES
  /// ---------------------------
  Widget _listaDocentes() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _docentes.length,
      itemBuilder: (context, index) {
        final docente = _docentes[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(docente['nombre']),
            subtitle: Text(docente['institucion']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.deepPurple),
                  onPressed: () => _editarDocente(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmarEliminar(index),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DocenteDetailScreen(docente: docente),
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
    final nuevoDocente = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DocenteFormScreen(),
      ),
    );

    if (nuevoDocente != null) {
      setState(() {
        _docentes.add(nuevoDocente);
      });
    }
  }

  /// ---------------------------
  /// EDITAR DOCENTE
  /// ---------------------------
  Future<void> _editarDocente(int index) async {
    final docenteActual = _docentes[index];

    final docenteEditado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocenteFormScreen(
          docente: docenteActual,
        ),
      ),
    );

    if (docenteEditado != null) {
      setState(() {
        _docentes[index] = docenteEditado;
      });
    }
  }

  /// ---------------------------
  /// CONFIRMAR ELIMINACIÓN
  /// ---------------------------
  void _confirmarEliminar(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text(
          '¿Está seguro que desea eliminar este docente?',
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
                _docentes.removeAt(index);
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
