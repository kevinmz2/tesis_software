import 'package:flutter/material.dart';
import 'package:app_academica_offline/features/docente/models/actividad_model.dart';
import 'package:app_academica_offline/features/docente/screens/actividad_form_screen.dart';
import 'package:app_academica_offline/features/docente/screens/actividad_detail_screen.dart';
import 'package:app_academica_offline/services/local/actividad_local_store.dart';

class ActividadesScreen extends StatefulWidget {
  final String asignaturaId;
  final String nombreAsignatura;

  const ActividadesScreen({
    super.key,
    required this.asignaturaId,
    required this.nombreAsignatura,
  });

  @override
  State<ActividadesScreen> createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends State<ActividadesScreen> {
  final ActividadLocalStore _actividadStore = ActividadLocalStore();
  List<Actividad> _actividades = [];

  @override
  void initState() {
    super.initState();
    _cargarActividades();
  }

  void _cargarActividades() {
    setState(() {
      _actividades = _actividadStore.getByAsignatura(widget.asignaturaId);
      _actividades.sort((a, b) => b.fecha.compareTo(a.fecha));
    });
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  Future<void> _nuevaActividad() async {
    final data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ActividadFormScreen(),
      ),
    );

    if (data == null) return;

    final actividad = Actividad(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      asignaturaId: widget.asignaturaId,
      titulo: (data['titulo'] ?? '').toString(),
      descripcion: (data['descripcion'] ?? '').toString(),
      tipo: (data['tipo'] ?? 'tarea').toString(),
      fecha: (data['fecha'] ?? '').toString(),
      puntajeMaximo: (data['puntajeMaximo'] as num).toDouble(),
    );

    await _actividadStore.upsert(actividad);
    _cargarActividades();

    if (!mounted) return;
    _mostrarMensaje('Actividad registrada correctamente');
  }

  Future<void> _editarActividad(Actividad actual) async {
    final data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActividadFormScreen(
          actividad: {
            'titulo': actual.titulo,
            'descripcion': actual.descripcion,
            'tipo': actual.tipo,
            'fecha': actual.fecha,
            'puntajeMaximo': actual.puntajeMaximo,
          },
        ),
      ),
    );

    if (data == null) return;

    final actividadActualizada = Actividad(
      id: actual.id,
      asignaturaId: actual.asignaturaId,
      titulo: (data['titulo'] ?? '').toString(),
      descripcion: (data['descripcion'] ?? '').toString(),
      tipo: (data['tipo'] ?? 'tarea').toString(),
      fecha: (data['fecha'] ?? '').toString(),
      puntajeMaximo: (data['puntajeMaximo'] as num).toDouble(),
    );

    await _actividadStore.upsert(actividadActualizada);
    _cargarActividades();

    if (!mounted) return;
    _mostrarMensaje('Actividad actualizada correctamente');
  }

  Future<void> _eliminarActividad(Actividad actividad) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text(
          '¿Está seguro que desea eliminar esta actividad?',
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
      await _actividadStore.delete(actividad.id);
      _cargarActividades();

      if (!mounted) return;
      _mostrarMensaje('Actividad eliminada correctamente');
    }
  }

  String _tipoTexto(String tipo) {
    switch (tipo) {
      case 'tarea':
        return 'Tarea';
      case 'examen':
        return 'Examen';
      case 'participacion':
        return 'Participación';
      case 'proyecto':
        return 'Proyecto';
      default:
        return tipo;
    }
  }

  Widget _encabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
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
                widget.nombreAsignatura,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Actividades registradas: ${_actividades.length}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _estadoVacio() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay actividades registradas',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Presione el botón para agregar una actividad',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _listaActividades() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _actividades.length,
      itemBuilder: (context, index) {
        final actividad = _actividades[index];

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
            leading: const Icon(Icons.assignment),
            title: Text(
              actividad.titulo,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${_tipoTexto(actividad.tipo)} • ${actividad.fecha}\nPuntaje máximo: ${actividad.puntajeMaximo}',
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit, color: Colors.deepPurple),
                  onPressed: () => _editarActividad(actividad),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminarActividad(actividad),
                ),
              ],
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActividadDetailScreen(
                    actividad: {
                      'titulo': actividad.titulo,
                      'descripcion': actividad.descripcion,
                      'tipo': actividad.tipo,
                      'fecha': actividad.fecha,
                      'puntajeMaximo': actividad.puntajeMaximo,
                    },
                  ),
                ),
              );

              if (!mounted) return;
              _cargarActividades();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de actividades'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _encabezado(),
          Expanded(
            child: _actividades.isEmpty ? _estadoVacio() : _listaActividades(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        onPressed: _nuevaActividad,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Agregar actividad',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

