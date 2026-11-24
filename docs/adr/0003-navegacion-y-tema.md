# ADR 0003 — Navegación protegida y tema Material 3

- **Fecha:** 14/11/2026
- **Estado:** aceptada
- **Decisores:** equipo de proyecto, con revisión del docente de SIS048
- **Contexto:** Unidad III, sesión S3 y Guía 09

## Contexto

La S2 dejó la autenticación y el estado de sesión en `SesionBloc`. La app decidía
la pantalla dentro de `_Inicio`, con `Navigator` implícito. Para la Guía 09 se
necesitan rutas protegidas, cierre de sesión sin navegación manual, temas claro,
oscuro y alto contraste, splash de Android 12+ y accesibilidad verificable.

## Decisión

1. **GoRouter con configuración central.** `AppRouter` declara `/`, `/acceso` y
   las rutas protegidas dentro de un `ShellRoute`. La regla de acceso vive en un
   único `redirect`.
2. **`refreshListenable` como puente.** `RouterRefresh` escucha el stream de
   `SesionBloc` y notifica al router; el estado del bloque sigue siendo la fuente
   de verdad.
3. **Logout por estado.** El perfil agrega `CerrarSesion`; cuando el stream emite
   `null`, el router redirige a `/acceso`. No se usa `context.go` después del
   evento.
4. **Cuatro temas Material 3.** `ColorScheme.fromSeed` con
   `contrastLevel: 0.0` y `1.0`; `theme`, `darkTheme`, `highContrastTheme` y
   `highContrastDarkTheme`; `themeMode: ThemeMode.system`.
5. **Splash en dos capas.** `values-v31` y `values-night-v31` para Android 12+;
   la ruta `/` cubre la verificación de la sesión.
6. **Accesibilidad como criterio.** Texto base de 18 sp, objetivos de 48 × 48,
   `liveRegion` en errores, texto al 200 % y pruebas con las guías de Flutter.

## Alternativas consideradas

| Alternativa | Motivo para no elegirla |
|---|---|
| `Navigator.push` y comprobaciones por pantalla | Repite la regla y no soporta deep links. |
| `currentUser` + `addPostFrameCallback` | Consulta el SDK desde la UI y navega durante el ciclo de construcción. |
| `context.go('/login')` tras el logout | Compite con el cambio de estado; produce el error documentado en la clase 15. |
| Colores fijos por pantalla | Rompe el modo oscuro y el alto contraste. |
| Splash con `Timer` | Retrasa la app sin aportar información. |
| `go_router` 18.x | Exige Dart 3.12; el proyecto usa Dart 3.11. |

## Consecuencias

**Positivas**

- Una sola regla de acceso, probable con pruebas de widget.
- El logout no depende de la pantalla de perfil.
- El tema se cambia desde el sistema sin tocar cada widget.
- El splash nativo y el de verificación tienen responsabilidades distintas.

**Negativas y riesgos**

- `go_router` 17.5.0 se debe actualizar cuando el SDK suba a Dart 3.12.
- Un `redirect` mal escrito puede entrar en bucle; se corrige la regla, no el
  límite.
- El alto contraste no corrige colores fijos: la revisión de código es necesaria.
- El splash de Android 12+ no se pudo probar en un dispositivo en este entorno.

## Evidencia

- `flutter analyze` sin observaciones.
- **50 pruebas en verde**, incluidas redirección, logout, temas y texto al 200 %.
- Rutas protegidas verificadas con `AppRouter` y con la app completa.

## Revisión

Se revisa en la S4 al conectar Firestore: las rutas de datos deben seguir usando
el mismo `redirect` y no agregar guardas duplicadas.
