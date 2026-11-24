import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salud_digital/features/citas/data/citas_repository.dart';
import 'package:salud_digital/features/citas/domain/cita.dart';
import 'package:salud_digital/features/citas/presentation/bloc/citas_bloc.dart';
import 'package:salud_digital/features/citas/presentation/bloc/citas_event.dart';
import 'package:salud_digital/features/citas/presentation/bloc/citas_state.dart';

class _RepositorioFalso implements CitasRepository {
  _RepositorioFalso({this.falla = false, List<Cita>? iniciales})
      : _citas = List<Cita>.of(iniciales ?? const <Cita>[]);

  final bool falla;
  final List<Cita> _citas;
  final StreamController<List<Cita>> _controlador =
      StreamController<List<Cita>>.broadcast();

  @override
  Stream<List<Cita>> watch() => _controlador.stream;

  @override
  Future<List<Cita>> listar() async {
    if (falla) {
      throw Exception('falla de prueba');
    }
    return List<Cita>.unmodifiable(_citas);
  }

  @override
  Future<void> crear(Cita cita) async {
    if (falla) {
      throw Exception('falla de prueba');
    }
    _citas.add(cita);
    _controlador.add(await listar());
  }

  @override
  Future<void> actualizar(Cita cita) async {
    if (falla) {
      throw Exception('falla de prueba');
    }
    final indice = _citas.indexWhere((item) => item.id == cita.id);
    if (indice >= 0) {
      _citas[indice] = cita;
    }
    _controlador.add(await listar());
  }

  @override
  Future<void> eliminar(String id) async {
    if (falla) {
      throw Exception('falla de prueba');
    }
    _citas.removeWhere((cita) => cita.id == id);
    _controlador.add(await listar());
  }
}

Cita _cita(String id, {String especialidad = 'Medicina general'}) => Cita(
      id: id,
      especialidad: especialidad,
      fechaHora: DateTime(2026, 11, 12, 9),
    );

void main() {
  group('CitasBloc', () {
    test('inicia en CitasInicial', () {
      final bloc = CitasBloc(_RepositorioFalso());
      expect(bloc.state, isA<CitasInicial>());
      bloc.close();
    });

    blocTest<CitasBloc, CitasState>(
      'carga las citas del repositorio',
      build: () => CitasBloc(
        _RepositorioFalso(iniciales: <Cita>[_cita('1'), _cita('2')]),
      ),
      act: (bloc) => bloc.add(const CargarCitas()),
      expect: () => <Matcher>[
        isA<CitasCargando>(),
        isA<CitasCargadas>().having(
          (estado) => estado.citas.length,
          'cantidad de citas',
          2,
        ),
      ],
    );

    blocTest<CitasBloc, CitasState>(
      'crea una cita y recibe la lista por el stream',
      build: () => CitasBloc(_RepositorioFalso()),
      act: (bloc) => bloc.add(CrearCita(_cita('nueva'))),
      wait: const Duration(milliseconds: 20),
      expect: () => <Matcher>[
        isA<CitasCargadas>().having(
          (estado) => estado.citas.single.id,
          'id de la cita',
          'nueva',
        ),
      ],
    );

    blocTest<CitasBloc, CitasState>(
      'actualiza una cita existente',
      build: () => CitasBloc(
        _RepositorioFalso(iniciales: <Cita>[_cita('1')]),
      ),
      act: (bloc) => bloc.add(
        ActualizarCita(_cita('1', especialidad: 'Cardiología')),
      ),
      wait: const Duration(milliseconds: 20),
      expect: () => <Matcher>[
        isA<CitasCargadas>().having(
          (estado) => estado.citas.single.especialidad,
          'especialidad',
          'Cardiología',
        ),
      ],
    );

    blocTest<CitasBloc, CitasState>(
      'elimina una cita existente',
      build: () => CitasBloc(
        _RepositorioFalso(iniciales: <Cita>[_cita('1')]),
      ),
      act: (bloc) => bloc.add(const EliminarCita('1')),
      wait: const Duration(milliseconds: 20),
      expect: () => <Matcher>[
        isA<CitasCargadas>().having(
          (estado) => estado.citas,
          'citas restantes',
          isEmpty,
        ),
      ],
    );

    blocTest<CitasBloc, CitasState>(
      'emite CitasError cuando el repositorio falla',
      build: () => CitasBloc(_RepositorioFalso(falla: true)),
      act: (bloc) => bloc.add(const CargarCitas()),
      expect: () => <Matcher>[
        isA<CitasCargando>(),
        isA<CitasError>().having(
          (estado) => estado.mensaje,
          'mensaje',
          contains('cargar'),
        ),
      ],
    );
  });
}
