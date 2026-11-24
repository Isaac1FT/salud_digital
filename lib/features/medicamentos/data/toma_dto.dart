import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/toma_medicamento.dart';

/// Traducción entre [TomaMedicamento] y Firestore.
class TomaDto {
  const TomaDto._();

  static TomaMedicamento desdeDocumento(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final datos = doc.data() ?? const <String, dynamic>{};
    final fecha = datos['fecha'];
    return TomaMedicamento(
      id: doc.id,
      medicamentoId: (datos['medicamentoId'] as String?) ?? '',
      fecha: fecha is Timestamp ? fecha.toDate() : DateTime.now(),
      tomado: (datos['tomado'] as bool?) ?? true,
    );
  }

  static Map<String, Object?> aCrear(TomaMedicamento toma) {
    return <String, Object?>{
      'medicamentoId': toma.medicamentoId,
      'fecha': Timestamp.fromDate(toma.fecha),
      'tomado': toma.tomado,
      'creadoEn': FieldValue.serverTimestamp(),
    };
  }
}
