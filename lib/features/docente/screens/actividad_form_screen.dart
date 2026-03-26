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
  bool _guardando = false;

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

  double? _parsePuntaje(String texto) {
    final limpio = texto.trim().replaceAll(',', '.');
    return double.tryParse(limpio);
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
    if (_guardando) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final puntaje = _parsePuntaje(_puntajeMaximoController.text);
    if (puntaje == null) return;

    setState(() {
      _guardando = true;
    });

    final actividad = {
      'titulo': _tituloController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'tipo': _tipoSeleccionado,
      'fecha': _formatearFecha(_fechaSeleccionada),
      'puntajeMaximo': puntaje,
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
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final texto = (value ?? '').trim();
                      if (texto.isEmpty) {
                        return 'Ingrese el título';
                      }
                      if (texto.length < 3) {
                        return 'Ingrese un título más descriptivo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                      hintText: 'Detalle breve de la actividad',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _tipoSeleccionado,
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
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _seleccionarFecha,
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: const Text('Fecha'),
                        subtitle: Text(fechaTexto),
                        trailing: const Icon(Icons.calendar_month),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _puntajeMaximoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Puntaje máximo',
                      border: OutlineInputBorder(),
                      hintText: 'Ej: 10 o 10.0',
                    ),
                    validator: (value) {
                      final texto = (value ?? '').trim();
                      if (texto.isEmpty) {
                        return 'Ingrese el puntaje máximo';
                      }

                      final numero = _parsePuntaje(texto);
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
                      onPressed: _guardando ? null : _guardar,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        _guardando ? 'Guardando...' : 'Guardar actividad',
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
}

