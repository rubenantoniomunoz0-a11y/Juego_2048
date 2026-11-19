import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasService {
  static const String _kModoTema = 'modo_tema';
  static const String _kUltimoJugador = 'ultimo_jugador';
  static const String _kMejorPuntuacion = 'mejor_puntuacion';

  final SharedPreferences _prefs;
  PreferenciasService._(this._prefs);

  static Future<PreferenciasService> crear() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferenciasService._(prefs);
  }

  Future<void> guardarModoTema(ThemeMode modo) async => await _prefs.setString(_kModoTema, modo.name);

  ThemeMode leerModoTema() {
    final s = _prefs.getString(_kModoTema);
    if (s == 'light') return ThemeMode.light;
    if (s == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> guardarUltimoJugador(String usuario) async => await _prefs.setString(_kUltimoJugador, usuario);
  String? leerUltimoJugador() => _prefs.getString(_kUltimoJugador);

  Future<void> guardarMejorPuntuacion(int puntos) async => await _prefs.setInt(_kMejorPuntuacion, puntos);
  int leerMejorPuntuacion() => _prefs.getInt(_kMejorPuntuacion) ?? 0;
}