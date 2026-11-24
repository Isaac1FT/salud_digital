import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/citas_repository.dart';
import '../../domain/cita.dart';
import 'citas_event.dart';
import 'citas_state.dart';

/// Bloque de citas en tiempo real.
///
/// La fuente de verdad es el stream del repositorio; los eventos de creación,
/// actualización y eliminación solo piden el cambio. La lista llega por
/// [CitasCambiaron].
class CitasBloc extends Bloc<CitasEvent, CitasState> {
  CitasBloc(this._repositorio) : super(const CitasInicial()) {
    on<CargarCitas>(_alCargar);
    on<CrearCita>(_alCrear);
    on<ActualizarCita>(_alActualizar);
    on<EliminarCita>(_alEliminar);
    on<CitasCambiaron>(_alCambiar);

    _suscripcion = _repositorio.watch().listen(
      (citas) {
        if (!isClosed) {
          add(CitasCambiaron(citas));
        }
      },
      onError: (Object _) {
        if (!isClosed) {
          add(const CitasCambiaron(null, error: true));
        }
      },
    );
  }

  final CitasRepository _repositorio;
  late final StreamSubscription<List<Cita>> _suscripcion;

  Future<void> _alCargar(
    CargarCitas event,
    Emitter<CitasState> emit,
  ) async {
    emit(const CitasCargando());
    try {
      final citas = await _repositorio.listar();
      emit(CitasCargadas(citas));
    } catch (_) {
      emit(const CitasError('No se pudieron cargar las citas.'));
    }
  }

  Future<void> _alCrear(
    CrearCita event,
    Emitter<CitasState> emit,
  ) async {
    try {
      await _repositorio.crear(event.cita);
    } catch (_) {
      emit(const CitasError('No se pudo guardar la cita. Intenta nuevamente.'));
    }
  }

  Future<void> _alActualizar(
    ActualizarCita event,
    Emitter<CitasState> emit,
  ) async {
    try {
      await _repositorio.actualizar(event.cita);
    } catch (_) {
      emit(const CitasError('No se pudo actualizar la cita.'));
    }
  }

  Future<void> _alEliminar(
    EliminarCita event,
    Emitter<CitasState> emit,
  ) async {
    try {
      await _repositorio.eliminar(event.id);
    } catch (_) {
      emit(const CitasError('No se pudo eliminar la cita.'));
    }
  }

  void _alCambiar(
    CitasCambiaron event,
    Emitter<CitasState> emit,
  ) {
    if (event.error || event.citas == null) {
      emit(const CitasError('No se pudieron cargar las citas.'));
      return;
    }
    emit(CitasCargadas(event.citas!));
  }

  @override
  Future<void> close() async {
    await _suscripcion.cancel();
    return super.close();
  }
}
