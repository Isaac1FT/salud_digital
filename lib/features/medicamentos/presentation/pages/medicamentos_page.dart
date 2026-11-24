import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/estado_error.dart';
import '../../../../core/widgets/estado_vacio.dart';
import '../../data/tomas_repository.dart';
import '../../domain/medicamento.dart';
import '../../domain/toma_medicamento.dart';
import '../bloc/medicamentos_bloc.dart';
import '../bloc/medicamentos_event.dart';
import '../bloc/medicamentos_state.dart';
import '../widgets/formulario_medicamento.dart';

/// Pantalla de medicamentos programados.
class MedicamentosPage extends StatelessWidget {
  const MedicamentosPage({super.key});

  Future<void> _abrirFormulario(
    BuildContext context, {
    Medicamento? medicamento,
  }) async {
    final resultado = await showModalBottomSheet<Medicamento>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => FormularioMedicamento(inicial: medicamento),
    );
    if (resultado == null || !context.mounted) return;

    final bloc = context.read<MedicamentosBloc>();
    if (medicamento == null) {
      bloc.add(CrearMedicamento(resultado));
    } else {
      bloc.add(ActualizarMedicamento(resultado));
    }
  }

  Future<void> _registrarToma(
    BuildContext context,
    Medicamento medicamento,
  ) async {
    try {
      await context.read<TomasRepository>().registrar(
            TomaMedicamento(
              id: '',
              medicamentoId: medicamento.id,
              fecha: DateTime.now(),
            ),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Toma de ${medicamento.nombre} registrada.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo registrar la toma.')),
        );
      }
    }
  }

  Future<bool> _confirmarEliminacion(
    BuildContext context,
    Medicamento medicamento,
  ) async {
    final respuesta = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar medicamento'),
        content: Text(
          '¿Eliminar ${medicamento.nombre}? '
          'También se dejará de mostrar en el tablero.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return respuesta ?? false;
  }

  Future<void> _eliminar(
    BuildContext context,
    Medicamento medicamento,
  ) async {
    final confirmado = await _confirmarEliminacion(context, medicamento);
    if (confirmado && context.mounted) {
      context
          .read<MedicamentosBloc>()
          .add(EliminarMedicamento(medicamento.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis medicamentos'),
        actions: [
          IconButton(
            tooltip: 'Actualizar medicamentos',
            onPressed: () => context
                .read<MedicamentosBloc>()
                .add(const CargarMedicamentos()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<MedicamentosBloc, MedicamentosState>(
        builder: (context, estado) {
          if (estado is MedicamentosInicial || estado is MedicamentosCargando) {
            return Center(
              child: Semantics(
                label: 'Cargando medicamentos',
                child: const CircularProgressIndicator(),
              ),
            );
          }

          if (estado is MedicamentosError) {
            return EstadoError(
              mensaje: estado.mensaje,
              onReintentar: () => context
                  .read<MedicamentosBloc>()
                  .add(const CargarMedicamentos()),
            );
          }

          if (estado is MedicamentosCargados) {
            if (estado.medicamentos.isEmpty) {
              return EstadoVacio(
                icono: Icons.medication_liquid,
                titulo: 'Aún no hay medicamentos',
                mensaje: 'Registra los medicamentos y sus horarios para '
                    'organizar las tomas del día.',
                accion: FilledButton.icon(
                  onPressed: () => _abrirFormulario(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar medicamento'),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 96),
              itemCount: estado.medicamentos.length,
              itemBuilder: (context, indice) {
                final medicamento = estado.medicamentos[indice];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: medicamento.activo
                          ? tema.colorScheme.secondaryContainer
                          : tema.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.medication,
                        color: medicamento.activo
                            ? tema.colorScheme.onSecondaryContainer
                            : tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      medicamento.nombre,
                      style: tema.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      '${medicamento.dosis} · ${medicamento.horaTexto}\n'
                      'Cada ${medicamento.frecuenciaHoras} h · '
                      '${medicamento.activo ? 'Activo' : 'Inactivo'}',
                      style: tema.textTheme.bodyMedium,
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      tooltip: 'Acciones del medicamento',
                      onSelected: (accion) {
                        switch (accion) {
                          case 'editar':
                            _abrirFormulario(
                              context,
                              medicamento: medicamento,
                            );
                          case 'toma':
                            _registrarToma(context, medicamento);
                          case 'eliminar':
                            _eliminar(context, medicamento);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'editar',
                          child: Text('Editar'),
                        ),
                        PopupMenuItem(
                          value: 'toma',
                          child: Text('Registrar toma'),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Text('Eliminar'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Registrar medicamento',
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),
    );
  }
}
