import '../data/database_helper.dart';

/// Modelo de datos que representa una partida finalizada del juego (ej. 2048).
///
/// Contiene toda la información estadística de la sesión de juego y proporciona
/// métodos para serializar y deserializar los datos hacia/desde la base de datos SQLite.
class Partida {
  /// Identificador único autogenerado en la base de datos. Es nulo si aún no se ha guardado.
  final int? id;

  /// Nombre o identificador del jugador que realizó la partida.
  final String usuario;

  /// Puntuación total obtenida al finalizar la partida.
  final int puntuacion;

  /// Valor de la ficha más alta alcanzada durante la partida.
  final int fichaMaxima;

  /// Cantidad total de movimientos realizados por el jugador.
  final int movimientos;

  /// Tiempo total de juego expresado en segundos.
  final int duracionSegundos;

  /// Fecha y hora exacta en la que se registró o finalizó la partida.
  final DateTime fecha;

  /// Dimensión de la cuadrícula del tablero (ej. 4 para un tablero de 4x4).
  /// Añadido en la migración v1->v2.
  final int tamanoTablero;

  /// Constructor constante para instanciar un objeto [Partida].
  ///
  /// Por defecto, [tamanoTablero] se inicializa en `4` si no se especifica.
  const Partida({
    this.id,
    required this.usuario,
    required this.puntuacion,
    required this.fichaMaxima,
    required this.movimientos,
    required this.duracionSegundos,
    required this.fecha,
    this.tamanoTablero = 4,
  });

  /// Convierte la instancia actual de [Partida] en un [Map] clave-valor
  /// compatible con las columnas definidas en [DatabaseHelper] para su inserción en SQLite.
  Map<String, dynamic> toMap() => {
    // Solo incluye el ID si ya existe (útil para actualizaciones)
    if (id != null) DatabaseHelper.colPartidaId: id,
    DatabaseHelper.colPartidaUsuario: usuario,
    DatabaseHelper.colPartidaPuntuacion: puntuacion,
    DatabaseHelper.colPartidaFichaMaxima: fichaMaxima,
    DatabaseHelper.colPartidaMovimientos: movimientos,
    DatabaseHelper.colPartidaDuracion: duracionSegundos,
    // Convierte el objeto DateTime a formato estándar ISO-8601 (String)
    DatabaseHelper.colPartidaFecha: fecha.toIso8601String(),
    DatabaseHelper.colPartidaTamanoTablero: tamanoTablero,
  };

  /// Constructor de fábrica (*factory*) que reconstruye un objeto [Partida]
  /// a partir de un [Map] recuperado de una consulta en la base de datos SQLite.
  factory Partida.fromMap(Map<String, dynamic> m) => Partida(
    id: m[DatabaseHelper.colPartidaId] as int?,
    usuario: m[DatabaseHelper.colPartidaUsuario] as String,
    puntuacion: m[DatabaseHelper.colPartidaPuntuacion] as int,
    fichaMaxima: m[DatabaseHelper.colPartidaFichaMaxima] as int,
    movimientos: m[DatabaseHelper.colPartidaMovimientos] as int,
    duracionSegundos: m[DatabaseHelper.colPartidaDuracion] as int,
    // Parsea la cadena ISO-8601 almacenada de vuelta a un objeto DateTime
    fecha: DateTime.parse(m[DatabaseHelper.colPartidaFecha] as String),
    // Si el valor es nulo (registros anteriores a la migración), asume un tablero 4x4
    tamanoTablero: (m[DatabaseHelper.colPartidaTamanoTablero] as int?) ?? 4,
  );
}