import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/fechas.dart';
import '../../../medicamentos/data/tomas_repository.dart';
import '../../../medicamentos/domain/toma_medicamento.dart';
import '../../domain/tablero.dart';
import '../bloc/tablero_bloc.dart';

/// Tablero con próxima cita, medicamento pendiente y adherencia semanal.
class TableroPage extends StatelessWidget {
  const TableroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi tablero')),
      body: BlocBuilder<TableroBloc, TableroState>(
        builder: (context, estado) {
          if (estado is TableroInicial || estado is TableroCargando) {
            return Center(
              child: Semantics(
                label: 'Cargando el tablero',
                child: const CircularProgressIndicator(),
              ),
            );
          }
          if (estado is TableroError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  estado.mensaje,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          if (estado is TableroCargado) {
            return _Contenido(resumen: estado.resumen);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _Contenido extends StatefulWidget {
  const _Contenido({required this.resumen});

  final ResumenTablero resumen;

  @override
  State<_Contenido> createState() => _ContenidoState();
}

class _ContenidoState extends State<_Contenido> {
  bool _guardando = false;
  // Evita registrar dos veces mientras llega la actualización del repositorio.
  String? _medicamentoRegistrado;

  Future<void> _registrarToma() async {
    final medicamento = widget.resumen.proximoMedicamento;
    if (_guardando ||
        medicamento == null ||
        _medicamentoRegistrado == medicamento.id) {
      return;
    }

    setState(() => _guardando = true);
    try {
      await context.read<TomasRepository>().registrar(
        TomaMedicamento(
          id: '',
          medicamentoId: medicamento.id,
          fecha: DateTime.now(),
        ),
      );
      if (mounted) {
        setState(() => _medicamentoRegistrado = medicamento.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Toma de ${medicamento.nombre} registrada.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo registrar la toma.')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resumen = widget.resumen;
    final registrada = _medicamentoRegistrado == resumen.proximoMedicamento?.id;
    final tema = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _Tarjeta(
          icono: Icons.event_available,
          titulo: 'Próxima cita',
          detalle: resumen.proximaCita == null
              ? 'No hay citas programadas.'
              : '${resumen.proximaCita!.especialidad}\n'
                    '${formatearFechaHora(resumen.proximaCita!.fechaHora)}',
        ),
        const SizedBox(height: 8),
        _Tarjeta(
          icono: Icons.medication,
          titulo: 'Medicamento pendiente',
          detalle: resumen.proximoMedicamento == null
              ? 'No hay medicamentos pendientes.'
              : '${resumen.proximoMedicamento!.nombre} · '
                    '${resumen.proximoMedicamento!.dosis}\n'
                    'Próxima toma: ${resumen.proximoMedicamento!.horaTexto}',
        ),
        if (resumen.proximoMedicamento != null) ...[
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _guardando || registrada ? null : _registrarToma,
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              registrada ? 'Toma registrada hoy' : 'Registrar toma de pastilla',
            ),
          ),
        ],
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.insights, color: tema.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Adherencia semanal',
                      style: tema.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${resumen.adherencia.registradas} de '
                  '${resumen.adherencia.esperadas} tomas registradas '
                  '(${resumen.adherencia.porcentajeEntero} %).',
                  style: tema.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: _descripcionGrafica(resumen.adherencia),
                  child: ExcludeSemantics(
                    child: SizedBox(
                      height: 220,
                      child: _GraficaAdherencia(dias: resumen.adherencia.dias),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ListaAdherencia(dias: resumen.adherencia.dias),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _descripcionGrafica(ResumenAdherencia adherencia) {
  final porcentajes = adherencia.dias.map(
    (dia) =>
        '${formatearFechaCorta(dia.dia)}: '
        '${(dia.porcentaje * 100).round()} por ciento',
  );
  return 'Gráfica de adherencia de los últimos siete días. '
      'Total: ${adherencia.porcentajeEntero} por ciento. '
      '${porcentajes.join('. ')}.';
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({
    required this.icono,
    required this.titulo,
    required this.detalle,
  });

  final IconData icono;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      color: tema.colorScheme.primaryContainer,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: tema.colorScheme.primaryContainer,
          child: Icon(icono, color: tema.colorScheme.onPrimaryContainer),
        ),
        title: Text(
          titulo,
          style: tema.textTheme.titleMedium?.copyWith(
            color: tema.colorScheme.onPrimaryContainer,
          ),
        ),
        subtitle: Text(
          detalle,
          style: tema.textTheme.bodyMedium?.copyWith(
            color: tema.colorScheme.onPrimaryContainer,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _GraficaAdherencia extends StatelessWidget {
  const _GraficaAdherencia({required this.dias});

  final List<AdherenciaDia> dias;

  static const _iniciales = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return BarChart(
      BarChartData(
        maxY: 100,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: false),
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: 50,
              getTitlesWidget: (valor, meta) =>
                  Text('${valor.toInt()}%', style: tema.textTheme.bodySmall),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (valor, meta) {
                final indice = valor.toInt();
                if (indice < 0 || indice >= dias.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _iniciales[dias[indice].dia.weekday - 1],
                    style: tema.textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < dias.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: dias[i].porcentaje * 100,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                  color: tema.colorScheme.primary,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ListaAdherencia extends StatelessWidget {
  const _ListaAdherencia({required this.dias});

  final List<AdherenciaDia> dias;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detalle por día', style: tema.textTheme.titleMedium),
        const SizedBox(height: 4),
        for (final dia in dias)
          Text(
            '${formatearFechaCorta(dia.dia)}: '
            '${dia.registradas}/${dia.esperadas} '
            '(${(dia.porcentaje * 100).round()} %)',
            style: tema.textTheme.bodyMedium,
          ),
      ],
    );
  }
}
