import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/sesion_bloc.dart';
import '../bloc/sesion_state.dart';

/// Pantalla de verificación mientras se restaura la sesión.
///
/// Es la ruta `/`. No es un splash decorativo: su función es evitar que se
/// muestre el acceso a una persona que ya tenía sesión.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: Center(
        child: BlocBuilder<SesionBloc, SesionState>(
          builder: (context, estado) {
            final error = estado is SesionError;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.health_and_safety,
                  size: 64,
                  color: tema.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                if (error)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      estado.mensaje,
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyLarge,
                    ),
                  )
                else ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Preparando tu agenda…',
                    style: tema.textTheme.bodyLarge,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
