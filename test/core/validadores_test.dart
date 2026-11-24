import 'package:flutter_test/flutter_test.dart';
import 'package:salud_digital/core/utils/validadores.dart';

void main() {
  group('Validadores.correo', () {
    test('acepta un correo válido', () {
      expect(Validadores.correo('paciente01@ejemplo.pe'), isNull);
    });

    test('rechaza vacío, sin arroba y sin dominio', () {
      expect(Validadores.correo(''), isNotNull);
      expect(Validadores.correo('paciente01'), isNotNull);
      expect(Validadores.correo('paciente01@'), isNotNull);
      expect(Validadores.correo('paciente01@ejemplo'), isNotNull);
    });

    test('rechaza espacios y puntos al borde del dominio', () {
      expect(Validadores.correo('paciente 01@ejemplo.pe'), isNotNull);
      expect(Validadores.correo('paciente01@.pe'), isNotNull);
      expect(Validadores.correo('paciente01@ejemplo.'), isNotNull);
    });
  });

  group('Validadores.contrasena', () {
    test('exige al menos 8 caracteres', () {
      expect(Validadores.contrasena('1234567'), isNotNull);
      expect(Validadores.contrasena('12345678'), isNull);
    });
  });

  group('Validadores.confirmacion', () {
    test('detecta contraseñas distintas y vacías', () {
      expect(Validadores.confirmacion('Salud2026*', 'Salud2026*'), isNull);
      expect(Validadores.confirmacion('Salud2026*', 'Otra2026*'), isNotNull);
      expect(Validadores.confirmacion('', 'Salud2026*'), isNotNull);
    });
  });
}
