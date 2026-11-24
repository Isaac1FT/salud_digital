import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Página para rutas que no existen.
class PaginaError extends StatelessWidget {
  const PaginaError({super.key, required this.ubicacion});

  final String ubicacion;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Página no encontrada')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.explore_off_outlined,
                size: 64,
                color: tema.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'No encontramos esta página',
                textAlign: TextAlign.center,
                style: tema.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                ubicacion,
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
