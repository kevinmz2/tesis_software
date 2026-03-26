import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_academica_offline/services/auth/session_local_service.dart';
import 'package:app_academica_offline/services/local/estudiante_local_store.dart';
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
  final EstudianteLocalStore _estudianteLocalStore = EstudianteLocalStore();

  List<Asignatura> _asignaturas = [];
  String _nombreDocente = 'Docente';
  String _correoDocenteActual = '';
  String _docenteIdActual = '';

  @override
  void initState() {
    super.initState();
    _inicializarPantalla();
  }

  Future<void> _inicializarPantalla() async {
    final emailLocal = await _sessionLocalService.obtenerEmail();
    final nombreLocal = await _sessionLocalService.obtenerNombre();
    final uidActual = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (!mounted) return;

    setState(() {
      _correoDocenteActual = (emailLocal ?? '').trim();
      _docenteIdActual = uidActual.trim();
      _nombreDocente = (nombreLocal ?? 'Docente').trim().isEmpty
          ? 'Docente'
          : nombreLocal!.trim();
    });

    _cargarAsignaturas();
  }

  void _cargarAsignaturas() {
    final Map<String, Asignatura> mapa = {};

    if (_docenteIdActual.isNotEmpty) {
      final porUid = _repository.getByDocenteId(_docenteIdActual);
      for (final asignatura in porUid) {
        if (asignatura.activo) {
          mapa[asignatura.id] = asignatura;
        }
      }
    }

    if (_correoDocenteActual.isNotEmpty &&
        _correoDocenteActual != _docenteIdActual) {
      final porCorreo = _repository.getByDocenteId(_correoDocenteActual);
      for (final asignatura in porCorreo) {
        if (asignatura.activo) {
          mapa[asignatura.id] = asignatura;
        }
      }
    }

    final lista = mapa.values.toList()
      ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

    setState(() {
      _asignaturas = lista;
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

  Future<void> _abrirFormulario() async {
    final nuevaAsignatura = await Navigator.push<Asignatura>(
      context,
      MaterialPageRoute(
        builder: (_) => const AsignaturaFormScreen(),
      ),
    );

    if (nuevaAsignatura == null) return;

    final docenteIdReal = _docenteIdActual.isNotEmpty
        ? _docenteIdActual
        : _correoDocenteActual;

    final asignatura = nuevaAsignatura.copyWith(
      docenteId: docenteIdReal,
      docenteNombre: _nombreDocente,
    );

    await _repository.save(asignatura);
    _cargarAsignaturas();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Asignatura guardada correctamente'),
      ),
    );
  }

  Future<void> _editarAsignatura(Asignatura actual) async {
    final editada = await Navigator.push<Asignatura>(
      context,
      MaterialPageRoute(
        builder: (_) => AsignaturaFormScreen(
          asignatura: actual,
        ),
      ),
    );

    if (editada == null) return;

    final asignaturaActualizada = editada.copyWith(
      id: actual.id,
      docenteId: actual.docenteId,
      docenteNombre: actual.docenteNombre.isEmpty
          ? _nombreDocente
          : actual.docenteNombre,
    );

    await _repository.save(asignaturaActualizada);
    _cargarAsignaturas();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Asignatura actualizada correctamente'),
      ),
    );
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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asignatura eliminada correctamente'),
        ),
      );
    }
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
                  'Mis asignaturas activas',
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
            'No tiene asignaturas activas registradas',
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
        final totalEstudiantes =
            _estudianteLocalStore.countByAsignatura(asignatura.id);

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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Curso: ${asignatura.curso}',
                  style: const TextStyle(
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Estudiantes: $totalEstudiantes',
                  style: const TextStyle(
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ],
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
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AsignaturaDetailScreen(
                    asignatura: asignatura,
                  ),
                ),
              );

              if (!mounted) return;
              _cargarAsignaturas();
            },
          ),
        );
      },
    );
  }
}

