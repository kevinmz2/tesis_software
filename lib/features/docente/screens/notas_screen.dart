import 'package:flutter/material.dart';

class NotasScreen extends StatefulWidget {
  const NotasScreen({super.key});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  /// Lista temporal de estudiantes con notas
  final List<Map<String, dynamic>> _estudiantes = [
    {'nombre': 'Juan Pérez', 'nota': 8.5},
    {'nombre': 'María López', 'nota': 9.2},
    {'nombre': 'Carlos Torres', 'nota': null},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _estudiantes.length,
        itemBuilder: (context, index) {
          final estudiante = _estudiantes[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                estudiante['nombre'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              /// NOTA A LA DERECHA (SIMILAR A ACCIONES)
              trailing: InkWell(
                onTap: () => _editarNota(index),
                child: Container(
                  width: 60,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.deepPurple,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    estudiante['nota'] == null
                        ? '--'
                        : estudiante['nota'].toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ---------------------------
  /// EDITAR NOTA
  /// ---------------------------
  void _editarNota(int index) async {
    final controller = TextEditingController(
      text: _estudiantes[index]['nota']?.toString() ?? '',
    );

    final resultado = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ingresar nota'),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'Ej: 8.5',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final valor = double.tryParse(controller.text);
              Navigator.pop(context, valor);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (resultado != null) {
      setState(() {
        _estudiantes[index]['nota'] = resultado;
      });
    }
  }
}
