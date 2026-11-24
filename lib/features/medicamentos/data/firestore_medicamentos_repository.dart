import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/medicamento.dart';
import 'medicamento_dto.dart';
import 'medicamentos_repository.dart';

/// Implementación de medicamentos sobre Firestore.
///
/// Ruta: `usuarios/{uid}/medicamentos/{medicamentoId}`.
class FirestoreMedicamentosRepository implements MedicamentosRepository {
  FirestoreMedicamentosRepository({
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
    return _db.collection('usuarios').doc(uid).collection('medicamentos');
  }

  @override
  Stream<List<Medicamento>> watch() {
    return _coleccion.orderBy('proximaToma').snapshots().map(
          (snapshot) => snapshot.docs
              .map(MedicamentoDto.desdeDocumento)
              .toList(),
        );
  }

  @override
  Future<List<Medicamento>> listar() async {
    final snapshot = await _coleccion.orderBy('proximaToma').get();
    return snapshot.docs.map(MedicamentoDto.desdeDocumento).toList();
  }

  @override
  Future<void> crear(Medicamento medicamento) async {
    await _coleccion.add(MedicamentoDto.aCrear(medicamento));
  }

  @override
  Future<void> actualizar(Medicamento medicamento) async {
    await _coleccion
        .doc(medicamento.id)
        .update(MedicamentoDto.aActualizar(medicamento));
  }

  @override
  Future<void> eliminar(String id) async {
    await _coleccion.doc(id).delete();
  }
}
