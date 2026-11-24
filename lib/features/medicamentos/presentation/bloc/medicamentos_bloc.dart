import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/medicamentos_repository.dart';
import '../../domain/medicamento.dart';
import 'medicamentos_event.dart';
import 'medicamentos_state.dart';

/// Bloque de medicamentos en tiempo real.
class MedicamentosBloc extends Bloc<MedicamentosEvent, MedicamentosState> {
  MedicamentosBloc(this._repositorio) : super(const MedicamentosInicial()) {
    on<CargarMedicamentos>(_alCargar);
    on<CrearMedicamento>(_alCrear);
    on<ActualizarMedicamento>(_alActualizar);
    on<EliminarMedicamento>(_alEliminar);
    on<MedicamentosCambiaron>(_alCambiar);

    _suscripcion = _repositorio.watch().listen(
      (medicamentos) {
        if (!isClosed) {
          add(MedicamentosCambiaron(medicamentos));
        }
      },
      onError: (Object _) {
        if (!isClosed) {
          add(const MedicamentosCambiaron(null, error: true));
        }
      },
    );
  }

  final MedicamentosRepository _repositorio;
  late final StreamSubscription<List<Medicamento>> _suscripcion;

  Future<void> _alCargar(
    CargarMedicamentos event,
    Emitter<MedicamentosState> emit,
  ) async {
    emit(const MedicamentosCargando());
    try {
      final medicamentos = await _repositorio.listar();
      emit(MedicamentosCargados(medicamentos));
    } catch (_) {
      emit(const MedicamentosError(
        'No se pudieron cargar los medicamentos.',
      ));
    }
  }

  Future<void> _alCrear(
    CrearMedicamento event,
    Emitter<MedicamentosState> emit,
  ) async {
    try {
      await _repositorio.crear(event.medicamento);
    } catch (_) {
      emit(const MedicamentosError(
        'No se pudo guardar el medicamento. Intenta nuevamente.',
      ));
    }
  }

  Future<void> _alActualizar(
    ActualizarMedicamento event,
    Emitter<MedicamentosState> emit,
  ) async {
    try {
      await _repositorio.actualizar(event.medicamento);
    } catch (_) {
      emit(const MedicamentosError(
        'No se pudo actualizar el medicamento.',
      ));
    }
  }

  Future<void> _alEliminar(
    EliminarMedicamento event,
    Emitter<MedicamentosState> emit,
  ) async {
    try {
      await _repositorio.eliminar(event.id);
    } catch (_) {
      emit(const MedicamentosError(
        'No se pudo eliminar el medicamento.',
      ));
    }
  }

  void _alCambiar(
    MedicamentosCambiaron event,
    Emitter<MedicamentosState> emit,
  ) {
    if (event.error || event.medicamentos == null) {
      emit(const MedicamentosError(
        'No se pudieron cargar los medicamentos.',
      ));
      return;
    }
    emit(MedicamentosCargados(event.medicamentos!));
  }

  @override
  Future<void> close() async {
    await _suscripcion.cancel();
    return super.close();
  }
}
