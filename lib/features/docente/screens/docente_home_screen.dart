import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_academica_offline/services/auth/session_local_service.dart';
import 'package:app_academica_offline/features/docente/models/asignatura_model.dart';
import 'package:app_academica_offline/features/docente/repositories/asignatura_repository.dart';
import 'package:app_academica_offline/features/docente/screens/asignatura_form_screen.dart';
import 'package:app_academica_offline/features/docente/screens/asignatura_detail_screen.dart';

class DocenteHomeScreen extends StatefulWidget {
  const DocenteHomeScreen({super.key});

  @override
  State<DocenteHomeScreen> createState() => _DocenteHomeScreenState();
}

class _DocenteHomeScreenState extends State<DocenteHomeScreen> {
  final AsignaturaRepository _repository = AsignaturaRepository();
  final SessionLocalService _sessionLocalService = SessionLocalService();

  List<Asignatura> _asignaturas = [];
  String _nombreDocente = 'Docente';
  String _correoDocenteActual = '';

  @override
  void initState() {
    super.initState();
    _inicializarPantalla();
  }

  Future<void> _inicializarPantalla() async {
    final emailLocal = await _sessionLocalService.obtenerEmail();
    final nombreLocal = await _sessionLocalService.obtenerNombre();

    if (!mounted) return;

    setState(() {
      _correoDocenteActual = (emailLocal ?? '').trim();
      _nombreDocente = (nombreLocal ?? 'Docente').trim().isEmpty
          ? 'Docente'
          : nombreLocal!.trim();
    });

    _cargarAsignaturas();
  }

  void _cargarAsignaturas() {
    setState(() {
      _asignaturas = _repository.getByDocenteId(_correoDocenteActual);
    });
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await _sessionLocalService.limpiarSesion();
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del docente'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
          ),
        ],
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
                  'Bienvenido, $_nombreDocente',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mis asignaturas',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _asignaturas.isEmpty ? _estadoVacio() : _listaAsignaturas(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.menu_book, color: Colors.white),
        label: const Text(
          'Agregar asignatura',
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
          Icon(Icons.menu_book_outlined, size: 90, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No tiene asignaturas registradas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1C1C1C),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Presione el botón para agregar una asignatura',
            style: TextStyle(color: Color(0xFF4A4A4A)),
          ),
        ],
      ),
    );
  }

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
            title: Text(
              asignatura.nombre,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1C),
              ),
            ),
            subtitle: Text(
              'Curso: ${asignatura.curso}',
              style: const TextStyle(
                color: Color(0xFF4A4A4A),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit, color: Colors.deepPurple),
                  onPressed: () => _editarAsignatura(asignatura),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _eliminarAsignatura(asignatura),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AsignaturaDetailScreen(
                    asignatura: {
                      'id': asignatura.id,
                      'nombre': asignatura.nombre,
                      'curso': asignatura.curso,
                      'docente': _nombreDocente,
                      'numeroEstudiantes': asignatura.numeroEstudiantes,
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
    final nuevaAsignatura = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AsignaturaFormScreen(),
      ),
    );

    if (nuevaAsignatura != null) {
      final asignatura = Asignatura(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: (nuevaAsignatura['nombre'] ?? '').toString(),
        curso: (nuevaAsignatura['curso'] ?? '').toString(),
        docenteId: _correoDocenteActual,
        numeroEstudiantes: _leerNumeroEstudiantes(nuevaAsignatura),
      );

      await _repository.save(asignatura);
      _cargarAsignaturas();
    }
  }

  Future<void> _editarAsignatura(Asignatura actual) async {
    final editada = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AsignaturaFormScreen(
          asignatura: {
            'nombre': actual.nombre,
            'curso': actual.curso,
            'docente': _nombreDocente,
            'numeroEstudiantes': actual.numeroEstudiantes,
          },
        ),
      ),
    );

    if (editada != null) {
      final asignaturaActualizada = Asignatura(
        id: actual.id,
        nombre: (editada['nombre'] ?? '').toString(),
        curso: (editada['curso'] ?? '').toString(),
        docenteId: actual.docenteId,
        numeroEstudiantes: _leerNumeroEstudiantes(editada),
      );

      await _repository.save(asignaturaActualizada);
      _cargarAsignaturas();
    }
  }

  Future<void> _eliminarAsignatura(Asignatura asignatura) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text(
          '¿Está seguro que desea eliminar esta asignatura?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NO'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SÍ'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _repository.delete(asignatura.id);
      _cargarAsignaturas();
    }
  }

  int _leerNumeroEstudiantes(Map<String, dynamic> data) {
    final valor = data['numeroEstudiantes'] ?? data['estudiantes'] ?? 0;
    if (valor is int) return valor;
    return int.tryParse(valor.toString()) ?? 0;
  }
}

