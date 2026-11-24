import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/toma_medicamento.dart';
import 'toma_dto.dart';
import 'tomas_repository.dart';

/// Tomas sobre Firestore: `usuarios/{uid}/tomas/{tomaId}`.
class FirestoreTomasRepository implements TomasRepository {
  FirestoreTomasRepository({
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
    return _db.collection('usuarios').doc(uid).collection('tomas');
  }

  @override
  Stream<List<TomaMedicamento>> watch({DateTime? desde}) {
    Query<Map<String, dynamic>> consulta = _coleccion;
    if (desde != null) {
      consulta = consulta.where(
        'fecha',
        isGreaterThanOrEqualTo: Timestamp.fromDate(desde),
      );
    }
    return consulta.orderBy('fecha').snapshots().map(
          (snapshot) =>
              snapshot.docs.map(TomaDto.desdeDocumento).toList(),
        );
  }

  @override
  Future<void> registrar(TomaMedicamento toma) async {
    await _coleccion.add(TomaDto.aCrear(toma));
  }
}
