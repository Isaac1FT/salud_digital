import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salud_digital/features/auth/data/auth_repository.dart';
import 'package:salud_digital/features/auth/domain/usuario.dart';
import 'package:salud_digital/features/auth/presentation/bloc/sesion_bloc.dart';
import 'package:salud_digital/features/auth/presentation/bloc/sesion_event.dart';
import 'package:salud_digital/features/auth/presentation/bloc/sesion_state.dart';

class _AuthFalso implements AuthRepository {
  _AuthFalso({this.falla = false, Usuario? inicial}) : _usuario = inicial;

  final bool falla;
  final StreamController<Usuario?> _controlador =
      StreamController<Usuario?>.broadcast();

  Usuario? _usuario;

  static const Usuario demo = Usuario(
    id: 'u1',
    correo: 'demo@uandina.edu.pe',
    nombre: 'Demo',
  );

  @override
  Stream<Usuario?> get cambiosDeSesion => _controlador.stream;

  @override
  Future<Usuario?> usuarioActual() async => _usuario;

  @override
  Future<Usuario> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    if (falla) {
      throw const AuthException('El correo o la contraseña no son correctos.');
    }
    _usuario = demo;
    _controlador.add(demo);
    return demo;
  }

  @override
  Future<Usuario> registrar({
    required String correo,
    required String contrasena,
  }) async {
    if (falla) {
      throw const AuthException('Ya existe una cuenta con ese correo.');
    }
    _usuario = demo;
    _controlador.add(demo);
    return demo;
  }

  @override
  Future<void> cerrarSesion() async {
    _usuario = null;
    _controlador.add(null);
  }
}

void main() {
  group('SesionBloc', () {
    blocTest<SesionBloc, SesionState>(
      'verifica una sesión existente',
      build: () => SesionBloc(_AuthFalso(inicial: _AuthFalso.demo)),
      act: (bloc) => bloc.add(const VerificarSesion()),
      expect: () => <Matcher>[
        isA<SesionVerificando>(),
        isA<SesionConUsuario>().having(
          (estado) => estado.usuario.correo,
          'correo',
          'demo@uandina.edu.pe',
        ),
      ],
    );

    blocTest<SesionBloc, SesionState>(
      'sin sesión previa pasa a SesionSinUsuario',
      build: () => SesionBloc(_AuthFalso()),
      act: (bloc) => bloc.add(const VerificarSesion()),
      expect: () => <Matcher>[
        isA<SesionVerificando>(),
        isA<SesionSinUsuario>(),
      ],
    );

    blocTest<SesionBloc, SesionState>(
      'inicia sesión y llega a ConUsuario por el stream',
      build: () => SesionBloc(_AuthFalso()),
      act: (bloc) => bloc.add(
        const IniciarSesion(
          correo: 'demo@uandina.edu.pe',
          contrasena: 'Salud2026*',
        ),
      ),
      wait: const Duration(milliseconds: 50),
      expect: () => <Matcher>[
        isA<SesionIniciando>(),
        isA<SesionConUsuario>(),
      ],
    );

    blocTest<SesionBloc, SesionState>(
      'informa credenciales incorrectas sin revelar cuál falló',
      build: () => SesionBloc(_AuthFalso(falla: true)),
      act: (bloc) => bloc.add(
        const IniciarSesion(
          correo: 'demo@uandina.edu.pe',
          contrasena: 'Salud2026*',
        ),
      ),
      expect: () => <Matcher>[
        isA<SesionIniciando>(),
        isA<SesionError>().having(
          (estado) => estado.mensaje,
          'mensaje',
          contains('correo o la contraseña'),
        ),
      ],
    );

    blocTest<SesionBloc, SesionState>(
      'registra una cuenta y llega a ConUsuario',
      build: () => SesionBloc(_AuthFalso()),
      act: (bloc) => bloc.add(
        const RegistrarUsuario(
          correo: 'nuevo@uandina.edu.pe',
          contrasena: 'Salud2026*',
        ),
      ),
      wait: const Duration(milliseconds: 50),
      expect: () => <Matcher>[
        isA<SesionRegistrando>(),
        isA<SesionConUsuario>(),
      ],
    );

    blocTest<SesionBloc, SesionState>(
      'cierra la sesión',
      build: () => SesionBloc(_AuthFalso(inicial: _AuthFalso.demo)),
      act: (bloc) => bloc.add(const CerrarSesion()),
      wait: const Duration(milliseconds: 50),
      expect: () => <Matcher>[isA<SesionSinUsuario>()],
    );
  });
}
