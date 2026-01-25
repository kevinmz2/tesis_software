import 'package:flutter/material.dart';

class AsignaturaFormScreen extends StatefulWidget {
  final Map<String, dynamic>? asignatura;

  const AsignaturaFormScreen({super.key, this.asignatura});

  @override
  State<AsignaturaFormScreen> createState() => _AsignaturaFormScreenState();
}

class _AsignaturaFormScreenState extends State<AsignaturaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _cursoController = TextEditingController();
  final _estudiantesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.asignatura != null) {
      _nombreController.text = widget.asignatura!['nombre'] ?? '';
      _cursoController.text = widget.asignatura!['curso'] ?? '';
      _estudiantesController.text =
          widget.asignatura!['estudiantes']?.toString() ?? '';
    }
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final asignatura = {
        'nombre': _nombreController.text.trim(),
        'curso': _cursoController.text.trim(),
        'docente': 'Docente actual', // luego vendrá del login
        'estudiantes': int.parse(_estudiantesController.text.trim()),
      };

      Navigator.pop(context, asignatura);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.asignatura == null
              ? 'Nueva Asignatura'
              : 'Editar Asignatura',
        ),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// NOMBRE
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la asignatura',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),

              const SizedBox(height: 16),

              /// CURSO
              TextFormField(
                controller: _cursoController,
                decoration: const InputDecoration(
                  labelText: 'Curso',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),

              const SizedBox(height: 16),

              /// NÚMERO DE ESTUDIANTES
              TextFormField(
                controller: _estudiantesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número de estudiantes',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
