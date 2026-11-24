import '../domain/cita.dart';

/// Contrato del repositorio de citas.
///
/// La implementación en memoria se usa para demostración y pruebas; la de
/// Firestore es la de producción. El bloque solo conoce este contrato.
abstract interface class CitasRepository {
  /// Emite la lista ordenada cada vez que cambia en la fuente de datos.
  Stream<List<Cita>> watch();

  /// Lectura puntual, útil para pruebas y para el primer render.
  Future<List<Cita>> listar();

  Future<void> crear(Cita cita);

  Future<void> actualizar(Cita cita);

  Future<void> eliminar(String id);
}
