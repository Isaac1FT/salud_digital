import 'dart:async';

import '../domain/medicamento.dart';
import 'medicamentos_repository.dart';

/// Repositorio en memoria para demostración y pruebas.
class MedicamentosRepositorioMemoria implements MedicamentosRepository {
  MedicamentosRepositorioMemoria({List<Medicamento>? iniciales})
      : _medicamentos = List<Medicamento>.of(iniciales ?? const <Medicamento>[]);

  factory MedicamentosRepositorioMemoria.demo() {
    final ahora = DateTime.now();
    return MedicamentosRepositorioMemoria(
      iniciales: <Medicamento>[
        Medicamento(
          id: 'demo-med-1',
          nombre: 'Enalapril',
          dosis: '10 mg',
          proximaToma: DateTime(ahora.year, ahora.month, ahora.day, 8),
        ),
        Medicamento(
          id: 'demo-med-2',
          nombre: 'Metformina',
          dosis: '850 mg',
          proximaToma: ahora.add(const Duration(hours: 6)),
          frecuenciaHoras: 12,
        ),
      ],
    );
  }

  final List<Medicamento> _medicamentos;
  final StreamController<List<Medicamento>> _controlador =
      StreamController<List<Medicamento>>.broadcast();

  @override
  Stream<List<Medicamento>> watch() async* {
    yield await listar();
    yield* _controlador.stream;
  }

  @override
  Future<List<Medicamento>> listar() async {
    final ordenados = List<Medicamento>.of(_medicamentos)
      ..sort((a, b) => a.proximaToma.compareTo(b.proximaToma));
    return List<Medicamento>.unmodifiable(ordenados);
  }

  @override
  Future<void> crear(Medicamento medicamento) async {
    final nuevo = medicamento.id.isEmpty
        ? medicamento.copyWith(
            id: 'mem-med-${DateTime.now().microsecondsSinceEpoch}',
          )
        : medicamento;
    _medicamentos.add(nuevo);
    await _emitir();
  }

  @override
  Future<void> actualizar(Medicamento medicamento) async {
    final indice = _medicamentos.indexWhere((item) => item.id == medicamento.id);
    if (indice < 0) {
      throw StateError('El medicamento no existe.');
    }
    _medicamentos[indice] = medicamento;
    await _emitir();
  }

  @override
  Future<void> eliminar(String id) async {
    _medicamentos.removeWhere((medicamento) => medicamento.id == id);
    await _emitir();
  }

  Future<void> _emitir() async {
    _controlador.add(await listar());
  }

  Future<void> dispose() => _controlador.close();
}
