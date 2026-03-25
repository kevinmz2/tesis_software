import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_academica_offline/features/admin/models/docente_model.dart';
import 'package:app_academica_offline/features/admin/repositories/docente_repository.dart';
import 'package:app_academica_offline/features/docente/models/asignatura_model.dart';
import 'package:app_academica_offline/services/auth/session_local_service.dart';
import 'package:app_academica_offline/services/local/asignatura_local_store.dart';
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
  final AsignaturaLocalStore _asignaturaLocalStore = AsignaturaLocalStore();

  List<Docente> _docentes = [];
  List<Asignatura> _asignaturas = [];

  bool _cargando = true;
  String _nombreAdmin = 'Administrador';

  String _busqueda = '';
  String _filtroEstado = 'todos';
  String _filtroInstitucion = 'todas';

  String _busquedaAsignatura = '';
  String _filtroDocenteAsignatura = 'todos';

  @override
  void initState() {
    super.initState();
    _recargarDatos();
  }

  Future<void> _recargarDatos() async {
    if (mounted) {
      setState(() {
        _cargando = true;
      });
    }

    final nombreLocal = await _sessionLocalService.obtenerNombre();
    final docentes = await _docenteRepository.getAll();
    final asignaturas = _asignaturaLocalStore.getAll();

    if (!mounted) return;

    setState(() {
      _nombreAdmin = (nombreLocal ?? '').trim().isEmpty
          ? 'Administrador'
          : nombreLocal!.trim();
      _docentes = docentes;
      _asignaturas = asignaturas;
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
      await _recargarDatos();

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
    await _recargarDatos();

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

    await _recargarDatos();

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

  String _nombreDocentePorId(String docenteId) {
    for (final docente in _docentes) {
      if (docente.id.trim().toLowerCase() == docenteId.trim().toLowerCase()) {
        return docente.nombre;
      }
    }
    return '';
  }

  String _nombreDocenteAsignatura(Asignatura asignatura) {
    if (asignatura.docenteNombre.trim().isNotEmpty) {
      return asignatura.docenteNombre.trim();
    }

    final nombre = _nombreDocentePorId(asignatura.docenteId);
    return nombre.isEmpty ? 'Sin docente asignado' : nombre;
  }

  List<Asignatura> _asignaturasDeDocente(String docenteId) {
    return _asignaturas
        .where(
          (a) =>
              a.docenteId.trim().toLowerCase() ==
              docenteId.trim().toLowerCase(),
        )
        .toList();
  }

  List<String> get _institucionesDisponibles {
    final instituciones = _docentes
        .map((docente) => docente.institucionNombre.trim())
        .where((nombre) => nombre.isNotEmpty)
        .toSet()
        .toList();

    instituciones.sort();
    return instituciones;
  }

  List<Docente> get _docentesFiltrados {
    return _docentes.where((docente) {
      final textoBusqueda = _busqueda.trim().toLowerCase();

      final coincideBusqueda =
          textoBusqueda.isEmpty ||
          docente.nombre.toLowerCase().contains(textoBusqueda) ||
          docente.correo.toLowerCase().contains(textoBusqueda) ||
          docente.cedula.toLowerCase().contains(textoBusqueda) ||
          docente.institucionNombre.toLowerCase().contains(textoBusqueda);

      final coincideEstado =
          _filtroEstado == 'todos' ||
          (_filtroEstado == 'activos' && docente.activo) ||
          (_filtroEstado == 'inactivos' && !docente.activo);

      final coincideInstitucion =
          _filtroInstitucion == 'todas' ||
          docente.institucionNombre == _filtroInstitucion;

      return coincideBusqueda && coincideEstado && coincideInstitucion;
    }).toList();
  }

  List<String> get _docentesDisponiblesParaAsignaturas {
    final docentes = _asignaturas
        .map(_nombreDocenteAsignatura)
        .where((nombre) => nombre.trim().isNotEmpty)
        .toSet()
        .toList();

    docentes.sort();
    return docentes;
  }

  List<Asignatura> get _asignaturasFiltradas {
    return _asignaturas.where((asignatura) {
      final texto = _busquedaAsignatura.trim().toLowerCase();
      final docenteNombre = _nombreDocenteAsignatura(asignatura).toLowerCase();

      final coincideBusqueda =
          texto.isEmpty ||
          asignatura.nombre.toLowerCase().contains(texto) ||
          asignatura.curso.toLowerCase().contains(texto) ||
          docenteNombre.contains(texto);

      final coincideDocente =
          _filtroDocenteAsignatura == 'todos' ||
          _nombreDocenteAsignatura(asignatura) == _filtroDocenteAsignatura;

      return coincideBusqueda && coincideDocente;
    }).toList();
  }

  int get _totalActivos => _docentes.where((d) => d.activo).length;
  int get _totalInactivos => _docentes.where((d) => !d.activo).length;
  int get _totalAsignaturasActivas =>
      _asignaturas.where((a) => a.activo).length;

  void _limpiarFiltrosDocentes() {
    setState(() {
      _busqueda = '';
      _filtroEstado = 'todos';
      _filtroInstitucion = 'todas';
    });
  }

  void _limpiarFiltrosAsignaturas() {
    setState(() {
      _busquedaAsignatura = '';
      _filtroDocenteAsignatura = 'todos';
    });
  }

  Widget _chipResumen({
    required String titulo,
    required String valor,
    required IconData icono,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: Colors.deepPurple.shade700, size: 20),
          const SizedBox(width: 8),
          Text(
            '$titulo: $valor',
            style: TextStyle(
              color: Colors.deepPurple.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipInfo(String texto, {Color? colorFondo, Color? colorTexto}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorFondo ?? Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: colorTexto ?? Colors.deepPurple.shade700,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _mensajeVacio({
    required IconData icono,
    required String titulo,
    required String subtitulo,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(icono, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        Center(
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            subtitulo,
            style: const TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFiltrosDocentes() {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, correo, cédula o institución',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busqueda.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _busqueda = '';
                          });
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _busqueda = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    value: _filtroEstado,
                    decoration: InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'todos',
                        child: Text('Todos'),
                      ),
                      DropdownMenuItem(
                        value: 'activos',
                        child: Text('Activos'),
                      ),
                      DropdownMenuItem(
                        value: 'inactivos',
                        child: Text('Inactivos'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _filtroEstado = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: DropdownButtonFormField<String>(
                    value: _filtroInstitucion,
                    decoration: InputDecoration(
                      labelText: 'Institución',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'todas',
                        child: Text('Todas'),
                      ),
                      ..._institucionesDisponibles.map(
                        (institucion) => DropdownMenuItem(
                          value: institucion,
                          child: Text(institucion),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _filtroInstitucion = value;
                      });
                    },
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _limpiarFiltrosDocentes,
                  icon: const Icon(Icons.cleaning_services),
                  label: const Text('Limpiar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltrosAsignaturas() {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por asignatura, curso o docente',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busquedaAsignatura.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _busquedaAsignatura = '';
                          });
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _busquedaAsignatura = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 280,
                  child: DropdownButtonFormField<String>(
                    value: _filtroDocenteAsignatura,
                    decoration: InputDecoration(
                      labelText: 'Docente',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'todos',
                        child: Text('Todos'),
                      ),
                      ..._docentesDisponiblesParaAsignaturas.map(
                        (docente) => DropdownMenuItem(
                          value: docente,
                          child: Text(docente),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _filtroDocenteAsignatura = value;
                      });
                    },
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _limpiarFiltrosAsignaturas,
                  icon: const Icon(Icons.cleaning_services),
                  label: const Text('Limpiar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocenteCard(Docente docente) {
    final asignaturasDocente = _asignaturasDeDocente(docente.id);
    final totalAsignaturas = asignaturasDocente.length;
    final previewAsignaturas =
        asignaturasDocente.take(3).map((a) => a.nombre).toList();
    final faltantes = totalAsignaturas - previewAsignaturas.length;

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
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(docente.correo.isEmpty ? 'Sin correo' : docente.correo),
            const SizedBox(height: 4),
            Text(
              docente.institucionNombre.isEmpty
                  ? 'Sin institución'
                  : docente.institucionNombre,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chipInfo(
                  docente.activo ? 'Activo' : 'Inactivo',
                  colorFondo: docente.activo
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  colorTexto: docente.activo
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
                _chipInfo('Asignaturas: $totalAsignaturas'),
              ],
            ),
            if (previewAsignaturas.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                faltantes > 0
                    ? '${previewAsignaturas.join(', ')} y $faltantes más'
                    : previewAsignaturas.join(', '),
                style: const TextStyle(color: Colors.black54),
              ),
            ],
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
              child: Text(docente.activo ? 'Desactivar' : 'Activar'),
            ),
            const PopupMenuItem(
              value: 'eliminar',
              child: Text('Eliminar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsignaturaCard(Asignatura asignatura) {
    final docenteNombre = _nombreDocenteAsignatura(asignatura);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              asignatura.nombre,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text('Curso: ${asignatura.curso}'),
            const SizedBox(height: 4),
            Text('Docente: $docenteNombre'),
            const SizedBox(height: 4),
            Text('Estudiantes: ${asignatura.numeroEstudiantes}'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chipInfo(
                  asignatura.activo ? 'Activa' : 'Inactiva',
                  colorFondo: asignatura.activo
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  colorTexto: asignatura.activo
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
                _chipInfo('Docente ID: ${asignatura.docenteId}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabDocentes() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_docentes.isEmpty) {
      return _mensajeVacio(
        icono: Icons.people_outline,
        titulo: 'No hay docentes registrados',
        subtitulo: 'Presione + para agregar un docente',
      );
    }

    if (_docentesFiltrados.isEmpty) {
      return _mensajeVacio(
        icono: Icons.filter_alt_off_outlined,
        titulo: 'No se encontraron docentes con esos filtros',
        subtitulo: 'Intente con otra búsqueda o limpie los filtros',
      );
    }

    return RefreshIndicator(
      onRefresh: _recargarDatos,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chipResumen(
                titulo: 'Total',
                valor: _docentes.length.toString(),
                icono: Icons.groups,
              ),
              _chipResumen(
                titulo: 'Activos',
                valor: _totalActivos.toString(),
                icono: Icons.check_circle_outline,
              ),
              _chipResumen(
                titulo: 'Inactivos',
                valor: _totalInactivos.toString(),
                icono: Icons.remove_circle_outline,
              ),
              _chipResumen(
                titulo: 'Mostrando',
                valor: _docentesFiltrados.length.toString(),
                icono: Icons.filter_alt_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFiltrosDocentes(),
          const SizedBox(height: 12),
          ..._docentesFiltrados.map(_buildDocenteCard),
        ],
      ),
    );
  }

  Widget _buildTabAsignaturas() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_asignaturas.isEmpty) {
      return _mensajeVacio(
        icono: Icons.menu_book_outlined,
        titulo: 'No hay asignaturas registradas',
        subtitulo: 'Primero registre o sincronice asignaturas',
      );
    }

    if (_asignaturasFiltradas.isEmpty) {
      return _mensajeVacio(
        icono: Icons.filter_alt_off_outlined,
        titulo: 'No se encontraron asignaturas con esos filtros',
        subtitulo: 'Intente con otra búsqueda o limpie los filtros',
      );
    }

    return RefreshIndicator(
      onRefresh: _recargarDatos,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chipResumen(
                titulo: 'Total',
                valor: _asignaturas.length.toString(),
                icono: Icons.menu_book,
              ),
              _chipResumen(
                titulo: 'Activas',
                valor: _totalAsignaturasActivas.toString(),
                icono: Icons.check_circle_outline,
              ),
              _chipResumen(
                titulo: 'Docentes',
                valor: _docentesDisponiblesParaAsignaturas.length.toString(),
                icono: Icons.groups,
              ),
              _chipResumen(
                titulo: 'Mostrando',
                valor: _asignaturasFiltradas.length.toString(),
                icono: Icons.filter_alt_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFiltrosAsignaturas(),
          const SizedBox(height: 12),
          ..._asignaturasFiltradas.map(_buildAsignaturaCard),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel de administrador'),
          backgroundColor: Colors.deepPurple.shade700,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              tooltip: 'Sincronizar',
              icon: const Icon(Icons.sync),
              onPressed: _recargarDatos,
            ),
            IconButton(
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout),
              onPressed: _cerrarSesion,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.groups),
                text: 'Docentes',
              ),
              Tab(
                icon: Icon(Icons.menu_book),
                text: 'Asignaturas',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurple.shade700,
          foregroundColor: Colors.white,
          onPressed: () => _abrirFormulario(),
          child: const Icon(Icons.add),
        ),
        body: Column(
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
                    'Administre docentes y asignturas desde un solo panel',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _AdminDocentesTab(),
                  _AdminAsignaturasTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDocentesTab extends StatelessWidget {
  const _AdminDocentesTab();

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_AdminHomeScreenState>();
    if (state == null) return const SizedBox.shrink();
    return state._buildTabDocentes();
  }
}

class _AdminAsignaturasTab extends StatelessWidget {
  const _AdminAsignaturasTab();

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_AdminHomeScreenState>();
    if (state == null) return const SizedBox.shrink();
    return state._buildTabAsignaturas();
  }
}
