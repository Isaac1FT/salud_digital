import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/errores_auth.dart';
import '../domain/usuario.dart';
import 'auth_repository.dart';

/// Implementación de autenticación con Firebase.
///
/// Es el único archivo de la app (junto con el traductor de errores) que
/// importa `firebase_auth`. El bloque y la interfaz dependen del contrato.
class AuthFirebaseRepository implements AuthRepository {
  AuthFirebaseRepository({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<Usuario?> usuarioActual() async => _mapear(_auth.currentUser);

  @override
  Stream<Usuario?> get cambiosDeSesion =>
      _auth.authStateChanges().map(_mapear);

  @override
  Future<Usuario> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: correo.trim(),
        password: contrasena,
      );
      return _usuarioDe(credencial);
    } on FirebaseAuthException catch (error) {
      throw AuthException(mensajeDeErrorAutenticacion(error));
    }
  }

  @override
  Future<Usuario> registrar({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: correo.trim(),
        password: contrasena,
      );
      return _usuarioDe(credencial);
    } on FirebaseAuthException catch (error) {
      throw AuthException(mensajeDeErrorAutenticacion(error));
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthException(mensajeDeErrorAutenticacion(error));
    }
  }

  Usuario _usuarioDe(UserCredential credencial) {
    final usuario = _mapear(credencial.user);
    if (usuario == null) {
      throw const AuthException('No se pudo obtener la cuenta.');
    }
    return usuario;
  }

  Usuario? _mapear(User? user) {
    if (user == null) {
      return null;
    }
    final correo = user.email ?? '';
    final nombre = (user.displayName ?? '').trim();
    return Usuario(
      id: user.uid,
      correo: correo,
      nombre: nombre.isEmpty ? _nombreDesdeCorreo(correo) : nombre,
    );
  }

  String _nombreDesdeCorreo(String correo) {
    final partes = correo.split('@');
    return partes.first.isEmpty ? 'Usuario' : partes.first;
  }
}
