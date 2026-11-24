import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salud_digital/features/medicamentos/data/medicamentos_repository.dart';
import 'package:salud_digital/features/medicamentos/domain/medicamento.dart';
import 'package:salud_digital/features/medicamentos/presentation/bloc/medicamentos_bloc.dart';
import 'package:salud_digital/features/medicamentos/presentation/bloc/medicamentos_event.dart';
import 'package:salud_digital/features/medicamentos/presentation/bloc/medicamentos_state.dart';

class _RepositorioFalso implements MedicamentosRepository {
  _RepositorioFalso({this.falla = false, List<Medicamento>? iniciales})
      : _medicamentos = List<Medicamento>.of(iniciales ?? const <Medicamento>[]);

  final bool falla;
  final List<Medicamento> _medicamentos;
  final StreamController<List<Medicamento>> _controlador =
      StreamController<List<Medicamento>>.broadcast();

  @override
  Stream<List<Medicamento>> watch() => _controlador.stream;

  @override
  Future<List<Medicamento>> listar() async {
    if (falla) {
      throw Exception('falla de prueba');
    }
    return List<Medicamento>.unmodifiable(_medicamentos);
  }

  @override
  Future<void> crear(Medicamento medicamento) async {
    if (falla) {
      throw Exception('falla de prueba');
    }
    _medicamentos.add(medicamento);
    _controlador.add(await listar());
  }

  @override
  Future<void> actualizar(Medicamento medicamento) async {
    if (falla) {
      throw Exception('falla de prueba');
    }
    final indice = _medicamentos.indexWhere(
      (item) => item.id == medicamento.id,
    );
    if (indice >= 0) {
      _medicamentos[indice] = medicamento;
    }
    _controlador.add(await listar());
  }

  @override
  Future<void> eliminar(String id) async {
    if (falla) {
      throw Exception('falla de prueba');
    }
    _medicamentos.removeWhere((medicamento) => medicamento.id == id);
    _controlador.add(await listar());
  }
}

Medicamento _medicamento(String id, {String nombre = 'Enalapril'}) =>
    Medicamento(
      id: id,
      nombre: nombre,
      dosis: '10 mg',
      proximaToma: DateTime(2026, 11, 20, 8),
    );

void main() {
  group('MedicamentosBloc', () {
    test('inicia en MedicamentosInicial', () {
      final bloc = MedicamentosBloc(_RepositorioFalso());
      expect(bloc.state, isA<MedicamentosInicial>());
      bloc.close();
    });

    blocTest<MedicamentosBloc, MedicamentosState>(
      'carga los medicamentos del repositorio',
      build: () => MedicamentosBloc(
        _RepositorioFalso(
          iniciales: <Medicamento>[
            _medicamento('1'),
            _medicamento('2'),
          ],
        ),
      ),
      act: (bloc) => bloc.add(const CargarMedicamentos()),
      expect: () => <Matcher>[
        isA<MedicamentosCargando>(),
        isA<MedicamentosCargados>().having(
          (estado) => estado.medicamentos.length,
          'cantidad',
          2,
        ),
      ],
    );

    blocTest<MedicamentosBloc, MedicamentosState>(
      'crea un medicamento y recibe la lista por el stream',
      build: () => MedicamentosBloc(_RepositorioFalso()),
      act: (bloc) => bloc.add(CrearMedicamento(_medicamento('nuevo'))),
      wait: const Duration(milliseconds: 20),
      expect: () => <Matcher>[
        isA<MedicamentosCargados>().having(
          (estado) => estado.medicamentos.single.id,
          'id',
          'nuevo',
        ),
      ],
    );

    blocTest<MedicamentosBloc, MedicamentosState>(
      'actualiza un medicamento',
      build: () => MedicamentosBloc(
        _RepositorioFalso(iniciales: <Medicamento>[_medicamento('1')]),
      ),
      act: (bloc) => bloc.add(
        ActualizarMedicamento(_medicamento('1', nombre: 'Losartán')),
      ),
      wait: const Duration(milliseconds: 20),
      expect: () => <Matcher>[
        isA<MedicamentosCargados>().having(
          (estado) => estado.medicamentos.single.nombre,
          'nombre',
          'Losartán',
        ),
      ],
    );

    blocTest<MedicamentosBloc, MedicamentosState>(
      'emite error cuando el repositorio falla',
      build: () => MedicamentosBloc(_RepositorioFalso(falla: true)),
      act: (bloc) => bloc.add(const CargarMedicamentos()),
      expect: () => <Matcher>[
        isA<MedicamentosCargando>(),
        isA<MedicamentosError>(),
      ],
    );
  });
}
