import 'package:flutter/material.dart';

import '../../../../core/utils/fechas.dart';
import '../../domain/cita.dart';

/// Tarjeta de una cita en la lista.
class CitaCard extends StatelessWidget {
  const CitaCard({
    super.key,
    required this.cita,
    required this.onEditar,
    required this.onEliminar,
  });

  final Cita cita;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final tieneNota = (cita.nota ?? '').trim().isNotEmpty;
    final completada = cita.estado == EstadoCita.completada;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        isThreeLine: tieneNota,
        leading: CircleAvatar(
          backgroundColor: completada
              ? tema.colorScheme.secondaryContainer
              : tema.colorScheme.primaryContainer,
          child: Icon(
            completada ? Icons.event_available : Icons.event,
            color: completada
                ? tema.colorScheme.onSecondaryContainer
                : tema.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(cita.especialidad, style: tema.textTheme.titleMedium),
        subtitle: Text(
          tieneNota
              ? '${formatearFechaHora(cita.fechaHora)}\n${cita.nota}'
              : formatearFechaHora(cita.fechaHora),
          style: tema.textTheme.bodyMedium,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar cita',
              onPressed: onEditar,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Eliminar cita',
              onPressed: onEliminar,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
