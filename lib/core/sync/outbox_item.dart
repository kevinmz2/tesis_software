// archivo que me sirve para representar una acción pendiente de sincronizacion
class OutboxItem {
  final String id;
  final String entidad;
  final String accion;
  final Map<String, dynamic> data;
  final DateTime creadoEn;
  final int intentos;
  final String? error;

  const OutboxItem({
    required this.id,
    required this.entidad,
    required this.accion,
    required this.data,
    required this.creadoEn,
    this.intentos = 0,
    this.error,
  });

  factory OutboxItem.crear({
    required String entidad,
    required String accion,
    required Map<String, dynamic> data,
  }) {
    return OutboxItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      entidad: entidad,
      accion: accion,
      data: data,
      creadoEn: DateTime.now(),
    );
  }

  factory OutboxItem.fromMap(Map<dynamic, dynamic> map) {
    return OutboxItem(
      id: (map['id'] ?? '').toString(),
      entidad: (map['entidad'] ?? '').toString(),
      accion: (map['accion'] ?? '').toString(),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      creadoEn: DateTime.tryParse((map['creadoEn'] ?? '').toString()) ??
          DateTime.now(),
      intentos: int.tryParse((map['intentos'] ?? '0').toString()) ?? 0,
      error: map['error']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entidad': entidad,
      'accion': accion,
      'data': data,
      'creadoEn': creadoEn.toIso8601String(),
      'intentos': intentos,
      'error': error,
    };
  }

  OutboxItem copyWith({
    String? id,
    String? entidad,
    String? accion,
    Map<String, dynamic>? data,
    DateTime? creadoEn,
    int? intentos,
    String? error,
  }) {
    return OutboxItem(
      id: id ?? this.id,
      entidad: entidad ?? this.entidad,
      accion: accion ?? this.accion,
      data: data ?? this.data,
      creadoEn: creadoEn ?? this.creadoEn,
      intentos: intentos ?? this.intentos,
      error: error,
    );
  }
}

