import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_firebase_repository.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/auth_repositorio_memoria.dart';
import 'features/auth/presentation/bloc/sesion_bloc.dart';
import 'features/citas/data/citas_repositorio_memoria.dart';
import 'features/citas/data/citas_repository.dart';
import 'features/citas/data/firestore_citas_repository.dart';
import 'features/medicamentos/data/firestore_medicamentos_repository.dart';
import 'features/medicamentos/data/firestore_tomas_repository.dart';
import 'features/medicamentos/data/medicamentos_repositorio_memoria.dart';
import 'features/medicamentos/data/medicamentos_repository.dart';
import 'features/medicamentos/data/tomas_repositorio_memoria.dart';
import 'features/medicamentos/data/tomas_repository.dart';
import 'firebase_bootstrap.dart';
import 'router_refresh.dart';

String _uidActual() => FirebaseAuth.instance.currentUser?.uid ?? '';

/// Raíz de la aplicación.
///
/// Los repositorios son inyectables: en pruebas se usan los de memoria; en
/// producción, Firestore si Firebase está inicializado.
class AppSalud extends StatefulWidget {
  AppSalud({
    super.key,
    this.resultadoFirebase = ResultadoFirebase.noConfigurado,
    AuthRepository? authRepository,
    CitasRepository? citasRepository,
    MedicamentosRepository? medicamentosRepository,
    TomasRepository? tomasRepository,
  })  : _authRepository = authRepository ??
            (resultadoFirebase.inicializado
                ? AuthFirebaseRepository()
                : AuthRepositorioMemoria()),
        _citasRepository = citasRepository ??
            (resultadoFirebase.inicializado
                ? FirestoreCitasRepository(usuarioId: _uidActual)
                : CitasRepositorioMemoria.demo()),
        _medicamentosRepository = medicamentosRepository ??
            (resultadoFirebase.inicializado
                ? FirestoreMedicamentosRepository(usuarioId: _uidActual)
                : MedicamentosRepositorioMemoria.demo()),
        _tomasRepository = tomasRepository ??
            (resultadoFirebase.inicializado
                ? FirestoreTomasRepository(usuarioId: _uidActual)
                : TomasRepositorioMemoria.demo());

  final ResultadoFirebase resultadoFirebase;
  final AuthRepository _authRepository;
  final CitasRepository _citasRepository;
  final MedicamentosRepository _medicamentosRepository;
  final TomasRepository _tomasRepository;

  @override
  State<AppSalud> createState() => _AppSaludState();
}

class _AppSaludState extends State<AppSalud> {
  late final SesionBloc _sesion;
  late final RouterRefresh _refresh;
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _sesion = SesionBloc(widget._authRepository);
    _refresh = RouterRefresh(_sesion.stream);
    _router = AppRouter(
      sesion: _sesion,
      refresh: _refresh,
      modoDemostracion: !widget.resultadoFirebase.inicializado,
      resultadoFirebase: widget.resultadoFirebase,
      citas: widget._citasRepository,
      medicamentos: widget._medicamentosRepository,
      tomas: widget._tomasRepository,
    );
  }

  @override
  void dispose() {
    _router.router.dispose();
    _refresh.dispose();
    _sesion.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(
          value: widget._authRepository,
        ),
        RepositoryProvider<CitasRepository>.value(
          value: widget._citasRepository,
        ),
        RepositoryProvider<MedicamentosRepository>.value(
          value: widget._medicamentosRepository,
        ),
        RepositoryProvider<TomasRepository>.value(
          value: widget._tomasRepository,
        ),
      ],
      child: BlocProvider<SesionBloc>.value(
        value: _sesion,
        child: MaterialApp.router(
          title: 'Salud Digital',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          darkTheme: AppTheme.oscuro,
          highContrastTheme: AppTheme.altoContrasteClaro,
          highContrastDarkTheme: AppTheme.altoContrasteOscuro,
          themeMode: ThemeMode.system,
          routerConfig: _router.router,
          locale: const Locale('es', 'PE'),
          supportedLocales: const [Locale('es', 'PE')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}
