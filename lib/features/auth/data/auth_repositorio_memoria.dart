import 'dart:async';

import '../domain/usuario.dart';
import 'auth_repository.dart';

/// Implementación de demostración.
///
/// No usa Firebase: permite ejecutar y probar la app sin red ni proyecto de
/// Firebase. En S2 la app usa `AuthFirebaseRepository` cuando Firebase está
/// inicializado y cae en esta implementación cuando no lo está.
class AuthRepositorioMemoria implements AuthRepository {
  /// Si [conSesionDemo] es `true`, la app abre con una sesión ya iniciada.
  AuthRepositorioMemoria({bool conSesionDemo = false})
      : _usuario = conSesionDemo ? _usuarioDemo : null;

  static const Usuario _usuarioDemo = Usuario(
    id: 'demo',
    correo: 'demo@uandina.edu.pe',
    nombre: 'Usuario de demostración',
  );

  final StreamController<Usuario?> _controlador =
      StreamController<Usuario?>.broadcast();

  Usuario? _usuario;

  @override
  Future<Usuario?> usuarioActual() async => _usuario;

  /// Emite el estado actual al suscribirse y luego los cambios.
  ///
  /// El contrato exige un evento inicial para que la app no quede en
  /// «verificando»; Firebase lo hace de forma nativa con `authStateChanges`.
  @override
  Stream<Usuario?> get cambiosDeSesion async* {
    yield _usuario;
    yield* _controlador.stream;
  }

  @override
  Future<Usuario> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _validar(correo: correo, contrasena: contrasena);

    final usuario = _crearUsuario(correo);
    _usuario = usuario;
    _controlador.add(usuario);
    return usuario;
  }

  @override
  Future<Usuario> registrar({
    required String correo,
    required String contrasena,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _validar(correo: correo, contrasena: contrasena);

    final usuario = _crearUsuario(correo);
    _usuario = usuario;
    _controlador.add(usuario);
    return usuario;
  }

  @override
  Future<void> cerrarSesion() async {
    _usuario = null;
    _controlador.add(null);
  }

  void _validar({required String correo, required String contrasena}) {
    if (!correo.contains('@')) {
      throw const AuthException('Escribe un correo electrónico válido.');
    }
    if (contrasena.length < 8) {
      throw const AuthException('La contraseña debe tener al menos 8 caracteres.');
    }
  }

  Usuario _crearUsuario(String correo) {
    final normalizado = correo.trim().toLowerCase();
    return Usuario(
      id: normalizado,
      correo: normalizado,
      nombre: normalizado.split('@').first,
    );
  }

  /// Libera el controlador del stream. Se usa en pruebas.
  Future<void> dispose() => _controlador.close();
}
