import 'package:flutter/material.dart';

import '../../../../core/utils/fechas.dart';
import '../../domain/medicamento.dart';

/// Formulario para crear o editar un medicamento.
class FormularioMedicamento extends StatefulWidget {
  const FormularioMedicamento({super.key, this.inicial});

  final Medicamento? inicial;

  @override
  State<FormularioMedicamento> createState() =>
      _FormularioMedicamentoState();
}

class _FormularioMedicamentoState extends State<FormularioMedicamento> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _dosis = TextEditingController();
  final TextEditingController _fechaTexto = TextEditingController();
  final TextEditingController _horaTexto = TextEditingController();

  DateTime? _fecha;
  TimeOfDay? _hora;
  int _frecuencia = 24;

  @override
  void initState() {
    super.initState();
    final inicial = widget.inicial;
    if (inicial != null) {
      _nombre.text = inicial.nombre;
      _dosis.text = inicial.dosis;
      _fecha = inicial.proximaToma;
      _hora = TimeOfDay.fromDateTime(inicial.proximaToma);
      _frecuencia = inicial.frecuenciaHoras;
      _fechaTexto.text = formatearFechaCorta(inicial.proximaToma);
      _horaTexto.text = formatearHora(
        inicial.proximaToma.hour,
        inicial.proximaToma.minute,
      );
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _dosis.dispose();
    _fechaTexto.dispose();
    _horaTexto.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final seleccion = await showDatePicker(
      context: context,
      initialDate: _fecha ?? ahora,
      firstDate: DateTime(2020),
      lastDate: DateTime(ahora.year + 2),
      helpText: 'Próxima toma',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (seleccion != null) {
      setState(() {
        _fecha = seleccion;
        _fechaTexto.text = formatearFechaCorta(seleccion);
      });
    }
  }

  Future<void> _elegirHora() async {
    final seleccion = await showTimePicker(
      context: context,
      initialTime: _hora ?? const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Hora de la toma',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (seleccion != null) {
      setState(() {
        _hora = seleccion;
        _horaTexto.text = formatearHora(seleccion.hour, seleccion.minute);
      });
    }
  }

  void _guardar() {
    if (!(_formulario.currentState?.validate() ?? false)) {
      return;
    }
    final fecha = _fecha;
    final hora = _hora;
    if (fecha == null || hora == null) {
      return;
    }
    final proximaToma = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora.hour,
      hora.minute,
    );
    final inicial = widget.inicial;
    final medicamento = inicial == null
        ? Medicamento(
            id: '',
            nombre: _nombre.text.trim(),
            dosis: _dosis.text.trim(),
            proximaToma: proximaToma,
            frecuenciaHoras: _frecuencia,
          )
        : inicial.copyWith(
            nombre: _nombre.text.trim(),
            dosis: _dosis.text.trim(),
            proximaToma: proximaToma,
            frecuenciaHoras: _frecuencia,
          );
    Navigator.of(context).pop(medicamento);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.inicial == null
                          ? 'Nuevo medicamento'
                          : 'Editar medicamento',
                      style: tema.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombre,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Medicamento',
                  hintText: 'Enalapril',
                  prefixIcon: Icon(Icons.medication_outlined),
                ),
                validator: (valor) {
                  if ((valor ?? '').trim().isEmpty) {
                    return 'Escribe el nombre del medicamento.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosis,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Dosis',
                  hintText: '10 mg',
                  prefixIcon: Icon(Icons.straighten),
                ),
                validator: (valor) {
                  if ((valor ?? '').trim().isEmpty) {
                    return 'Escribe la dosis indicada.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fechaTexto,
                readOnly: true,
                onTap: _elegirFecha,
                decoration: const InputDecoration(
                  labelText: 'Próxima toma (fecha)',
                  hintText: 'Selecciona una fecha',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                validator: (_) =>
                    _fecha == null ? 'Selecciona la fecha de la toma.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _horaTexto,
                readOnly: true,
                onTap: _elegirHora,
                decoration: const InputDecoration(
                  labelText: 'Próxima toma (hora)',
                  hintText: 'Selecciona una hora',
                  prefixIcon: Icon(Icons.schedule),
                ),
                validator: (_) =>
                    _hora == null ? 'Selecciona la hora de la toma.' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _frecuencia,
                decoration: const InputDecoration(
                  labelText: 'Frecuencia',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: const [
                  DropdownMenuItem(value: 8, child: Text('Cada 8 horas')),
                  DropdownMenuItem(value: 12, child: Text('Cada 12 horas')),
                  DropdownMenuItem(value: 24, child: Text('Cada 24 horas')),
                ],
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() => _frecuencia = valor);
                  }
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  widget.inicial == null
                      ? 'Guardar medicamento'
                      : 'Guardar cambios',
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
