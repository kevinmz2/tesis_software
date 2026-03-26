import 'package:flutter/material.dart';

class EstudianteFormScreen extends StatefulWidget {
  final Map<String, dynamic>? estudiante;

  const EstudianteFormScreen({
    super.key,
    this.estudiante,
  });

  @override
  State<EstudianteFormScreen> createState() => _EstudianteFormScreenState();
}

class _EstudianteFormScreenState extends State<EstudianteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _edadController = TextEditingController();
  final _celularController = TextEditingController();
  final _tipoSangreController = TextEditingController();
  final _contactoEmergenciaNombreController = TextEditingController();
  final _contactoEmergenciaCelularController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.estudiante != null) {
      _nombresController.text =
          (widget.estudiante!['nombres'] ?? '').toString();
      _apellidosController.text =
          (widget.estudiante!['apellidos'] ?? '').toString();
      _edadController.text = (widget.estudiante!['edad'] ?? '').toString();
      _celularController.text =
          (widget.estudiante!['celular'] ?? '').toString();
      _tipoSangreController.text =
          (widget.estudiante!['tipoSangre'] ?? '').toString();
      _contactoEmergenciaNombreController.text =
          (widget.estudiante!['contactoEmergenciaNombre'] ?? '').toString();
      _contactoEmergenciaCelularController.text =
          (widget.estudiante!['contactoEmergenciaCelular'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _edadController.dispose();
    _celularController.dispose();
    _tipoSangreController.dispose();
    _contactoEmergenciaNombreController.dispose();
    _contactoEmergenciaCelularController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final estudiante = {
      'nombres': _nombresController.text.trim(),
      'apellidos': _apellidosController.text.trim(),
      'edad': int.tryParse(_edadController.text.trim()) ?? 0,
      'celular': _celularController.text.trim(),
      'tipoSangre': _tipoSangreController.text.trim(),
      'contactoEmergenciaNombre':
          _contactoEmergenciaNombreController.text.trim(),
      'contactoEmergenciaCelular':
          _contactoEmergenciaCelularController.text.trim(),
    };

    Navigator.pop(context, estudiante);
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.estudiante != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          esEdicion ? 'Editar estudiante' : 'Nuevo estudiante',
        ),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
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
                    controller: _apellidosController,
                    label: 'Apellidos',
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Campo obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _campoTexto(
                    controller: _nombresController,
                    label: 'Nombres',
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Campo obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _campoTexto(
                    controller: _edadController,
                    label: 'Edad',
                    tipo: TextInputType.number,
                    validator: (value) {
                      final texto = (value ?? '').trim();
                      if (texto.isEmpty) {
                        return 'Campo obligatorio';
                      }
                      final edad = int.tryParse(texto);
                      if (edad == null) {
                        return 'Ingrese una edad válida';
                      }
                      if (edad <= 0) {
                        return 'Ingrese una edad válida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _campoTexto(
                    controller: _celularController,
                    label: 'Celular',
                    tipo: TextInputType.phone,
                    validator: (value) {
                      final texto = (value ?? '').trim();
                      if (texto.isEmpty) {
                        return 'Campo obligatorio';
                      }
                      if (!RegExp(r'^\d+$').hasMatch(texto)) {
                        return 'Solo se permiten números';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _campoTexto(
                    controller: _tipoSangreController,
                    label: 'Tipo de sangre',
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Campo obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _campoTexto(
                    controller: _contactoEmergenciaNombreController,
                    label: 'En caso de emergencia llamar a',
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Campo obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _campoTexto(
                    controller: _contactoEmergenciaCelularController,
                    label: 'Número de emergencia',
                    tipo: TextInputType.phone,
                    validator: (value) {
                      final texto = (value ?? '').trim();
                      if (texto.isEmpty) {
                        return 'Campo obligatorio';
                      }
                      if (!RegExp(r'^\d+$').hasMatch(texto)) {
                        return 'Solo se permiten números';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _guardar,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        esEdicion ? 'Actualizar' : 'Guardar',
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
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    TextInputType tipo = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}

