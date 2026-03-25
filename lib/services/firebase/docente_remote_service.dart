import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_academica_offline/features/admin/models/docente_model.dart';

class DocenteRemoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usuariosRef =>
      _firestore.collection('usuarios');

  Future<List<Docente>> getDocentes() async {
    try {
      print('REMOTE: entrando a getDocentes()');

      final snapshot = await _usuariosRef.get();

      print('REMOTE: total usuarios en Firestore = ${snapshot.docs.length}');

      final docentesDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        final rol = (data['rol'] ?? '').toString().trim().toLowerCase();
        return rol == 'docente';
      }).toList();

      print('REMOTE: total docentes encontrados = ${docentesDocs.length}');

      for (final doc in docentesDocs) {
        print('REMOTE DOCENTE -> id: ${doc.id} data: ${doc.data()}');
      }

      return docentesDocs.map((doc) {
        final data = doc.data();

        return Docente(
          id: doc.id,
          nombre: (data['nombre'] ?? '').toString(),
          cedula: '',
          edad: 0,
          correo: (data['email'] ?? '').toString(),
          telefono: '',
          institucionId: '',
          institucionNombre: '',
          activo: data['activo'] is bool ? data['activo'] : true,
          fechaCreacion: '',
          pendienteSync: false,
        );
      }).toList();
    } catch (e) {
      print('REMOTE ERROR getDocentes(): $e');
      rethrow;
    }
  }

  Future<void> saveDocente(Docente docente) async {
    try {
      print('REMOTE: intentando guardar docente -> ${docente.id}');
      print('REMOTE: nombre=${docente.nombre}');
      print('REMOTE: email=${docente.correo}');
      print('REMOTE: activo=${docente.activo}');

      await _usuariosRef.doc(docente.id).set({
        'nombre': docente.nombre,
        'email': docente.correo,
        'activo': docente.activo,
        'rol': 'docente',
      }, SetOptions(merge: true));

      print('REMOTE: docente guardado correctamente en Firestore');
    } catch (e) {
      print('REMOTE ERROR saveDocente(): $e');
      rethrow;
    }
  }

  Future<void> updateDocente(Docente docente) async {
    try {
      print('REMOTE: intentando actualizar docente -> ${docente.id}');

      await _usuariosRef.doc(docente.id).set({
        'nombre': docente.nombre,
        'email': docente.correo,
        'activo': docente.activo,
        'rol': 'docente',
      }, SetOptions(merge: true));

      print('REMOTE: docente actualizado correctamente en Firestore');
    } catch (e) {
      print('REMOTE ERROR updateDocente(): $e');
      rethrow;
    }
  }

  Future<void> deleteDocente(String id) async {
    try {
      print('REMOTE: intentando eliminar docente -> $id');

      await _usuariosRef.doc(id).delete();

      print('REMOTE: docente eliminado correctamente en Firestore');
    } catch (e) {
      print('REMOTE ERROR deleteDocente(): $e');
      rethrow;
    }
  }
}
