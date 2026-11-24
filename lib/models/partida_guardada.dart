import 'dart:convert';
import '../data/database_helper.dart';

/// Modelo de datos que representa el estado de la partida en curso guardada.
/// En la base de datos solo se almacena un único registro activo a la vez.
class PartidaGuardada {
  // Identificador fijo del registro (siempre será 1 para sobrescribir la misma fila)
  final int id;
  
  // Lista unidimensional de 16 enteros que representa las celdas del tablero (0 = vacía)
  final List<int> tablero;
  
  // Puntuación acumulada hasta el momento en que se guardó la partida
  final int puntuacion;
  
  // Cantidad de movimientos válidos realizados hasta el momento del guardado
  final int movimientos;
  
  // Tiempo de juego acumulado (en segundos) para reanudar el cronómetro
  final int segundosTranscurridos;

  /// Constructor constante de [PartidaGuardada].
  /// Asigna `1` por defecto al [id] para mantener el patrón de registro único.
  const PartidaGuardada({
    this.id = 1,
    required this.tablero,
    required this.puntuacion,
    required this.movimientos,
    required this.segundosTranscurridos,
  });

  /// Serializa la instancia actual a un [Map] compatible con SQLite.
  /// Como SQLite no soporta listas de forma nativa, el [tablero] se codifica
  /// como una cadena de texto en formato JSON mediante `jsonEncode`.
  Map<String, dynamic> toMap() => {
    DatabaseHelper.colGuardadaId: id,
    DatabaseHelper.colGuardadaTablero: jsonEncode(tablero),
    DatabaseHelper.colGuardadaPuntuacion: puntuacion,
    DatabaseHelper.colGuardadaMovimientos: movimientos,
    DatabaseHelper.colGuardadaSegundos: segundosTranscurridos,
  };

  /// Constructor factory que reconstruye una instancia de [PartidaGuardada]
  /// a partir de una fila obtenida de una consulta en SQLite.
  factory PartidaGuardada.fromMap(Map<String, dynamic> m) {
    // Extraemos la cadena JSON del tablero y la decodificamos de nuevo a List<int>
    final raw = m[DatabaseHelper.colGuardadaTablero] as String;
    final lista = (jsonDecode(raw) as List).cast<int>();

    return PartidaGuardada(
      id: m[DatabaseHelper.colGuardadaId] as int,
      tablero: lista,
      puntuacion: m[DatabaseHelper.colGuardadaPuntuacion] as int,
      movimientos: m[DatabaseHelper.colGuardadaMovimientos] as int,
      segundosTranscurridos: m[DatabaseHelper.colGuardadaSegundos] as int,
    );
  }
}
