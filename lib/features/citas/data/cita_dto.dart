import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/cita.dart';

/// Traducción entre [Cita] y los documentos de Firestore.
///
/// Mantiene el dominio libre de `cloud_firestore`: los `Timestamp` y los
/// `FieldValue` se manejan solo en esta capa.
class CitaDto {
  const CitaDto._();

  static Cita desdeDocumento(DocumentSnapshot<Map<String, dynamic>> doc) {
    final datos = doc.data() ?? const <String, dynamic>{};
    final fecha = datos['fechaHora'];
    final creada = datos['creadoEn'];
    return Cita(
      id: doc.id,
      especialidad: (datos['especialidad'] as String?)?.trim() ?? '',
      fechaHora: fecha is Timestamp ? fecha.toDate() : DateTime.now(),
      nota: (datos['nota'] as String?)?.trim(),
      estado: EstadoCita.values.firstWhere(
        (valor) => valor.name == datos['estado'],
        orElse: () => EstadoCita.programada,
      ),
      creadoEn: creada is Timestamp ? creada.toDate() : null,
    );
  }

  static Map<String, Object?> aCrear(Cita cita) {
    return <String, Object?>{
      'especialidad': cita.especialidad.trim(),
      'fechaHora': Timestamp.fromDate(cita.fechaHora),
      'nota': (cita.nota ?? '').trim().isEmpty ? null : cita.nota!.trim(),
      'estado': cita.estado.name,
      'creadoEn': FieldValue.serverTimestamp(),
      'actualizadoEn': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, Object?> aActualizar(Cita cita) {
    return <String, Object?>{
      'especialidad': cita.especialidad.trim(),
      'fechaHora': Timestamp.fromDate(cita.fechaHora),
      'nota': (cita.nota ?? '').trim().isEmpty ? null : cita.nota!.trim(),
      'estado': cita.estado.name,
      'actualizadoEn': FieldValue.serverTimestamp(),
    };
  }
}
