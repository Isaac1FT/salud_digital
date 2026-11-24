import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/cita.dart';
import 'cita_dto.dart';
import 'citas_repository.dart';

/// Implementación de citas sobre Firestore.
///
/// Ruta: `usuarios/{uid}/citas/{citaId}`. Las reglas verifican que el uid de
/// la ruta coincida con `request.auth.uid`.
class FirestoreCitasRepository implements CitasRepository {
  FirestoreCitasRepository({
    required String Function() usuarioId,
    FirebaseFirestore? firestore,
  })  : _usuarioId = usuarioId,
        _db = firestore ?? FirebaseFirestore.instance;

  final String Function() _usuarioId;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _coleccion {
    final uid = _usuarioId();
    if (uid.isEmpty) {
      throw StateError('No hay usuario autenticado.');
    }
    return _db.collection('usuarios').doc(uid).collection('citas');
  }

  @override
  Stream<List<Cita>> watch() {
    return _coleccion
        .orderBy('fechaHora')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(CitaDto.desdeDocumento).toList());
  }

  @override
  Future<List<Cita>> listar() async {
    final snapshot = await _coleccion.orderBy('fechaHora').get();
    return snapshot.docs.map(CitaDto.desdeDocumento).toList();
  }

  @override
  Future<void> crear(Cita cita) async {
    await _coleccion.add(CitaDto.aCrear(cita));
  }

  @override
  Future<void> actualizar(Cita cita) async {
    await _coleccion.doc(cita.id).update(CitaDto.aActualizar(cita));
  }

  @override
  Future<void> eliminar(String id) async {
    await _coleccion.doc(id).delete();
  }
}
