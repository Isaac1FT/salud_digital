import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validadores.dart';
import '../bloc/sesion_bloc.dart';
import '../bloc/sesion_event.dart';
import '../bloc/sesion_state.dart';

/// Pantalla de acceso y registro.
///
/// La interfaz solo valida, agrega eventos y muestra estados. No conoce
/// Firebase ni el repositorio.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.modoDemostracion = false});

  /// Muestra las credenciales de demostración cuando Firebase no está
  /// configurado y se usa el repositorio en memoria.
  final bool modoDemostracion;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _contrasena = TextEditingController();
  final TextEditingController _confirmacion = TextEditingController();

  bool _esRegistro = false;
  bool _verContrasena = false;
  bool _mostrarError = false;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  void _enviar() {
    setState(() => _mostrarError = true);
    if (!(_formulario.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();

    final correo = _correo.text.trim();
    final contrasena = _contrasena.text;
    final bloc = context.read<SesionBloc>();

    if (_esRegistro) {
      bloc.add(
        RegistrarUsuario(correo: correo, contrasena: contrasena),
      );
    } else {
      bloc.add(
        IniciarSesion(correo: correo, contrasena: contrasena),
      );
    }
  }

  void _cambiarModo() {
    setState(() {
      _esRegistro = !_esRegistro;
      _confirmacion.clear();
      _mostrarError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estado = context.watch<SesionBloc>().state;
    final ocupado =
        estado is SesionIniciando || estado is SesionRegistrando;
    final error = _mostrarError && estado is SesionError
        ? estado.mensaje
        : null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formulario,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      size: 64,
                      color: tema.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Salud Digital',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _esRegistro
                          ? 'Crea tu cuenta para organizar tus citas y medicamentos'
                          : 'Agenda de citas y medicamentos para el adulto mayor',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _correo,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              hintText: 'nombre@correo.com',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: Validadores.correo,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _contrasena,
                            obscureText: !_verContrasena,
                            textInputAction: _esRegistro
                                ? TextInputAction.next
                                : TextInputAction.done,
                            autofillHints: _esRegistro
                                ? const [AutofillHints.newPassword]
                                : const [AutofillHints.password],
                            onFieldSubmitted: _esRegistro
                                ? null
                                : (_) => _enviar(),
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              helperText: _esRegistro
                                  ? 'Al menos 8 caracteres'
                                  : null,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _verContrasena
                                    ? 'Ocultar contraseña'
                                    : 'Mostrar contraseña',
                                onPressed: () => setState(
                                  () => _verContrasena = !_verContrasena,
                                ),
                                icon: Icon(
                                  _verContrasena
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: Validadores.contrasena,
                          ),
                          if (_esRegistro) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmacion,
                              obscureText: !_verContrasena,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              onFieldSubmitted: (_) => _enviar(),
                              decoration: const InputDecoration(
                                labelText: 'Confirmar contraseña',
                                prefixIcon: Icon(Icons.lock_reset),
                              ),
                              validator: (valor) =>
                                  Validadores.confirmacion(
                                valor,
                                _contrasena.text,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 20),
                      Semantics(
                        liveRegion: true,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: tema.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: tema.colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  error,
                                  style: tema.textTheme.bodyMedium?.copyWith(
                                    color: tema.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: ocupado ? null : _enviar,
                      icon: ocupado
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _esRegistro ? Icons.person_add : Icons.login,
                            ),
                      label: Text(
                        ocupado
                            ? 'Procesando…'
                            : (_esRegistro ? 'Crear cuenta' : 'Ingresar'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: ocupado ? null : _cambiarModo,
                      child: Text(
                        _esRegistro
                            ? 'Ya tengo una cuenta'
                            : 'Crear una cuenta nueva',
                      ),
                    ),
                    if (widget.modoDemostracion) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: tema.colorScheme.surfaceContainerHighest,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modo demostración',
                                style: tema.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Firebase no está configurado. Puedes probar '
                                'el flujo con cualquier correo válido y una '
                                'contraseña de 8 caracteres o más.',
                                style: tema.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
