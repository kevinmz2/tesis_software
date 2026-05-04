import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app_academica_offline/features/admin/models/docente_model.dart';
import 'package:app_academica_offline/features/admin/repositories/docente_repository.dart';
import 'package:app_academica_offline/features/docente/models/asignatura_model.dart';

class AsignaturaFormScreen extends StatefulWidget {
  final Asignatura? asignatura;

  const AsignaturaFormScreen({
    super.key,
    this.asignatura,
  });

  @override
  State<AsignaturaFormScreen> createState() => _AsignaturaFormScreenState();
}

class _AsignaturaFormScreenState extends State<AsignaturaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DocenteRepository _docenteRepository = DocenteRepository();

  final _nombreController = TextEditingController();
  final _cursoController = TextEditingController();

  Docente? _docenteAutenticado;
  String? _mensajeDocente;
  bool _activo = true;
  bool _guardando = false;
  bool _cargandoDocentes = true;

  bool get _esEdicion => widget.asignatura != null;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    final asignatura = widget.asignatura;

    if (asignatura != null) {
      _nombreController.text = asignatura.nombre;
      _cursoController.text = asignatura.curso;
      _activo = asignatura.activo;
    }

    final docentes = await _docenteRepository.getAll();
    final docentesActivos = docentes.where((d) => d.activo).toList();

    final correoUsuario =
        FirebaseAuth.instance.currentUser?.email?.trim().toLowerCase();

    Docente? docenteEncontrado;

    if (asignatura != null && asignatura.docenteId.trim().isNotEmpty) {
      docenteEncontrado = _buscarDocentePorId(
            docentesActivos,
            asignatura.docenteId,
          ) ??
          _buscarDocentePorId(
            docentes,
            asignatura.docenteId,
          );
    }

    if (docenteEncontrado == null &&
        correoUsuario != null &&
        correoUsuario.isNotEmpty) {
      docenteEncontrado = _buscarDocentePorCorreo(
            docentesActivos,
            correoUsuario,
          ) ??
          _buscarDocentePorCorreo(
            docentes,
            correoUsuario,
          );
    }

    String? mensaje;

    if (docenteEncontrado == null) {
      if (correoUsuario == null || correoUsuario.isEmpty) {
        mensaje = 'No se pudo identificar el correo del docente autenticado.';
      } else {
        mensaje =
            'No se encontró un docente registrado con el correo $correoUsuario.';
      }
    }

    if (!mounted) return;

    setState(() {
      _docenteAutenticado = docenteEncontrado;
      _mensajeDocente = mensaje;
      _cargandoDocentes = false;
    });
  }

  Docente? _buscarDocentePorId(List<Docente> docentes, String docenteId) {
    return docentes.cast<Docente?>().firstWhere(
          (docente) => docente?.id == docenteId,
          orElse: () => null,
        );
  }

  Docente? _buscarDocentePorCorreo(List<Docente> docentes, String correo) {
    return docentes.cast<Docente?>().firstWhere(
          (docente) => docente?.correo.trim().toLowerCase() == correo,
          orElse: () => null,
        );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cursoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final docente = _docenteAutenticado;

    if (docente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _mensajeDocente ?? 'No se pudo identificar el docente autenticado.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    final asignatura = Asignatura(
      id: widget.asignatura?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _nombreController.text.trim(),
      curso: _cursoController.text.trim(),
      docenteId: docente.id,
      //numeroEstudiantes: 0,
      docenteNombre: docente.nombre,
      activo: _activo,
    );

    if (!mounted) return;

    Navigator.pop(context, asignatura);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEdicion ? 'Editar asignatura' : 'Nueva asignatura',
        ),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: _cargandoDocentes
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _campoTexto(
                            'Nombre de la asignatura',
                            _nombreController,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Campo obligatorio';
                              }
                              return null;
                            },
                          ),
                          _campoTexto(
                            'Curso',
                            _cursoController,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Campo obligatorio';
                              }
                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TextFormField(
                              initialValue: _docenteAutenticado?.nombre ??
                                  'Docente no identificado',
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Docente',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.person_outline),
                                helperText:
                                    'Asignado automáticamente según la sesión',
                                errorText: _docenteAutenticado == null
                                    ? _mensajeDocente
                                    : null,
                              ),
                            ),
                          ),
                          SwitchListTile(
                            value: _activo,
                            activeColor: Colors.deepPurple.shade700,
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Asignatura activa',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              _activo ? 'Estado: activa' : 'Estado: inactiva',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _activo = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _guardando ? null : _guardar,
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: Text(
                                _guardando ? 'Guardando...' : 'Guardar',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple.shade700,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _campoTexto(
    String label,
    TextEditingController controller, {
    TextInputType tipo = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator ??
            (value) => value == null || value.trim().isEmpty
                ? 'Campo obligatorio'
                : null,
      ),
    );
  }
}
