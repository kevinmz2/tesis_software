import 'package:flutter/material.dart';
import 'package:app_academica_offline/features/admin/models/docente_model.dart';
import 'package:app_academica_offline/features/admin/repositories/docente_repository.dart';

class DocenteFormScreen extends StatefulWidget {
  final Docente? docente;

  const DocenteFormScreen({
    super.key,
    this.docente,
  });

  @override
  State<DocenteFormScreen> createState() => _DocenteFormScreenState();
}

class _DocenteFormScreenState extends State<DocenteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DocenteRepository _docenteRepository = DocenteRepository();

  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _edadController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _institucionIdController = TextEditingController();
  final _institucionNombreController = TextEditingController();

  bool _activo = true;
  bool _guardando = false;

  bool get _esEdicion => widget.docente != null;

  @override
  void initState() {
    super.initState();

    final docente = widget.docente;
    if (docente != null) {
      _nombreController.text = docente.nombre;
      _cedulaController.text = docente.cedula;
      _edadController.text = docente.edad.toString();
      _correoController.text = docente.correo;
      _telefonoController.text = docente.telefono;
      _institucionIdController.text = docente.institucionId;
      _institucionNombreController.text = docente.institucionNombre;
      _activo = docente.activo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _edadController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _institucionIdController.dispose();
    _institucionNombreController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _guardando = true;
    });

    final docente = Docente(
      id: widget.docente?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _nombreController.text.trim(),
      cedula: _cedulaController.text.trim(),
      edad: int.tryParse(_edadController.text.trim()) ?? 0,
      correo: _correoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      institucionId: _institucionIdController.text.trim(),
      institucionNombre: _institucionNombreController.text.trim(),
      activo: _activo,
      fechaCreacion: widget.docente?.fechaCreacion ??
          DateTime.now().toIso8601String(),
      pendienteSync: true,
    );

    String? error;

    if (_esEdicion) {
      error = await _docenteRepository.update(docente);
    } else {
      error = await _docenteRepository.save(docente);
    }

    if (!mounted) return;

    setState(() {
      _guardando = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _esEdicion
              ? 'Docente actualizado correctamente'
              : 'Docente guardado correctamente',
        ),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEdicion ? 'Editar docente' : 'Nuevo docente',
        ),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      'Nombres y apellidos',
                      _nombreController,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Campo obligatorio';
                        }
                        return null;
                      },
                    ),
                    _campoTexto(
                      'Cédula',
                      _cedulaController,
                      tipo: TextInputType.number,
                      validator: (value) {
                        final texto = (value ?? '').trim();

                        if (texto.isEmpty) return 'Campo obligatorio';
                        if (!RegExp(r'^\d+$').hasMatch(texto)) {
                          return 'Solo números';
                        }
                        if (texto.length != 10) {
                          return 'Debe tener 10 dígitos';
                        }
                        return null;
                      },
                    ),
                    _campoTexto(
                      'Edad',
                      _edadController,
                      tipo: TextInputType.number,
                      validator: (value) {
                        final texto = (value ?? '').trim();

                        if (texto.isEmpty) return 'Campo obligatorio';

                        final edad = int.tryParse(texto);
                        if (edad == null) {
                          return 'Ingrese un número válido';
                        }
                        if (edad < 18) {
                          return 'La edad mínima es 18';
                        }
                        return null;
                      },
                    ),
                    _campoTexto(
                      'Correo electrónico',
                      _correoController,
                      tipo: TextInputType.emailAddress,
                      validator: (value) {
                        final texto = (value ?? '').trim();

                        if (texto.isEmpty) return 'Campo obligatorio';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(texto)) {
                          return 'Correo inválido';
                        }
                        return null;
                      },
                    ),
                    _campoTexto(
                      'Número de teléfono',
                      _telefonoController,
                      tipo: TextInputType.phone,
                      validator: (value) {
                        final texto = (value ?? '').trim();

                        if (texto.isEmpty) return 'Campo obligatorio';
                        if (!RegExp(r'^\d+$').hasMatch(texto)) {
                          return 'Solo números';
                        }
                        if (texto.length != 10) {
                          return 'El número debe contener 10 dígitos';
                        }
                        return null;
                      },
                    ),
                    _campoTexto(
                      'ID de institución',
                      _institucionIdController,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Campo obligatorio';
                        }
                        return null;
                      },
                    ),
                    _campoTexto(
                      'Nombre de institución',
                      _institucionNombreController,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Campo obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 4),
                    SwitchListTile(
                      value: _activo,
                      activeColor: Colors.deepPurple.shade700,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Docente activo',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _activo ? 'Estado: activo' : 'Estado: inactivo',
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
            (value) =>
                value == null || value.trim().isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }
}
