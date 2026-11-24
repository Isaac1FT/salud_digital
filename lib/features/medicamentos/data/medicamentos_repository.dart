import '../domain/medicamento.dart';

/// Contrato del repositorio de medicamentos.
abstract interface class MedicamentosRepository {
  Stream<List<Medicamento>> watch();

  Future<List<Medicamento>> listar();

  Future<void> crear(Medicamento medicamento);

  Future<void> actualizar(Medicamento medicamento);

  Future<void> eliminar(String id);
}
