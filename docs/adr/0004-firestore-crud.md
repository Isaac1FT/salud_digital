# ADR 0004 — Firestore, reglas y CRUD en tiempo real

- **Fecha:** 19/11/2026
- **Estado:** aceptada
- **Decisores:** equipo de proyecto, con revisión del docente de SIS048
- **Contexto:** Semana 2, sesiones S4–S6 y Guía 10

## Contexto

La aplicación ya autentica y protege rutas. La semana 2 incorpora datos en la
nube: modelo, reglas de seguridad, CRUD, listas en tiempo real y un tablero de
adherencia. El proyecto debe seguir funcionando sin Firebase para demostración y
pruebas.

## Decisión

1. **Subcolecciones por propietario.** `usuarios/{uid}/citas`,
   `usuarios/{uid}/medicamentos` y `usuarios/{uid}/tomas`. El `uid` de la ruta es
   la frontera de seguridad; no se consulta una colección global.
2. **DTO y mapeadores en la capa de datos.** `CitaDto`, `MedicamentoDto` y
   `TomaDto` traducen `Timestamp` y `FieldValue.serverTimestamp()`. El dominio no
   importa `cloud_firestore`.
3. **Contrato de repositorio con stream.** `watch()` emite la lista ordenada;
   `listar()` queda para pruebas y primeras lecturas. La UI no llama a Firestore.
4. **BLoC con el stream como fuente de verdad.** Los eventos de creación,
   actualización y eliminación solo piden el cambio; la lista llega por un evento
   interno desde el stream.
5. **Reglas de propietario y validación.** `firestore.rules` exige
   `request.auth.uid == uid`, valida campos y refuerza que una toma pertenezca a
   un medicamento existente del mismo usuario. Denegación por defecto.
6. **Tablero derivado.** `ResumenTablero.calcular` combina las tres fuentes; no
   se guarda un documento de tablero que pueda quedar desincronizado.
7. **Respaldo en memoria.** Sin Firebase, la app usa repositorios con datos de
   demostración; las pruebas no necesitan emulador.

## Alternativas consideradas

| Alternativa | Motivo para no elegirla |
|---|---|
| Colecciones globales con `propietarioId` | La consulta y la regla dependen de un campo que el cliente podría intentar falsificar. |
| Llamar a Firestore desde el widget | Rompe la separación de capas y no se puede probar sin red. |
| Guardar el tablero como documento | Duplica la verdad y se desincroniza con citas/tomas. |
| Solo `listar()` con recarga manual | No cumple el requisito de tiempo real ni el modo offline. |
| Reglas `allow read, write: if request.auth != null` | Cualquier usuario autenticado leería datos ajenos. |

## Consecuencias

**Positivas**

- Aislamiento por usuario verificable en las reglas.
- Las listas se actualizan solas al cambiar Firestore.
- El dominio y las pruebas quedan independientes de Firebase.
- El tablero es una vista derivada, no un dato duplicado.

**Negativas y riesgos**

- `cloud_firestore` 7.2.0 exige Dart 3.12; el proyecto usa 7.1.0.
- Las reglas no se pudieron ejecutar en el emulador en este entorno.
- La adherencia usa una toma esperada por medicamento activo y día; si se
  requiere varias dosis diarias, se debe extender el cálculo.
- Los índices compuestos deben agregarse si se filtran colecciones por estado.

## Evidencia

- `flutter analyze` sin observaciones.
- **57 pruebas en verde**, incluidas DTO, BLoC en tiempo real y tablero.
- Reglas e índices versionados en el proyecto.

## Revisión

Se revisa en la S7 al agregar recordatorios: la próxima toma y las notificaciones
deben usar el mismo modelo de medicamento.
