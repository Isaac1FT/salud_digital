import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salud_digital/core/theme/app_theme.dart';
import 'package:salud_digital/features/auth/data/auth_repositorio_memoria.dart';
import 'package:salud_digital/features/auth/presentation/bloc/sesion_bloc.dart';
import 'package:salud_digital/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('el acceso soporta texto al 200 % sin desbordes',
      (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      BlocProvider<SesionBloc>(
        create: (_) => SesionBloc(AuthRepositorioMemoria()),
        child: MaterialApp(
          theme: AppTheme.claro,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
            ),
            child: child!,
          ),
          home: const LoginPage(modoDemostracion: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
