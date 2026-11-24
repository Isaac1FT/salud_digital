# Salud Digital · Semana 2 (S4–S6)

Proyecto Flutter Android que continúa la base de las sesiones S1–S3 y añade
**Cloud Firestore**: modelo de datos, reglas de seguridad, CRUD en tiempo real y
tablero de adherencia con `fl_chart`.

> **Estado:** S1–S3 y semana 2 (S4–S6) implementadas. La semana 3 (recordatorios
> e IA), las pruebas de integración y el CI se incorporan en las sesiones S7–S11.

## 1. Qué incluye

- Autenticación con Firebase y rutas protegidas con GoRouter (S2–S3).
- **Modelo Firestore por propietario**:
  - `usuarios/{uid}/citas/{citaId}`
  - `usuarios/{uid}/medicamentos/{medicamentoId}`
  - `usuarios/{uid}/tomas/{tomaId}`
- **DTO y mapeadores** (`CitaDto`, `MedicamentoDto`, `TomaDto`) con `Timestamp`,
  `FieldValue.serverTimestamp()` y campos opcionales.
- **Repositorios** con contrato, implementación Firestore y respaldo en memoria.
- **CRUD en tiempo real** con `snapshots()`; los BLoC reciben la lista por stream.
- **Tablero**: próxima cita, medicamento pendiente, adherencia semanal y gráfica
  de barras con alternativa textual accesible.
- **Reglas de seguridad** en `firestore.rules`: propietario, validación y
  denegación por defecto.
- **57 pruebas** de dominio, DTO, BLoC, router, temas y accesibilidad.
- `flutter analyze` sin observaciones.

## 2. Requisitos y versiones

| Herramienta | Versión o condición |
|---|---|
| Flutter | 3.41.1 / Dart 3.11 |
| `go_router` | 17.5.0 (18.x exige Dart 3.12) |
| `cloud_firestore` | 7.1.0 (7.2 exige Dart 3.12) |
| `firebase_core` | 5.1.0 |
| `fl_chart` | 1.3.1 |
| Android | `minSdk 24`, permisos de Internet |

```bash
flutter pub get
flutter analyze
flutter test
```

## 3. Conectar Firestore

1. Configura Firebase y Authentication como en la guía de conexión de la S2.
2. Habilita **Cloud Firestore** en la consola (modo producción).
3. Despliega reglas e índices:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

4. Para desarrollo local:

```bash
firebase emulators:start --only auth,firestore
```

5. En la app, el repositorio de Firestore se elige automáticamente cuando
   `ResultadoFirebase.inicializado` es verdadero. Sin Firebase, se usan los
   repositorios en memoria con datos de demostración.

> **Offline:** Firestore mantiene una caché local y sincroniza al recuperar la
> red. La app muestra los datos cacheados; las operaciones pendientes se
> reconcilian cuando vuelve la conexión. No se guardan tokens ni contraseñas en
> la caché de la app.

## 4. Modelo de datos

```text
usuarios/{uid}
├── citas/{citaId}
│   ├── especialidad: string
│   ├── fechaHora: Timestamp
│   ├── nota: string?
│   ├── estado: 'programada' | 'completada'
│   ├── creadoEn: Timestamp
│   └── actualizadoEn: Timestamp
├── medicamentos/{medicamentoId}
│   ├── nombre: string
│   ├── dosis: string
│   ├── proximaToma: Timestamp
│   ├── frecuenciaHoras: 8 | 12 | 24
│   ├── activo: bool
│   ├── creadoEn: Timestamp
│   └── actualizadoEn: Timestamp
└── tomas/{tomaId}
    ├── medicamentoId: string
    ├── fecha: Timestamp
    ├── tomado: bool
    └── creadoEn: Timestamp
```

El `uid` de la ruta es la frontera de seguridad: no se consulta una colección
global ni se confía en un `propietarioId` enviado por el cliente.

## 5. Reglas de seguridad

`firestore.rules` aplica:

- Solo el propietario (`request.auth.uid == uid`) lee y escribe su subárbol.
- Validación de tipos, longitudes y estados en citas y medicamentos.
- Una toma solo se crea si el medicamento referenciado existe y es del mismo
  usuario.
- Denegación por defecto: no hay una regla `allow read, write: if true`.

Prueba las reglas en el emulador antes de desplegarlas. El proyecto no incluye
credenciales ni datos reales.

## 6. Estructura relevante

```text
lib/
├── app.dart                     # Repositorios Firestore/memoria + router
├── app_router.dart              # Rutas y creación de BLoC por sesión
├── home_shell.dart              # Tablero, citas, medicamentos, perfil
├── firebase_bootstrap.dart
├── features/
│   ├── citas/
│   │   ├── domain/cita.dart
│   │   ├── data/{cita_dto,citas_repository,firestore_citas_repository,citas_repositorio_memoria}.dart
│   │   └── presentation/…
│   ├── medicamentos/
│   │   ├── domain/{medicamento,toma_medicamento}.dart
│   │   ├── data/{medicamento_dto,toma_dto,…}.dart
│   │   └── presentation/…
│   └── tablero/
│       ├── domain/tablero.dart
│       └── presentation/{bloc, pages}
├── firestore.rules
├── firestore.indexes.json
└── firebase.json
```

### Flujo de datos

```text
Firestore snapshots() → Repositorio → BLoC (stream) → Estado → Widget
```

Las pantallas no llaman a Firestore. Las operaciones de escritura se piden al
BLoC; la lista llega por el stream del repositorio. La UI solo representa
estados: cargando, vacío, error o datos.

## 7. Tablero de adherencia

`ResumenTablero.calcular` combina citas, medicamentos y tomas:

- Próxima cita: la primera `programada` con fecha futura.
- Medicamento pendiente: el activo con `proximaToma` más cercana.
- Adherencia: para los últimos 7 días, una toma esperada por medicamento activo
  y día; se cuenta una toma registrada por medicamento y día.

La gráfica es una ayuda visual; el texto «X de Y tomas registradas» y el detalle
por día son la alternativa accesible. La gráfica está excluida de semántica y su
resumen se anuncia con `Semantics`.

## 8. Pruebas

| Archivo | Pruebas |
|---|---|
| `test/features/tablero/tablero_test.dart` | Dominio, DTO y BLoC (5) |
| `test/features/citas/citas_bloc_test.dart` | Carga, creación, actualización, eliminación y error (6) |
| `test/features/medicamentos/medicamentos_bloc_test.dart` | Carga, creación, actualización y error (5) |
| `test/features/citas/citas_repositorio_memoria_test.dart` | Contrato (6) |
| `test/router/app_router_test.dart` | Rutas y protección (5) |
| Resto de la base S1–S3 | Autenticación, temas, accesibilidad y widgets (30) |

**Resultado:** `flutter analyze` limpio y **57 pruebas en verde**.

## 9. Siguiente semana

Recordatorios locales, permisos, modo claro con IA, pruebas de integración y
pipeline de CI. El tablero y el CRUD quedan como base para la Guía 11.
