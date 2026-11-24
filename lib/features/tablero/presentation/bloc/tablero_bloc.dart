import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../citas/data/citas_repository.dart';
import '../../../citas/domain/cita.dart';
import '../../../medicamentos/data/medicamentos_repository.dart';
import '../../../medicamentos/data/tomas_repository.dart';
import '../../../medicamentos/domain/medicamento.dart';
import '../../../medicamentos/domain/toma_medicamento.dart';
import '../../domain/tablero.dart';

sealed class TableroState {
  const TableroState();
}

final class TableroInicial extends TableroState {
  const TableroInicial();
}

final class TableroCargando extends TableroState {
  const TableroCargando();
}

final class TableroCargado extends TableroState {
  const TableroCargado(this.resumen);

  final ResumenTablero resumen;
}

final class TableroError extends TableroState {
  const TableroError(this.mensaje);

  final String mensaje;
}

/// Bloque que combina citas, medicamentos y tomas en un resumen.
class TableroBloc extends Bloc<TableroEvent, TableroState> {
  TableroBloc({
    required CitasRepository citas,
    required MedicamentosRepository medicamentos,
    required TomasRepository tomas,
    DateTime? desde,
  }) : super(const TableroInicial()) {
    on<_TableroListo>(_alListo);
    on<_TableroFallo>(_alFallar);

    final corte = desde ??
        DateTime.now().subtract(const Duration(days: 7));
    _suscripciones.add(
      citas.watch().listen(
        (lista) {
          _citas = lista;
          _recalcular();
        },
        onError: (Object _) => add(const _TableroFallo()),
      ),
    );
    _suscripciones.add(
      medicamentos.watch().listen(
        (lista) {
          _medicamentos = lista;
          _recalcular();
        },
        onError: (Object _) => add(const _TableroFallo()),
      ),
    );
    _suscripciones.add(
      tomas.watch(desde: corte).listen(
        (lista) {
          _tomasRegistradas = lista;
          _recalcular();
        },
        onError: (Object _) => add(const _TableroFallo()),
      ),
    );
  }

  final List<StreamSubscription<dynamic>> _suscripciones =
      <StreamSubscription<dynamic>>[];

  List<Cita>? _citas;
  List<Medicamento>? _medicamentos;
  List<TomaMedicamento>? _tomasRegistradas;

  void _recalcular() {
    if (_citas == null ||
        _medicamentos == null ||
        _tomasRegistradas == null) {
      return;
    }
    add(
      _TableroListo(
        ResumenTablero.calcular(
          citas: _citas!,
          medicamentos: _medicamentos!,
          tomas: _tomasRegistradas!,
        ),
      ),
    );
  }

  void _alListo(_TableroListo event, Emitter<TableroState> emit) {
    emit(TableroCargado(event.resumen));
  }

  void _alFallar(_TableroFallo event, Emitter<TableroState> emit) {
    emit(const TableroError('No se pudo cargar el tablero.'));
  }

  @override
  Future<void> close() async {
    for (final suscripcion in _suscripciones) {
      await suscripcion.cancel();
    }
    return super.close();
  }
}

sealed class TableroEvent {
  const TableroEvent();
}

final class _TableroListo extends TableroEvent {
  const _TableroListo(this.resumen);

  final ResumenTablero resumen;
}

final class _TableroFallo extends TableroEvent {
  const _TableroFallo();
}
