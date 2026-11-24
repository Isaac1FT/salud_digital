import '../../citas/domain/cita.dart';
import '../../medicamentos/domain/medicamento.dart';
import '../../medicamentos/domain/toma_medicamento.dart';

/// Adherencia de un día.
class AdherenciaDia {
  const AdherenciaDia({
    required this.dia,
    required this.esperadas,
    required this.registradas,
  });

  final DateTime dia;
  final int esperadas;
  final int registradas;

  double get porcentaje {
    if (esperadas == 0) return 0;
    return registradas / esperadas;
  }
}

/// Resumen semanal de adherencia.
class ResumenAdherencia {
  const ResumenAdherencia(this.dias);

  final List<AdherenciaDia> dias;

  int get esperadas =>
      dias.fold(0, (total, dia) => total + dia.esperadas);

  int get registradas =>
      dias.fold(0, (total, dia) => total + dia.registradas);

  double get porcentaje {
    if (esperadas == 0) return 0;
    return registradas / esperadas;
  }

  int get porcentajeEntero => (porcentaje * 100).round();
}

/// Datos que alimentan el tablero.
class ResumenTablero {
  const ResumenTablero({
    required this.proximaCita,
    required this.proximoMedicamento,
    required this.adherencia,
    required this.medicamentosActivos,
  });

  final Cita? proximaCita;
  final Medicamento? proximoMedicamento;
  final ResumenAdherencia adherencia;
  final int medicamentosActivos;

  /// Calcula el tablero a partir de las tres fuentes.
  ///
  /// Supuesto de la unidad: cada medicamento activo aporta una toma esperada
  /// por día. La frecuencia se usa para el recordatorio de la S7, no para
  /// multiplicar la adherencia.
  factory ResumenTablero.calcular({
    required List<Cita> citas,
    required List<Medicamento> medicamentos,
    required List<TomaMedicamento> tomas,
    DateTime? ahora,
  }) {
    final hoy = ahora ?? DateTime.now();
    final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final inicioSemana = inicioHoy.subtract(const Duration(days: 6));

    final activos = medicamentos.where((m) => m.activo).toList()
      ..sort((a, b) => a.proximaToma.compareTo(b.proximaToma));

    final proximaCita = citas
        .where((c) => c.estado == EstadoCita.programada)
        .where((c) => !c.fechaHora.isBefore(hoy))
        .toList()
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

    final idsActivos = activos.map((m) => m.id).toSet();
    final dias = <AdherenciaDia>[];
    for (var i = 0; i < 7; i++) {
      final dia = inicioSemana.add(Duration(days: i));
      final fin = dia.add(const Duration(days: 1));
      final registradas = tomas
          .where((t) => t.tomado)
          .where((t) => idsActivos.contains(t.medicamentoId))
          .where((t) => !t.fecha.isBefore(dia) && t.fecha.isBefore(fin))
          .map((t) => t.medicamentoId)
          .toSet()
          .length;
      dias.add(
        AdherenciaDia(
          dia: dia,
          esperadas: activos.length,
          registradas: registradas,
        ),
      );
    }

    return ResumenTablero(
      proximaCita: proximaCita.isEmpty ? null : proximaCita.first,
      proximoMedicamento: activos.isEmpty ? null : activos.first,
      adherencia: ResumenAdherencia(List<AdherenciaDia>.unmodifiable(dias)),
      medicamentosActivos: activos.length,
    );
  }
}
