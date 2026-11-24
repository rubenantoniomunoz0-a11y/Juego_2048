import 'package:flutter/material.dart';

class ColoresFicha {
  // Paleta Claro: Colores vivos
  static const Map<int, Color> _claro = {
    0: Color(0xFFE0E0E0),      // Gris claro (hueco)
    2: Color(0xFFFFF59D),      // Amarillo pastel (Texto oscuro)
    4: Color(0xFFFFD54F),      // Amarillo vibrante (Texto oscuro)
    8: Color(0xFFFFB300),      // Naranja ámbar (Texto oscuro)
    16: Color(0xFFFF7043),     // Naranja coral (Texto blanco)
    32: Color(0xFFF4511E),     // Rojo anaranjado (Texto blanco)
    64: Color(0xFFE53935),     // Rojo brillante (Texto blanco)
    128: Color(0xFFD81B60),    // Rosa fuerte (Texto blanco)
    256: Color(0xFF8E24AA),    // Púrpura (Texto blanco)
    512: Color(0xFF5E35B1),    // Violeta (Texto blanco)
    1024: Color(0xFF3949AB),   // Azul índigo (Texto blanco)
    2048: Color(0xFF00ACC1),   // Cian eléctrico (Texto blanco)
  };

  // Paleta Oscuro: Colores vibrantes pero adaptados
  static const Map<int, Color> _oscuro = {
    0: Color(0xFF2C2C2C),      // Gris oscuro (hueco)
    2: Color(0xFFFBC02D),      // Amarillo oscuro (Texto oscuro)
    4: Color(0xFFF57F17),      // Ámbar (Texto blanco)
    8: Color(0xFFE65100),      // Naranja oscuro (Texto blanco)
    16: Color(0xFFD84315),     // Rojo oscuro (Texto blanco)
    32: Color(0xFFC62828),     // Rojo profundo (Texto blanco)
    64: Color(0xFFAD1457),     // Fucsia oscuro (Texto blanco)
    128: Color(0xFF6A1B9A),    // Morado oscuro (Texto blanco)
    256: Color(0xFF4527A0),    // Índigo oscuro (Texto blanco)
    512: Color(0xFF283593),    // Azul noche (Texto blanco)
    1024: Color(0xFF00838F),   // Cian oscuro (Texto blanco)
    2048: Color(0xFF00E5FF),   // Cian neón (Texto oscuro/negro para que contraste)
  };

  // Devuelve el color de fondo de la ficha
  static Color porValor(int valor, Brightness brillo) {
    final mapa = brillo == Brightness.dark ? _oscuro : _claro;
    return mapa[valor] ?? (brillo == Brightness.dark ? const Color(0xFF121212) : const Color(0xFF9E9E9E));
  }

  // Lógica de contraste: Decide si el texto es blanco o negro
  static Color textoPorValor(int valor, Brightness brillo) {
    if (valor == 0) return Colors.transparent;

    // Si es modo claro
    if (brillo == Brightness.light) {
      if (valor <= 8) return Colors.black87; // Texto oscuro para amarillos y naranjas claros
      return Colors.white; // Texto blanco para rojos, morados, azules...
    }
    // Si es modo oscuro
    else {
      if (valor == 2) return Colors.black87; // Texto oscuro en el amarillo oscuro
      if (valor == 2048) return Colors.black87; // Texto oscuro en el cian neón
      return Colors.white; // Texto blanco para el resto
    }
  }
}

class AppTheme {
  static const double espaciadoS = 8;
  static const double espaciadoM = 16;
  static const double espaciadoL = 24;
  static const double espaciadoXL = 32;
  static const double radioBorde = 12;
  static const double radioFicha = 8;

  // Tema Claro con Naranja Eléctrico
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF5722), // Naranja Eléctrico
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Color(0xFFF8F9FA),
        foregroundColor: Colors.black87,
        elevation: 0
    ),
  );

  // Tema Oscuro con Cian Eléctrico
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00BCD4), // Cian Eléctrico
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0
    ),
  );
}