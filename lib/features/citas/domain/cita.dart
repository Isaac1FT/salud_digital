/// Estado de una cita médica.
enum EstadoCita { programada, completada }

/// Cita médica del adulto mayor.
///
/// Entidad de dominio: no depende de Flutter ni de Firebase. El mapeo a
/// Firestore vive en la capa de datos (`CitaDto`).
class Cita {
  const Cita({
    required this.id,
    required this.especialidad,
    required this.fechaHora,
    this.nota,
    this.estado = EstadoCita.programada,
    this.creadoEn,
  });

  final String id;
  final String especialidad;
  final DateTime fechaHora;
  final String? nota;
  final EstadoCita estado;
  final DateTime? creadoEn;

  bool get esFutura => fechaHora.isAfter(DateTime.now());

  Cita copyWith({
    String? id,
    String? especialidad,
    DateTime? fechaHora,
    String? nota,
    EstadoCita? estado,
    DateTime? creadoEn,
  }) {
    return Cita(
      id: id ?? this.id,
      especialidad: especialidad ?? this.especialidad,
      fechaHora: fechaHora ?? this.fechaHora,
      nota: nota ?? this.nota,
      estado: estado ?? this.estado,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
