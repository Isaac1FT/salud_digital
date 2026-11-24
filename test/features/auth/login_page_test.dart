import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salud_digital/app.dart';
import 'package:salud_digital/features/auth/data/auth_repositorio_memoria.dart';
import 'package:salud_digital/features/citas/data/citas_repositorio_memoria.dart';
import 'package:salud_digital/features/medicamentos/data/medicamentos_repositorio_memoria.dart';

Future<void> _abrirAcceso(WidgetTester tester) async {
  await tester.pumpWidget(
    AppSalud(
      authRepository: AuthRepositorioMemoria(),
      citasRepository: CitasRepositorioMemoria(),
      medicamentosRepository: MedicamentosRepositorioMemoria(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el acceso exige correo y contraseña', (tester) async {
    await _abrirAcceso(tester);

    final boton = find.widgetWithText(FilledButton, 'Ingresar');
    await tester.ensureVisible(boton);
    await tester.pumpAndSettle();
    await tester.tap(boton);
    await tester.pump();

    expect(find.text('Escribe tu correo electrónico.'), findsOneWidget);
    expect(find.text('Escribe una contraseña.'), findsOneWidget);
  });

  testWidgets('cambia a registro y pide confirmación', (tester) async {
    await _abrirAcceso(tester);

    final cambiar = find.text('Crear una cuenta nueva');
    await tester.ensureVisible(cambiar);
    await tester.tap(cambiar);
    await tester.pumpAndSettle();

    expect(find.text('Confirmar contraseña'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  testWidgets('inicia sesión con el repositorio en memoria', (tester) async {
    await _abrirAcceso(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'demo@uandina.edu.pe',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Salud2026*',
    );

    final boton = find.widgetWithText(FilledButton, 'Ingresar');
    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pumpAndSettle();

    expect(find.text('Mi tablero'), findsOneWidget);
  });

  testWidgets('los controles del acceso tienen etiqueta', (tester) async {
    final handle = tester.ensureSemantics();

    await _abrirAcceso(tester);

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
