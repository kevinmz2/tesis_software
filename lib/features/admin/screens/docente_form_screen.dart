import 'package:flutter/material.dart';

class DocenteFormScreen extends StatefulWidget {
  final Map<String, dynamic>? docente; // null = nuevo | con data = editar

  const DocenteFormScreen({super.key, this.docente});

  @override
  State<DocenteFormScreen> createState() => _DocenteFormScreenState();
}

class _DocenteFormScreenState extends State<DocenteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _edadController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();

  String? _institucionSeleccionada;

  final List<String> _instituciones = [
    'Unidad Educativa Rural Loja',
    'Escuela Comunitaria Andina',
    'Institución Educativa Intercultural',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.docente != null) {
      _nombreController.text = widget.docente!['nombre'] ?? '';
      _cedulaController.text = widget.docente!['cedula'] ?? '';
      _edadController.text = widget.docente!['edad']?.toString() ?? '';
      _correoController.text = widget.docente!['correo'] ?? '';
      _telefonoController.text = widget.docente!['telefono'] ?? '';
      _institucionSeleccionada = widget.docente!['institucion'];
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _edadController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final docente = {
        'nombre': _nombreController.text.trim(),
        'cedula': _cedulaController.text.trim(),
        'edad': int.parse(_edadController.text.trim()),
        'correo': _correoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'institucion': _institucionSeleccionada,
      };

      Navigator.pop(context, docente);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.docente == null
              ? 'Nuevo docente'
              : 'Editar docente',
        ),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _campoTexto('Nombres y Apellidos', _nombreController),

              _campoTexto(
                'Cédula',
                _cedulaController,
                tipo: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Solo números';
                  }
                  if (value.length != 10) {
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
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),

              _campoTexto(
                'Correo electrónico',
                _correoController,
                tipo: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
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
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Solo números';
                  } //le agrege validacion de 10 digitos 
                  if (value.length !=10) {
                    return 'El numero debe contener 10 digitos';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _institucionSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Institución',
                  border: OutlineInputBorder(),
                ),
                items: _instituciones
                    .map(
                      (inst) => DropdownMenuItem(
                        value: inst,
                        child: Text(inst),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _institucionSeleccionada = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Seleccione una institución' : null,
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
                value == null || value.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }
}
