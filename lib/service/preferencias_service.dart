import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio que encapsula el acceso a `SharedPreferences` para persistir
/// configuraciones y datos ligeros de la aplicación.
///
/// Requisito B.2.1: Encapsula SharedPreferences y define las claves como constantes.
class PreferenciasService {
  /// Clave para almacenar el modo de tema seleccionado (`light`, `dark` o `system`).
  static const String _kModoTema = 'modo_tema';

  /// Clave para almacenar el nombre del último jugador activo.
  static const String _kUltimoJugador = 'ultimo_jugador';

  /// Clave para almacenar la mejor puntuación registrada.
  static const String _kMejorPuntuacion = 'mejor_puntuacion';

  /// Instancia interna de [SharedPreferences] utilizada para leer y escribir datos.
  final SharedPreferences _prefs;

  /// Constructor privado para forzar la creación mediante [crear].
  PreferenciasService._(this._prefs);

  /// Inicializa de forma asíncrona [SharedPreferences] y devuelve
  /// una instancia lista para usar de [PreferenciasService].
  static Future<PreferenciasService> crear() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferenciasService._(prefs);
  }

  /// Requisito B.2.2: Guarda el [ThemeMode] elegido guardando su nombre como cadena de texto.
  Future<void> guardarModoTema(ThemeMode modo) async {
    await _prefs.setString(_kModoTema, modo.name);
  }

  /// Requisito B.2.2: Recupera y convierte el modo de tema guardado a [ThemeMode].
  ///
  /// Si no hay ningún valor guardado o no coincide, devuelve [ThemeMode.system] por defecto.
  ThemeMode leerModoTema() {
    final s = _prefs.getString(_kModoTema);
    if (s == 'light') return ThemeMode.light;
    if (s == 'dark') return ThemeMode.dark;
    return ThemeMode.system; // Valor por defecto
  }

  /// Ampliación B.3: Guarda el nombre del último jugador que utilizó la aplicación.
  Future<void> guardarUltimoJugador(String usuario) async {
    await _prefs.setString(_kUltimoJugador, usuario);
  }

  /// Ampliación B.3: Obtiene el nombre del último jugador guardado, o `null` si aún no existe.
  String? leerUltimoJugador() => _prefs.getString(_kUltimoJugador);

  /// Ampliación B.3: Guarda la mejor puntuación alcanzada en [SharedPreferences].
  Future<void> guardarMejorPuntuacion(int puntos) async {
    await _prefs.setInt(_kMejorPuntuacion, puntos);
  }

  /// Ampliación B.3: Devuelve la mejor puntuación guardada, o `0` si no hay registro previo.
  int leerMejorPuntuacion() => _prefs.getInt(_kMejorPuntuacion) ?? 0;
}