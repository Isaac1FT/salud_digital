import '../domain/usuario.dart';

/// Error de autenticación con un mensaje apto para la persona usuaria.
class AuthException implements Exception {
  const AuthException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Contrato de autenticación.
///
/// En S1 lo implementa `AuthRepositorioMemoria`; en S2 se usa
/// `AuthFirebaseRepository`. El bloque y la pantalla dependen solo de este
/// contrato.
abstract interface class AuthRepository {
  /// Devuelve el usuario de la sesión actual o `null` si no hay sesión.
  Future<Usuario?> usuarioActual();

  /// Emite el estado actual al suscribirse y luego cada cambio de sesión.
  Stream<Usuario?> get cambiosDeSesion;

  /// Inicia sesión y devuelve el usuario autenticado.
  ///
  /// Lanza [AuthException] cuando las credenciales no son válidas.
  Future<Usuario> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  /// Crea una cuenta y deja la sesión iniciada.
  ///
  /// Lanza [AuthException] cuando el correo ya existe o la contraseña es débil.
  Future<Usuario> registrar({
    required String correo,
    required String contrasena,
  });

  /// Cierra la sesión actual.
  Future<void> cerrarSesion();
}
