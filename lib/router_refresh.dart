import 'dart:async';

import 'package:flutter/foundation.dart';

/// Puente entre el stream del bloque de sesión y el router.
///
/// GoRouter reevalúa `redirect` cuando este [Listenable] notifica. Sin este
/// puente, el cierre de sesión cambiaría el estado pero la ruta protegida
/// seguiría visible.
class RouterRefresh extends ChangeNotifier {
  RouterRefresh(Stream<Object?> stream) {
    _suscripcion = stream.listen(
      (_) => notifyListeners(),
      onError: (Object _) => notifyListeners(),
    );
  }

  late final StreamSubscription<Object?> _suscripcion;

  @override
  void dispose() {
    _suscripcion.cancel();
    super.dispose();
  }
}
