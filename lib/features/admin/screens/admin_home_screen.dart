import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_academica_offline/features/admin/models/docente_model.dart';
import 'package:app_academica_offline/features/admin/repositories/docente_repository.dart';
import 'package:app_academica_offline/services/auth/session_local_service.dart';
import 'docente_form_screen.dart';
import 'docente_detail_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final SessionLocalService _sessionLocalService = SessionLocalService();
  final DocenteRepository _docenteRepository = DocenteRepository();

  List<Docente> _docentes = [];
  bool _cargando = true;
  String _nombreAdmin = 'Administrador';

  @override
  void initState() {
    super.initState();
    _inicializarPantalla();
  }

  Future<void> _inicializarPantalla() async {
    await _cargarNombreAdmin();
    await _cargarDocentes();
  }

  Future<void> _cargarNombreAdmin() async {
    final nombreLocal = await _sessionLocalService.obtenerNombre();
    final nombre = (nombreLocal ?? '').trim();

    if (!mounted) return;

    setState(() {
      _nombreAdmin = nombre.isEmpty ? 'Administrador' : nombre;
    });
  }

  Future<void> _cargarDocentes() async {
    final docentes = _docenteRepository.getAll();

    if (!mounted) return;

    setState(() {
      _docentes = docentes;
      _cargando = false;
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

  Future<void> _abrirFormulario({Docente? docenteExistente}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DocenteFormScreen(docente: docenteExistente),
      ),
    );

    if (resultado == true) {
      await _cargarDocentes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            docenteExistente == null
                ? 'Docente guardado correctamente'
                : 'Docente actualizado correctamente',
          ),
        ),
      );
    }
  }

  Future<void> _abrirDetalle(Docente docente) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocenteDetailScreen(docente: docente),
      ),
    );
  }

  Future<void> _confirmarEliminar(Docente docente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar docente'),
        content: Text(
          '¿Está seguro que desea eliminar a ${docente.nombre}?',
        ),
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
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await _docenteRepository.delete(docente.id);
    await _cargarDocentes();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Docente eliminado correctamente')),
    );
  }

  Future<void> _cambiarEstado(Docente docente) async {
    await _docenteRepository.cambiarEstado(
      id: docente.id,
      activo: !docente.activo,
    );

    await _cargarDocentes();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          docente.activo
              ? 'Docente desactivado correctamente'
              : 'Docente activado correctamente',
        ),
      ),
    );
  }

  Widget _estadoVacio() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Icon(
          Icons.people_outline,
          size: 80,
          color: Colors.grey,
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            'No hay docentes registrados',
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(height: 8),
        Center(
          child: Text(
            'Presione + para agregar un docente',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _listaDocentes() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _docentes.length,
      itemBuilder: (context, index) {
        final docente = _docentes[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            leading: CircleAvatar(
              backgroundColor: docente.activo
                  ? Colors.deepPurple.shade100
                  : Colors.grey.shade300,
              child: Icon(
                Icons.person,
                color: docente.activo
                    ? Colors.deepPurple.shade700
                    : Colors.grey.shade700,
              ),
            ),
            title: Text(
              docente.nombre,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(docente.correo),
                const SizedBox(height: 4),
                Text(
                  docente.institucionNombre.isEmpty
                      ? 'Sin institución'
                      : docente.institucionNombre,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: docente.activo
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    docente.activo ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: docente.activo
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () => _abrirDetalle(docente),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'ver') {
                  await _abrirDetalle(docente);
                } else if (value == 'editar') {
                  await _abrirFormulario(docenteExistente: docente);
                } else if (value == 'estado') {
                  await _cambiarEstado(docente);
                } else if (value == 'eliminar') {
                  await _confirmarEliminar(docente);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'ver',
                  child: Text('Ver detalle'),
                ),
                const PopupMenuItem(
                  value: 'editar',
                  child: Text('Editar'),
                ),
                PopupMenuItem(
                  value: 'estado',
                  child: Text(
                    docente.activo ? 'Desactivar' : 'Activar',
                  ),
                ),
                const PopupMenuItem(
                  value: 'eliminar',
                  child: Text('Eliminar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de administrador'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDocentes,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido, $_nombreAdmin',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Administre los docentes registrados localmente',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _docentes.isEmpty
                      ? _estadoVacio()
                      : _listaDocentes(),
            ),
          ],
        ),
      ),
    );
  }
}
