import 'package:flutter/material.dart';

// Colores y tamaños centralizados para toda la app.
// Ningún valor visual debe estar repetido a mano por el código.
class ColoresFicha {
  // Paleta para el tema claro
  static const Map<int, Color> _claro = {
    0: Color(0xFFCDC1B4), 2: Color(0xFFEEE4DA), 4: Color(0xFFEDE0C8),
    8: Color(0xFFF2B179), 16: Color(0xFFF59563), 32: Color(0xFFF67C5F),
    64: Color(0xFFF65E3B), 128: Color(0xFFEDCF72), 256: Color(0xFFEDCC61),
    512: Color(0xFFEDC850), 1024: Color(0xFFEDC53F), 2048: Color(0xFFEDC22E),
  };

  // Paleta para el tema oscuro
  static const Map<int, Color> _oscuro = {
    0: Color(0xFF3C3A32), 2: Color(0xFF4E4A42), 4: Color(0xFF655D4E),
    8: Color(0xFFB47F4A), 16: Color(0xFFB8653C), 32: Color(0xFFB35030),
    64: Color(0xFFB93A1C), 128: Color(0xFFB08E3E), 256: Color(0xFFB08C2A),
    512: Color(0xFFB0891A), 1024: Color(0xFFB0850A), 2048: Color(0xFFB08200),
  };

  // Devuelve el color de fondo de la ficha según su valor y el brillo actual
  static Color porValor(int valor, Brightness brillo) {
    final mapa = brillo == Brightness.dark ? _oscuro : _claro;
    return mapa[valor] ?? (brillo == Brightness.dark ? const Color(0xFF1A1A1A) : const Color(0xFF3C3A32));
  }

  // Devuelve el color del texto para que contraste con el fondo de la ficha
  static Color textoPorValor(int valor, Brightness brillo) {
    if (valor <= 4 && brillo == Brightness.light) return Colors.black87;
    if (valor == 0) return Colors.transparent;
    return Colors.white;
  }
}

class AppTheme {
  static const double espaciadoS = 8;
  static const double espaciadoM = 16;
  static const double espaciadoL = 24;
  static const double espaciadoXL = 32;
  static const double radioBorde = 12;
  static const double radioFicha = 8;

  // Tema claro
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF67C5F), brightness: Brightness.light),
    scaffoldBackgroundColor: const Color(0xFFFAF8EF),
    appBarTheme: const AppBarTheme(centerTitle: true, backgroundColor: Color(0xFFFAF8EF), foregroundColor: Colors.black87, elevation: 0),
  );

  // Tema oscuro
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB35030), brightness: Brightness.dark),
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    appBarTheme: const AppBarTheme(centerTitle: true, backgroundColor: Color(0xFF1A1A1A), foregroundColor: Colors.white, elevation: 0),
  );
}