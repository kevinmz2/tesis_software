import 'package:flutter/material.dart';

class ActividadFormScreen extends StatefulWidget {
  final Map<String, dynamic>? actividad;

  const ActividadFormScreen({
    super.key,
    this.actividad,
  });

  @override
  State<ActividadFormScreen> createState() => _ActividadFormScreenState();
}

class _ActividadFormScreenState extends State<ActividadFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _puntajeMaximoController = TextEditingController();

  String _tipoSeleccionado = 'tarea';
  DateTime _fechaSeleccionada = DateTime.now();

  @override
  void initState() {
    super.initState();

    if (widget.actividad != null) {
      _tituloController.text = (widget.actividad!['titulo'] ?? '').toString();
      _descripcionController.text =
          (widget.actividad!['descripcion'] ?? '').toString();
      _puntajeMaximoController.text =
          (widget.actividad!['puntajeMaximo'] ?? '').toString();
      _tipoSeleccionado = (widget.actividad!['tipo'] ?? 'tarea').toString();

      final fechaTexto = (widget.actividad!['fecha'] ?? '').toString();
      if (fechaTexto.isNotEmpty) {
        try {
          _fechaSeleccionada = DateTime.parse(fechaTexto);
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _puntajeMaximoController.dispose();
    super.dispose();
  }

  String _formatearFecha(DateTime fecha) {
    final year = fecha.year.toString();
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final actividad = {
      'titulo': _tituloController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'tipo': _tipoSeleccionado,
      'fecha': _formatearFecha(_fechaSeleccionada),
      'puntajeMaximo':
          double.parse(_puntajeMaximoController.text.trim()),
    };

    Navigator.pop(context, actividad);
  }

  @override
  Widget build(BuildContext context) {
    final fechaTexto = _formatearFecha(_fechaSeleccionada);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.actividad == null ? 'Nueva actividad' : 'Editar actividad',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _tipoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de actividad',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'tarea',
                    child: Text('Tarea'),
                  ),
                  DropdownMenuItem(
                    value: 'examen',
                    child: Text('Examen'),
                  ),
                  DropdownMenuItem(
                    value: 'participacion',
                    child: Text('Participación'),
                  ),
                  DropdownMenuItem(
                    value: 'proyecto',
                    child: Text('Proyecto'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipoSeleccionado = value ?? 'tarea';
                  });
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Fecha'),
                  subtitle: Text(fechaTexto),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _seleccionarFecha,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _puntajeMaximoController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Puntaje máximo',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: 10',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el puntaje máximo';
                  }

                  final numero = double.tryParse(value.trim());
                  if (numero == null) {
                    return 'Ingrese un número válido';
                  }

                  if (numero <= 0) {
                    return 'Debe ser mayor a 0';
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
                  label: const Text('Guardar actividad'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}