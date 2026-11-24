import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/widgets/aviso_configuracion.dart';
import 'firebase_bootstrap.dart';

/// Barra inferior compartida por las rutas protegidas.
class HomeShell extends StatelessWidget {
  const HomeShell({
    super.key,
    required this.ubicacion,
    required this.child,
    required this.resultadoFirebase,
  });

  final String ubicacion;
  final Widget child;
  final ResultadoFirebase resultadoFirebase;

  static const _rutas = [
    '/tablero',
    '/citas',
    '/medicamentos',
    '/perfil',
  ];

  int get _indice {
    final indice = _rutas.indexOf(ubicacion);
    return indice < 0 ? 0 : indice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (!resultadoFirebase.inicializado)
            AvisoConfiguracion(
              mensaje: resultadoFirebase.mensaje,
              detalle: resultadoFirebase.detalle,
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (indice) => context.go(_rutas[indice]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Tablero',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Citas',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Medicamentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
