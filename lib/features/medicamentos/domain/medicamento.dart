/// Medicamento programado por la persona usuaria.
///
/// `proximaToma` es la próxima fecha y hora en que corresponde la dosis. El
/// recordatorio local de la S7 usará este campo; el tablero de la S6 lo usa
/// para mostrar la toma pendiente.
class Medicamento {
  const Medicamento({
    required this.id,
    required this.nombre,
    required this.dosis,
    required this.proximaToma,
    this.frecuenciaHoras = 24,
    this.activo = true,
    this.creadoEn,
  });

  final String id;
  final String nombre;
  final String dosis;
  final DateTime proximaToma;
  final int frecuenciaHoras;
  final bool activo;
  final DateTime? creadoEn;

  /// Hora en formato de 24 horas, por ejemplo «08:05».
  String get horaTexto {
    final hh = proximaToma.hour.toString().padLeft(2, '0');
    final mm = proximaToma.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  bool get esPendiente =>
      activo && !proximaToma.isAfter(DateTime.now());

  Medicamento copyWith({
    String? id,
    String? nombre,
    String? dosis,
    DateTime? proximaToma,
    int? frecuenciaHoras,
    bool? activo,
    DateTime? creadoEn,
  }) {
    return Medicamento(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      dosis: dosis ?? this.dosis,
      proximaToma: proximaToma ?? this.proximaToma,
      frecuenciaHoras: frecuenciaHoras ?? this.frecuenciaHoras,
      activo: activo ?? this.activo,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
