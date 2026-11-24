import '../domain/toma_medicamento.dart';

/// Contrato de los registros de toma.
abstract interface class TomasRepository {
  /// Emite las tomas desde [desde] (por defecto, los últimos 7 días).
  Stream<List<TomaMedicamento>> watch({DateTime? desde});

  Future<void> registrar(TomaMedicamento toma);
}
