# Checkpoint S4–S6 · Guía 10

**Semana 2 · 17 al 21 de noviembre de 2026**
**Equipo:** ______________________  **Integrantes:** ______________________

## 1. Lista de verificación

| N.º | Criterio | Estado | Evidencia |
|---|---|---|---|
| 01 | El modelo usa `usuarios/{uid}/{citas,medicamentos,tomas}`. | ☐ | Diagrama / consola |
| 02 | Las reglas exigen propietario y validan campos. | ☐ | `firestore.rules` |
| 03 | Las reglas se probaron en el emulador. | ☐ | Captura / log |
| 04 | El repositorio de citas escucha `snapshots()`. | ☐ | Código |
| 05 | El repositorio de medicamentos escucha `snapshots()`. | ☐ | Código |
| 06 | Crear, editar y eliminar citas funciona. | ☐ | Demo |
| 07 | Crear, editar y eliminar medicamentos funciona. | ☐ | Demo |
| 08 | Registrar una toma actualiza la adherencia. | ☐ | Demo |
| 09 | El tablero muestra próxima cita y medicamento pendiente. | ☐ | Captura |
| 10 | La gráfica tiene alternativa textual y semántica. | ☐ | Captura / código |
| 11 | Los estados vacío, carga y error están cubiertos. | ☐ | Captura |
| 12 | `flutter analyze` está limpio. | ☐ | Salida |
| 13 | `flutter test` pasa las 57 pruebas. | ☐ | Salida |
| 14 | README, ADR y modelo están documentados. | ☐ | Repositorio |

## 2. Datos del entorno

| Dato | Valor |
|---|---|
| Proyecto de Firebase | |
| Colección raíz | `usuarios` |
| Emulador usado | Sí / No |
| Versión de Flutter | |
| Hash del commit | |
| Enlace al tablero | |

## 3. Modelo y reglas

| Elemento | Decisión | Observaciones |
|---|---|---|
| Citas | | |
| Medicamentos | | |
| Tomas | | |
| Índices | | |

## 4. Pruebas de reglas

| Caso | Resultado esperado | Resultado obtenido |
|---|---|---|
| Leer citas de otro uid | Denegado | |
| Crear cita sin sesión | Denegado | |
| Crear cita con especialidad vacía | Denegado | |
| Crear toma de medicamento ajeno | Denegado | |
| Crear cita propia válida | Permitido | |

## 5. Bloqueos y plan de recuperación

| Bloqueo | Impacto | Acción acordada | Responsable | Fecha |
|---|---|---|---|---|
| | | | | |

## 6. Revisión entre pares

**Equipo revisor:** ______________________

| Hallazgo | Severidad | Acción acordada |
|---|---|---|
| | | |
| | | |

**Firma del revisor:** ______________________
