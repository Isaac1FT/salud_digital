import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salud_digital/core/utils/errores_auth.dart';

FirebaseAuthException _error(String code) =>
    FirebaseAuthException(code: code, message: 'mensaje crudo del SDK');

void main() {
  group('mensajeDeErrorAutenticacion', () {
    test('credenciales incorrectas no revelan si el correo existe', () {
      const esperado = 'El correo o la contraseña no son correctos.';
      expect(
        mensajeDeErrorAutenticacion(_error('invalid-credential')),
        esperado,
      );
      expect(
        mensajeDeErrorAutenticacion(_error('wrong-password')),
        esperado,
      );
      expect(
        mensajeDeErrorAutenticacion(_error('user-not-found')),
        esperado,
      );
    });

    test('correo ya registrado', () {
      expect(
        mensajeDeErrorAutenticacion(_error('email-already-in-use')),
        contains('Ya existe una cuenta'),
      );
    });

    test('contraseña débil', () {
      expect(
        mensajeDeErrorAutenticacion(_error('weak-password')),
        contains('8 caracteres'),
      );
    });

    test('problemas de red', () {
      expect(
        mensajeDeErrorAutenticacion(_error('network-request-failed')),
        contains('Sin conexión'),
      );
    });

    test('demasiados intentos', () {
      expect(
        mensajeDeErrorAutenticacion(_error('too-many-requests')),
        contains('Demasiados intentos'),
      );
    });

    test('proveedor no habilitado', () {
      expect(
        mensajeDeErrorAutenticacion(_error('operation-not-allowed')),
        contains('no está habilitado'),
      );
    });

    test('código desconocido usa un mensaje genérico', () {
      expect(
        mensajeDeErrorAutenticacion(_error('codigo-desconocido')),
        contains('No se pudo completar'),
      );
    });
  });
}
