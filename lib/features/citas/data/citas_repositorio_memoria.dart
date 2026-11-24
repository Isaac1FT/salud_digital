import 'dart:async';

import '../domain/cita.dart';
import 'citas_repository.dart';

/// Repositorio en memoria para demostración y pruebas.
class CitasRepositorioMemoria implements CitasRepository {
  CitasRepositorioMemoria({List<Cita>? iniciales})
      : _citas = List<Cita>.of(iniciales ?? const <Cita>[]);

  factory CitasRepositorioMemoria.demo() {
    final ahora = DateTime.now();
    return CitasRepositorioMemoria(
      iniciales: <Cita>[
        Cita(
          id: 'demo-1',
          especialidad: 'Medicina general',
          fechaHora: ahora.add(const Duration(days: 2, hours: 1)),
          nota: 'Llevar los resultados de laboratorio.',
        ),
        Cita(
          id: 'demo-2',
          especialidad: 'Oftalmología',
          fechaHora: ahora.add(const Duration(days: 10)),
        ),
      ],
    );
  }

  final List<Cita> _citas;
  final StreamController<List<Cita>> _controlador =
      StreamController<List<Cita>>.broadcast();

  @override
  Stream<List<Cita>> watch() async* {
    yield await listar();
    yield* _controlador.stream;
  }

  @override
  Future<List<Cita>> listar() async {
    final ordenadas = List<Cita>.of(_citas)
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
    return List<Cita>.unmodifiable(ordenadas);
  }

  @override
  Future<void> crear(Cita cita) async {
    final nueva = cita.id.isEmpty
        ? cita.copyWith(id: 'mem-${DateTime.now().microsecondsSinceEpoch}')
        : cita;
    _citas.add(nueva);
    await _emitir();
  }

  @override
  Future<void> actualizar(Cita cita) async {
    final indice = _citas.indexWhere((item) => item.id == cita.id);
    if (indice < 0) {
      throw StateError('La cita no existe.');
    }
    _citas[indice] = cita;
    await _emitir();
  }

  @override
  Future<void> eliminar(String id) async {
    _citas.removeWhere((cita) => cita.id == id);
    await _emitir();
  }

  Future<void> _emitir() async {
    _controlador.add(await listar());
  }

  Future<void> dispose() => _controlador.close();
}
