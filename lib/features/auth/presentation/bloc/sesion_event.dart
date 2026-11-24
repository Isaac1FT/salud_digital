import '../../domain/usuario.dart';

/// Eventos del bloque de sesión.
sealed class SesionEvent {
  const SesionEvent();
}

/// Pide verificar si existe una sesión activa.
final class VerificarSesion extends SesionEvent {
  const VerificarSesion();
}

/// Solicita iniciar sesión con correo y contraseña.
final class IniciarSesion extends SesionEvent {
  const IniciarSesion({
    required this.correo,
    required this.contrasena,
  });

  final String correo;
  final String contrasena;
}

/// Solicita crear una cuenta nueva.
final class RegistrarUsuario extends SesionEvent {
  const RegistrarUsuario({
    required this.correo,
    required this.contrasena,
  });

  final String correo;
  final String contrasena;
}

/// Solicita cerrar la sesión actual.
final class CerrarSesion extends SesionEvent {
  const CerrarSesion();
}

/// Evento interno que traduce el stream de sesión a la cola del bloque.
///
/// No se agrega desde la interfaz: lo usa [SesionBloc] al recibir un cambio
/// del repositorio.
final class SesionCambiada extends SesionEvent {
  const SesionCambiada(this.usuario, {this.error = false});

  final Usuario? usuario;
  final bool error;
}
