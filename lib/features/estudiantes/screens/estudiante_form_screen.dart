import 'package:flutter/material.dart';

class EstudianteFormScreen extends StatefulWidget {
  final Map<String, dynamic>? estudiante;

  const EstudianteFormScreen({super.key, this.estudiante});

  @override
  State<EstudianteFormScreen> createState() =>
      _EstudianteFormScreenState();
}

class _EstudianteFormScreenState extends State<EstudianteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _cursoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.estudiante != null) {
      _nombreController.text =
          (widget.estudiante!['nombre'] ?? '').toString();
      _cursoController.text =
          (widget.estudiante!['curso'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cursoController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final estudiante = {
        'nombre': _nombreController.text.trim(),
        'curso': _cursoController.text.trim(),
      };

      Navigator.pop(context, estudiante);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esEdicion = widget.estudiante != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          esEdicion ? 'Editar Estudiante' : 'Nuevo Estudiante',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del estudiante',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cursoController,
                decoration: const InputDecoration(
                  labelText: 'Curso',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardar,
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}