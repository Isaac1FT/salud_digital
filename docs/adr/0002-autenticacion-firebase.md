# ADR 0002 — Autenticación con Firebase y estado de sesión

- **Fecha:** 12/11/2026
- **Estado:** aceptada
- **Decisores:** equipo de proyecto, con revisión del docente de SIS048
- **Contexto:** Unidad III, sesión S2

## Contexto

La S1 dejó un contrato `AuthRepository`, una implementación en memoria y un
`SesionBloc` que emitía estados de forma explícita. La S2 necesita autenticación
real con Firebase, registro, cierre de sesión y restauración de la sesión al abrir
la app, manteniendo la interfaz libre de dependencias de Firebase.

## Decisión

1. **Firebase Authentication con correo y contraseña** como proveedor único de la
   unidad. El registro y el acceso usan `createUserWithEmailAndPassword` y
   `signInWithEmailAndPassword`; el cierre usa `signOut`.
2. **El stream es la fuente de verdad.** `AuthFirebaseRepository` expone
   `authStateChanges()` como `Stream<Usuario?>`; `SesionBloc` lo escucha y traduce
   cada cambio a un estado mediante un evento interno. Los manejadores de login y
   registro no emiten `ConUsuario` directamente.
3. **La contraseña no se guarda.** Permanece en el `TextEditingController` del
   formulario y se descarta. No se incluye en estados, logs, repositorios ni
   capturas.
4. **Errores traducidos en la capa de datos.** `AuthFirebaseRepository` captura
   `FirebaseAuthException`, usa `mensajeDeErrorAutenticacion` y lanza
   `AuthException` con un mensaje para la persona usuaria. La UI no conoce códigos
   de Firebase.
5. **Formulario accesible y sin lógica de negocio.** Valida con `Validadores`,
   agrega eventos y muestra el error en línea con `Semantics(liveRegion: true)`.
6. **Respaldo en memoria.** Si Firebase no está configurado, la app usa
   `AuthRepositorioMemoria` para poder demostrarse sin red.

## Alternativas consideradas

| Alternativa | Motivo para no elegirla |
|---|---|
| Llamar a `FirebaseAuth` desde el widget | Rompe la separación de capas y no se puede probar sin Firebase. |
| Guardar correo y contraseña en el estado | Expone la contraseña en logs y estados; es innecesario. |
| Emitir `ConUsuario` desde el manejador y también desde el stream | Dos fuentes de verdad y reconstrucciones duplicadas. |
| Usar `userChanges()` en lugar de `authStateChanges()` | La unidad no edita el perfil todavía; `authStateChanges` es suficiente. |
| Diferir la autenticación a la S3 | La Guía 09 exige login antes de proteger rutas. |

## Consecuencias

**Positivas**

- La sesión persiste entre reinicios sin código adicional.
- El bloque se prueba con un repositorio falso y un `StreamController`.
- La interfaz no importa `firebase_auth` ni conoce sus códigos.
- El cambio de proveedor no obliga a reescribir la pantalla.

**Negativas y riesgos**

- Dependencia de Firebase y de la cuenta institucional.
- La protección de enumeración devuelve `invalid-credential`; hay que manejar
  también los códigos anteriores.
- El stream debe emitir el estado inicial; si una implementación no lo hace, la app
  queda en «verificando». El contrato lo exige y la implementación en memoria lo
  cumple.

## Evidencia

- `flutter analyze` sin observaciones. La suite actual tiene 50 pruebas en verde.
- Registro e inicio de sesión verificados en el emulador (Checkpoint S2).
- Revisión de código: sin contraseñas en estados ni logs.

## Revisión

Se revisa en la S3 al conectar GoRouter: la redirección debe escuchar el estado de
sesión, no duplicar la lógica del bloque.
