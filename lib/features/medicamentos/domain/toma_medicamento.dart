/// Registro de una toma de medicamento.
///
/// Permite calcular la adherencia semanal sin modificar el documento del
/// medicamento. Vive en `usuarios/{uid}/tomas`.
class TomaMedicamento {
  const TomaMedicamento({
    required this.id,
    required this.medicamentoId,
    required this.fecha,
    this.tomado = true,
  });

  final String id;
  final String medicamentoId;
  final DateTime fecha;
  final bool tomado;
}
