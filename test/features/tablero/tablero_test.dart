import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salud_digital/features/citas/data/cita_dto.dart';
import 'package:salud_digital/features/citas/data/citas_repositorio_memoria.dart';
import 'package:salud_digital/features/citas/domain/cita.dart';
import 'package:salud_digital/features/medicamentos/data/medicamento_dto.dart';
import 'package:salud_digital/features/medicamentos/data/medicamentos_repositorio_memoria.dart';
import 'package:salud_digital/features/medicamentos/data/tomas_repositorio_memoria.dart';
import 'package:salud_digital/features/medicamentos/domain/medicamento.dart';
import 'package:salud_digital/features/medicamentos/domain/toma_medicamento.dart';
import 'package:salud_digital/features/tablero/domain/tablero.dart';
import 'package:salud_digital/features/tablero/presentation/bloc/tablero_bloc.dart';

void main() {
  group('ResumenTablero', () {
    test('calcula la próxima cita y el medicamento pendiente', () {
      final ahora = DateTime(2026, 11, 21, 10);
      final resumen = ResumenTablero.calcular(
        citas: <Cita>[
          Cita(
            id: 'vieja',
            especialidad: 'Oftalmología',
            fechaHora: ahora.subtract(const Duration(days: 1)),
          ),
          Cita(
            id: 'proxima',
            especialidad: 'Cardiología',
            fechaHora: ahora.add(const Duration(days: 2)),
          ),
        ],
        medicamentos: <Medicamento>[
          Medicamento(
            id: 'med',
            nombre: 'Enalapril',
            dosis: '10 mg',
            proximaToma: ahora.subtract(const Duration(hours: 1)),
          ),
        ],
        tomas: const <TomaMedicamento>[],
        ahora: ahora,
      );

      expect(resumen.proximaCita?.id, 'proxima');
      expect(resumen.proximoMedicamento?.id, 'med');
      expect(resumen.adherencia.esperadas, 7);
      expect(resumen.adherencia.registradas, 0);
    });

    test('cuenta una toma por medicamento y por día', () {
      final ahora = DateTime(2026, 11, 21, 10);
      final inicio = DateTime(2026, 11, 21);
      final resumen = ResumenTablero.calcular(
        citas: const <Cita>[],
        medicamentos: <Medicamento>[
          Medicamento(
            id: 'med-1',
            nombre: 'Enalapril',
            dosis: '10 mg',
            proximaToma: ahora,
          ),
          Medicamento(
            id: 'med-2',
            nombre: 'Metformina',
            dosis: '850 mg',
            proximaToma: ahora,
          ),
        ],
        tomas: <TomaMedicamento>[
          TomaMedicamento(
            id: 't1',
            medicamentoId: 'med-1',
            fecha: inicio.add(const Duration(hours: 8)),
          ),
          TomaMedicamento(
            id: 't2',
            medicamentoId: 'med-2',
            fecha: inicio.add(const Duration(hours: 9)),
          ),
          TomaMedicamento(
            id: 't3',
            medicamentoId: 'med-1',
            fecha: inicio.add(const Duration(hours: 20)),
          ),
        ],
        ahora: ahora,
      );

      expect(resumen.adherencia.esperadas, 14);
      expect(resumen.adherencia.registradas, 2);
      expect(resumen.adherencia.porcentajeEntero, 14);
    });
  });

  test('el tablero elige un medicamento sin toma registrada hoy', () {
    final ahora = DateTime(2026, 11, 21, 10);
    final resumen = ResumenTablero.calcular(
      citas: const <Cita>[],
      medicamentos: <Medicamento>[
        Medicamento(
          id: 'primero',
          nombre: 'Enalapril',
          dosis: '10 mg',
          proximaToma: ahora.subtract(const Duration(hours: 2)),
        ),
        Medicamento(
          id: 'segundo',
          nombre: 'Metformina',
          dosis: '850 mg',
          proximaToma: ahora.add(const Duration(hours: 2)),
        ),
      ],
      tomas: <TomaMedicamento>[
        TomaMedicamento(
          id: 'toma-primero',
          medicamentoId: 'primero',
          fecha: ahora,
        ),
      ],
      ahora: ahora,
    );

    expect(resumen.proximoMedicamento?.id, 'segundo');
  });

  group('DTO', () {
    test('la cita se convierte a un mapa con Timestamp y estado', () {
      final cita = Cita(
        id: 'c1',
        especialidad: 'Medicina general',
        fechaHora: DateTime(2026, 11, 25, 9),
        nota: 'Llevar análisis',
      );

      final mapa = CitaDto.aCrear(cita);

      expect(mapa['especialidad'], 'Medicina general');
      expect(mapa['fechaHora'], isA<Timestamp>());
      expect(mapa['estado'], 'programada');
      expect(mapa['nota'], 'Llevar análisis');
      expect(mapa['creadoEn'], isA<FieldValue>());
    });

    test('el medicamento se convierte a un mapa con frecuencia', () {
      final medicamento = Medicamento(
        id: 'm1',
        nombre: 'Enalapril',
        dosis: '10 mg',
        proximaToma: DateTime(2026, 11, 25, 8),
        frecuenciaHoras: 12,
      );

      final mapa = MedicamentoDto.aCrear(medicamento);

      expect(mapa['nombre'], 'Enalapril');
      expect(mapa['proximaToma'], isA<Timestamp>());
      expect(mapa['frecuenciaHoras'], 12);
      expect(mapa['activo'], isTrue);
    });
  });

  group('TableroBloc', () {
    blocTest<TableroBloc, TableroState>(
      'emite el resumen cuando las tres fuentes están listas',
      build: () => TableroBloc(
        citas: CitasRepositorioMemoria.demo(),
        medicamentos: MedicamentosRepositorioMemoria.demo(),
        tomas: TomasRepositorioMemoria.demo(),
      ),
      wait: const Duration(milliseconds: 50),
      expect: () => <Matcher>[
        isA<TableroCargado>().having(
          (estado) => estado.resumen.medicamentosActivos,
          'medicamentos activos',
          2,
        ),
      ],
    );
  });
}
