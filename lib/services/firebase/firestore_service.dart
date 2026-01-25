import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirestoreService() {
    _db.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  Stream<QuerySnapshot> obtenerDocentes() {
    return _db
        .collection('docentes')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  Future<void> agregarDocente({
    required String nombre,
    required String institucion,
    required String asignatura,
  }) async {
    await _db.collection('docentes').add({
      'nombre': nombre,
      'institucion': institucion,
      'asignatura': asignatura,
      'fecha': Timestamp.now(),
    });
  }
}
