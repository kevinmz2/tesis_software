// me sirve para guardar localmente las acciones pendientes de sincronizacion
import 'package:hive/hive.dart';

import 'package:app_academica_offline/core/sync/outbox_item.dart';

class OutboxLocalStore {
  static const String boxName = 'outbox_box';

  Future<Box> _abrirBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }

    return await Hive.openBox(boxName);
  }

  Future<List<OutboxItem>> getAll() async {
    final box = await _abrirBox();

    final items = box.values
        .where((value) => value is Map)
        .map(
          (value) => OutboxItem.fromMap(
            Map<dynamic, dynamic>.from(value as Map),
          ),
        )
        .toList();

    items.sort((a, b) => a.creadoEn.compareTo(b.creadoEn));

    return items;
  }

  Future<List<OutboxItem>> getPendientes() async {
    final items = await getAll();

    return items.where((item) => item.intentos < 5).toList();
  }

  Future<OutboxItem?> getById(String id) async {
    final box = await _abrirBox();
    final value = box.get(id);

    if (value == null || value is! Map) {
      return null;
    }

    return OutboxItem.fromMap(
      Map<dynamic, dynamic>.from(value),
    );
  }

  Future<void> upsert(OutboxItem item) async {
    final box = await _abrirBox();

    await box.put(
      item.id,
      item.toMap(),
    );
  }

  Future<void> add(OutboxItem item) async {
    await upsert(item);
  }

  Future<void> delete(String id) async {
    final box = await _abrirBox();

    await box.delete(id);
  }

  Future<void> clear() async {
    final box = await _abrirBox();

    await box.clear();
  }

  Future<int> count() async {
    final box = await _abrirBox();

    return box.length;
  }

  Future<int> countPendientes() async {
    final pendientes = await getPendientes();

    return pendientes.length;
  }

  Future<void> registrarError({
    required String id,
    required String error,
  }) async {
    final item = await getById(id);

    if (item == null) return;

    final actualizado = item.copyWith(
      intentos: item.intentos + 1,
      error: error,
    );

    await upsert(actualizado);
  }

  Future<void> incrementarIntentos(String id) async {
    final item = await getById(id);

    if (item == null) return;

    final actualizado = item.copyWith(
      intentos: item.intentos + 1,
      error: item.error,
    );

    await upsert(actualizado);
  }
}

