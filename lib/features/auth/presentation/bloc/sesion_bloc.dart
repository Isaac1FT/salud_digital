import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../../domain/usuario.dart';
import 'sesion_event.dart';
import 'sesion_state.dart';

/// Bloque de sesión.
///
/// La fuente de verdad es el stream de autenticación del repositorio. Los
/// eventos representan intenciones; el estado final siempre llega por
/// [SesionCambiada]. Así se evita tener dos verdades y dos reconstrucciones.
class SesionBloc extends Bloc<SesionEvent, SesionState> {
  SesionBloc(this._repositorio) : super(const SesionVerificando()) {
    on<VerificarSesion>(_alVerificar);
    on<IniciarSesion>(_alIniciar);
    on<RegistrarUsuario>(_alRegistrar);
    on<CerrarSesion>(_alCerrar);
    on<SesionCambiada>(_alCambiar);

    _suscripcion = _repositorio.cambiosDeSesion.listen(
      (usuario) {
        if (!isClosed) {
          add(SesionCambiada(usuario));
        }
      },
      onError: (Object _) {
        if (!isClosed) {
          add(const SesionCambiada(null, error: true));
        }
      },
    );
  }

  final AuthRepository _repositorio;
  late final StreamSubscription<Usuario?> _suscripcion;

  Future<void> _alVerificar(
    VerificarSesion event,
    Emitter<SesionState> emit,
  ) async {
    emit(const SesionVerificando());
    try {
      final usuario = await _repositorio.usuarioActual();
      emit(
        usuario == null
            ? const SesionSinUsuario()
            : SesionConUsuario(usuario),
      );
    } catch (_) {
      emit(const SesionError('No se pudo verificar la sesión.'));
    }
  }

  Future<void> _alIniciar(
    IniciarSesion event,
    Emitter<SesionState> emit,
  ) async {
    emit(const SesionIniciando());
    try {
      await _repositorio.iniciarSesion(
        correo: event.correo,
        contrasena: event.contrasena,
      );
      // ConUsuario llega por SesionCambiada, desde el stream.
    } on AuthException catch (error) {
      emit(SesionError(error.mensaje));
    } catch (_) {
      emit(const SesionError('No se pudo iniciar sesión. Intenta nuevamente.'));
    }
  }

  Future<void> _alRegistrar(
    RegistrarUsuario event,
    Emitter<SesionState> emit,
  ) async {
    emit(const SesionRegistrando());
    try {
      await _repositorio.registrar(
        correo: event.correo,
        contrasena: event.contrasena,
      );
      // Firebase deja la sesión iniciada; el stream emite ConUsuario.
    } on AuthException catch (error) {
      emit(SesionError(error.mensaje));
    } catch (_) {
      emit(const SesionError('No se pudo crear la cuenta. Intenta nuevamente.'));
    }
  }

  Future<void> _alCerrar(
    CerrarSesion event,
    Emitter<SesionState> emit,
  ) async {
    try {
      await _repositorio.cerrarSesion();
      // El stream emite null y el estado pasa a SinUsuario.
    } catch (_) {
      emit(const SesionError('No se pudo cerrar la sesión.'));
    }
  }

  void _alCambiar(
    SesionCambiada event,
    Emitter<SesionState> emit,
  ) {
    if (event.error) {
      emit(const SesionError('Se perdió la conexión con la sesión.'));
      return;
    }
    final usuario = event.usuario;
    emit(
      usuario == null
          ? const SesionSinUsuario()
          : SesionConUsuario(usuario),
    );
  }

  @override
  Future<void> close() async {
    await _suscripcion.cancel();
    return super.close();
  }
}
