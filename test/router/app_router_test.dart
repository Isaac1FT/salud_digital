import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salud_digital/app_router.dart';
import 'package:salud_digital/core/theme/app_theme.dart';
import 'package:salud_digital/features/auth/data/auth_repositorio_memoria.dart';
import 'package:salud_digital/features/auth/presentation/bloc/sesion_bloc.dart';
import 'package:salud_digital/features/citas/data/citas_repositorio_memoria.dart';
import 'package:salud_digital/features/medicamentos/data/medicamentos_repositorio_memoria.dart';
import 'package:salud_digital/features/medicamentos/data/tomas_repositorio_memoria.dart';
import 'package:salud_digital/firebase_bootstrap.dart';
import 'package:salud_digital/router_refresh.dart';

Future<void> _asentar(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump(const Duration(milliseconds: 350));
}

void main() {
  late SesionBloc sesion;
  late RouterRefresh refresh;
  late AppRouter appRouter;

  void crear({bool conSesion = false}) {
    sesion = SesionBloc(
      AuthRepositorioMemoria(conSesionDemo: conSesion),
    );
    refresh = RouterRefresh(sesion.stream);
    appRouter = AppRouter(
      sesion: sesion,
      refresh: refresh,
      modoDemostracion: true,
      resultadoFirebase: ResultadoFirebase.noConfigurado,
      citas: CitasRepositorioMemoria.demo(),
      medicamentos: MedicamentosRepositorioMemoria.demo(),
      tomas: TomasRepositorioMemoria.demo(),
    );
  }

  Future<void> abrir(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<SesionBloc>.value(
        value: sesion,
        child: MaterialApp.router(
          theme: AppTheme.claro,
          routerConfig: appRouter.router,
        ),
      ),
    );
    await _asentar(tester);
  }

  tearDown(() {
    appRouter.router.dispose();
    refresh.dispose();
    sesion.close();
  });

  testWidgets('sin sesión, la app muestra el acceso', (tester) async {
    crear();
    await abrir(tester);

    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('Mis citas'), findsNothing);
  });

  testWidgets('una ruta protegida sin sesión redirige al acceso',
      (tester) async {
    crear();
    await abrir(tester);

    appRouter.router.go('/perfil');
    await _asentar(tester);

    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('Mi perfil'), findsNothing);
  });

  testWidgets('con sesión, la app abre en la agenda', (tester) async {
    crear(conSesion: true);
    await abrir(tester);

    expect(find.text('Mi tablero'), findsOneWidget);
    expect(find.text('Ingresar'), findsNothing);
  });

  testWidgets('con sesión, se puede navegar al perfil', (tester) async {
    crear(conSesion: true);
    await abrir(tester);

    appRouter.router.go('/perfil');
    await _asentar(tester);

    expect(find.text('Mi perfil'), findsOneWidget);
  });

  testWidgets('una ruta inexistente muestra el error', (tester) async {
    crear(conSesion: true);
    await abrir(tester);

    appRouter.router.go('/no-existe');
    await _asentar(tester);

    expect(find.text('Página no encontrada'), findsOneWidget);
  });
}
