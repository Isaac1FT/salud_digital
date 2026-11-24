import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/medicamento.dart';

/// Traducción entre [Medicamento] y Firestore.
class MedicamentoDto {
  const MedicamentoDto._();

  static Medicamento desdeDocumento(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final datos = doc.data() ?? const <String, dynamic>{};
    final proxima = datos['proximaToma'];
    final creado = datos['creadoEn'];
    return Medicamento(
      id: doc.id,
      nombre: (datos['nombre'] as String?)?.trim() ?? '',
      dosis: (datos['dosis'] as String?)?.trim() ?? '',
      proximaToma:
          proxima is Timestamp ? proxima.toDate() : DateTime.now(),
      frecuenciaHoras: (datos['frecuenciaHoras'] as num?)?.toInt() ?? 24,
      activo: (datos['activo'] as bool?) ?? true,
      creadoEn: creado is Timestamp ? creado.toDate() : null,
    );
  }

  static Map<String, Object?> aCrear(Medicamento medicamento) {
    return <String, Object?>{
      'nombre': medicamento.nombre.trim(),
      'dosis': medicamento.dosis.trim(),
      'proximaToma': Timestamp.fromDate(medicamento.proximaToma),
      'frecuenciaHoras': medicamento.frecuenciaHoras,
      'activo': medicamento.activo,
      'creadoEn': FieldValue.serverTimestamp(),
      'actualizadoEn': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, Object?> aActualizar(Medicamento medicamento) {
    return <String, Object?>{
      'nombre': medicamento.nombre.trim(),
      'dosis': medicamento.dosis.trim(),
      'proximaToma': Timestamp.fromDate(medicamento.proximaToma),
      'frecuenciaHoras': medicamento.frecuenciaHoras,
      'activo': medicamento.activo,
      'actualizadoEn': FieldValue.serverTimestamp(),
    };
  }
}
