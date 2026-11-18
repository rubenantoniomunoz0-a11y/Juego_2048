import 'dart:convert';
import '../data/database_helper.dart';

/// Modelo que representa la partida en curso (solo puede haber una).
/// Métodos toMap() y fromMap().
class PartidaGuardada {
  final int id; // Siempre será 1
  final List<int> tablero; // Lista de 16 enteros (0 = vacío)
  final int puntuacion;
  final int movimientos;
  final int segundosTranscurridos;

  const PartidaGuardada({
    this.id = 1,
    required this.tablero,
    required this.puntuacion,
    required this.movimientos,
    required this.segundosTranscurridos,
  });

  /// Convierte el objeto a un Map para SQLite.
  /// El tablero (List<int>) se convierte a formato JSON String.
  Map<String, dynamic> toMap() => {
    DatabaseHelper.colGuardadaId: id,
    DatabaseHelper.colGuardadaTablero: jsonEncode(tablero),
    DatabaseHelper.colGuardadaPuntuacion: puntuacion,
    DatabaseHelper.colGuardadaMovimientos: movimientos,
    DatabaseHelper.colGuardadaSegundos: segundosTranscurridos,
  };

  /// Crea un objeto PartidaGuardada a partir de un Map de SQLite.
  factory PartidaGuardada.fromMap(Map<String, dynamic> m) {
    final raw = m[DatabaseHelper.colGuardadaTablero] as String;
    final lista = (jsonDecode(raw) as List).cast<int>(); // Deserializa el JSON

    return PartidaGuardada(
      id: m[DatabaseHelper.colGuardadaId] as int,
      tablero: lista,
      puntuacion: m[DatabaseHelper.colGuardadaPuntuacion] as int,
      movimientos: m[DatabaseHelper.colGuardadaMovimientos] as int,
      segundosTranscurridos: m[DatabaseHelper.colGuardadaSegundos] as int,
    );
  }
}