import 'dart:async';

import '../domain/toma_medicamento.dart';
import 'tomas_repository.dart';

/// Registros de toma en memoria, con datos de demostración.
class TomasRepositorioMemoria implements TomasRepository {
  TomasRepositorioMemoria({List<TomaMedicamento>? iniciales})
      : _tomas = List<TomaMedicamento>.of(iniciales ?? const <TomaMedicamento>[]);

  factory TomasRepositorioMemoria.demo() {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);
    final tomas = <TomaMedicamento>[];
    for (var dia = 0; dia < 5; dia++) {
      final fecha = inicio.subtract(Duration(days: dia));
      tomas.add(
        TomaMedicamento(
          id: 'demo-toma-$dia',
          medicamentoId: 'demo-med-1',
          fecha: fecha.add(const Duration(hours: 8)),
        ),
      );
    }
    return TomasRepositorioMemoria(iniciales: tomas);
  }

  final List<TomaMedicamento> _tomas;
  final StreamController<List<TomaMedicamento>> _controlador =
      StreamController<List<TomaMedicamento>>.broadcast();

  @override
  Stream<List<TomaMedicamento>> watch({DateTime? desde}) async* {
    yield _filtrar(desde);
    yield* _controlador.stream.map((_) => _filtrar(desde));
  }

  @override
  Future<void> registrar(TomaMedicamento toma) async {
    _tomas.add(
      toma.id.isEmpty
          ? TomaMedicamento(
              id: 'mem-toma-${DateTime.now().microsecondsSinceEpoch}',
              medicamentoId: toma.medicamentoId,
              fecha: toma.fecha,
              tomado: toma.tomado,
            )
          : toma,
    );
    _controlador.add(List<TomaMedicamento>.unmodifiable(_tomas));
  }

  List<TomaMedicamento> _filtrar(DateTime? desde) {
    final lista = _tomas
        .where((toma) => desde == null || !toma.fecha.isBefore(desde))
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    return List<TomaMedicamento>.unmodifiable(lista);
  }

  Future<void> dispose() => _controlador.close();
}
