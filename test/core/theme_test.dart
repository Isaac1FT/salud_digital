import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salud_digital/core/theme/app_theme.dart';
import 'package:salud_digital/features/auth/data/auth_repositorio_memoria.dart';
import 'package:salud_digital/features/auth/presentation/bloc/sesion_bloc.dart';
import 'package:salud_digital/features/auth/presentation/pages/login_page.dart';

void main() {
  test('los cuatro temas usan el brillo esperado', () {
    expect(AppTheme.claro.brightness, Brightness.light);
    expect(AppTheme.altoContrasteClaro.brightness, Brightness.light);
    expect(AppTheme.oscuro.brightness, Brightness.dark);
    expect(AppTheme.altoContrasteOscuro.brightness, Brightness.dark);
  });

  test('el alto contraste produce un esquema distinto', () {
    expect(
      AppTheme.altoContrasteClaro.colorScheme.primary,
      isNot(AppTheme.claro.colorScheme.primary),
    );
    expect(
      AppTheme.altoContrasteOscuro.colorScheme.primary,
      isNot(AppTheme.oscuro.colorScheme.primary),
    );
  });

  testWidgets('el acceso cumple contraste con el tema de alto contraste',
      (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      BlocProvider<SesionBloc>(
        create: (_) => SesionBloc(AuthRepositorioMemoria()),
        child: MaterialApp(
          theme: AppTheme.altoContrasteClaro,
          home: const LoginPage(modoDemostracion: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
