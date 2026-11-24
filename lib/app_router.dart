import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/pages/pagina_error.dart';
import 'features/auth/presentation/bloc/sesion_bloc.dart';
import 'features/auth/presentation/bloc/sesion_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/citas/data/citas_repository.dart';
import 'features/citas/presentation/bloc/citas_bloc.dart';
import 'features/citas/presentation/bloc/citas_event.dart';
import 'features/citas/presentation/pages/citas_page.dart';
import 'features/medicamentos/data/medicamentos_repository.dart';
import 'features/medicamentos/data/tomas_repository.dart';
import 'features/medicamentos/presentation/bloc/medicamentos_bloc.dart';
import 'features/medicamentos/presentation/bloc/medicamentos_event.dart';
import 'features/medicamentos/presentation/pages/medicamentos_page.dart';
import 'features/perfil/presentation/pages/perfil_page.dart';
import 'features/tablero/presentation/bloc/tablero_bloc.dart';
import 'features/tablero/presentation/pages/tablero_page.dart';
import 'firebase_bootstrap.dart';
import 'home_shell.dart';

/// Rutas y regla de acceso.
///
/// Las rutas protegidas se envuelven en un [ShellRoute] que crea los bloques de
/// citas, medicamentos y tablero. Así no se consulta Firestore antes de que
/// exista una sesión.
class AppRouter {
  AppRouter({
    required this.sesion,
    required this.refresh,
    required this.modoDemostracion,
    required this.resultadoFirebase,
    required this.citas,
    required this.medicamentos,
    required this.tomas,
  });

  final SesionBloc sesion;
  final Listenable refresh;
  final bool modoDemostracion;
  final ResultadoFirebase resultadoFirebase;
  final CitasRepository citas;
  final MedicamentosRepository medicamentos;
  final TomasRepository tomas;

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: _redirigir,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: '/acceso',
        builder: (_, _) => LoginPage(
          modoDemostracion: modoDemostracion,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MultiBlocProvider(
          providers: [
            BlocProvider<CitasBloc>(
              create: (_) =>
                  CitasBloc(citas)..add(const CargarCitas()),
            ),
            BlocProvider<MedicamentosBloc>(
              create: (_) => MedicamentosBloc(medicamentos)
                ..add(const CargarMedicamentos()),
            ),
            BlocProvider<TableroBloc>(
              create: (_) => TableroBloc(
                citas: citas,
                medicamentos: medicamentos,
                tomas: tomas,
              ),
            ),
          ],
          child: HomeShell(
            ubicacion: state.matchedLocation,
            resultadoFirebase: resultadoFirebase,
            child: child,
          ),
        ),
        routes: [
          GoRoute(
            path: '/tablero',
            builder: (_, _) => const TableroPage(),
          ),
          GoRoute(
            path: '/citas',
            builder: (_, _) => const CitasPage(),
          ),
          GoRoute(
            path: '/medicamentos',
            builder: (_, _) => const MedicamentosPage(),
          ),
          GoRoute(
            path: '/perfil',
            builder: (_, _) => PerfilPage(
              resultadoFirebase: resultadoFirebase,
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => PaginaError(
      ubicacion: state.uri.toString(),
    ),
  );

  String? _redirigir(BuildContext context, GoRouterState state) {
    final ubicacion = state.matchedLocation;
    final estado = sesion.state;

    if (estado is SesionVerificando) {
      return ubicacion == '/' ? null : '/';
    }

    final autenticado = estado is SesionConUsuario;
    if (!autenticado) {
      return ubicacion == '/acceso' ? null : '/acceso';
    }

    if (ubicacion == '/' || ubicacion == '/acceso') {
      return '/tablero';
    }

    return null;
  }
}
