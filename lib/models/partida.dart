import '../data/database_helper.dart';

/// Modelo de datos que representa una partida finalizada en el historial.
/// Se utiliza para registrar estadísticas y mostrar el ranking de puntuaciones.
class Partida {
  // Identificador único autogenerado en la base de datos (nulo antes de guardarse)
  final int? id;
  
  // Nombre del usuario que jugó la partida
  final String usuario;
  
  // Puntuación total obtenida al finalizar
  final int puntuacion;
  
  // Valor de la ficha más alta alcanzada en el tablero (ej. 512, 1024, 2048...)
  final int fichaMaxima;
  
  // Número total de movimientos realizados durante la partida
  final int movimientos;
  
  // Tiempo total jugado expresado en segundos
  final int duracionSegundos;
  
  // Fecha y hora exactas en las que finalizó la partida
  final DateTime fecha;
  
  // Dimensión del tablero utilizado (por defecto 4x4, añadido en la versión 2 de la BD)
  final int tamanoTablero;
  
  /// Constructor constante de la clase [Partida].
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

  /// Convierte la instancia de [Partida] en un [Map] clave-valor listo para
  /// ser insertado o actualizado en la tabla `partidas` de SQLite.
  Map<String, dynamic> toMap() => {
    // Solo incluimos el ID si ya existe, permitiendo que SQLite lo autogenere si es nulo
    if (id != null) DatabaseHelper.colPartidaId: id,
    DatabaseHelper.colPartidaUsuario: usuario,
    DatabaseHelper.colPartidaPuntuacion: puntuacion,
    DatabaseHelper.colPartidaFichaMaxima: fichaMaxima,
    DatabaseHelper.colPartidaMovimientos: movimientos,
    DatabaseHelper.colPartidaDuracion: duracionSegundos,
    // SQLite no tiene tipo DateTime nativo, por lo que se serializa en formato estándar ISO-8601
    DatabaseHelper.colPartidaFecha: fecha.toIso8601String(),
    DatabaseHelper.colPartidaTamanoTablero: tamanoTablero,
  };

  /// Constructor factory que reconstruye un objeto [Partida] a partir de una fila
  /// (mapa de columnas) recuperada de una consulta en SQLite.
  factory Partida.fromMap(Map<String, dynamic> m) => Partida(
    id: m[DatabaseHelper.colPartidaId] as int?,
    usuario: m[DatabaseHelper.colPartidaUsuario] as String,
    puntuacion: m[DatabaseHelper.colPartidaPuntuacion] as int,
    fichaMaxima: m[DatabaseHelper.colPartidaFichaMaxima] as int,
    movimientos: m[DatabaseHelper.colPartidaMovimientos] as int,
    duracionSegundos: m[DatabaseHelper.colPartidaDuracion] as int,
    // Parsea la cadena ISO-8601 de vuelta a un objeto DateTime de Dart
    fecha: DateTime.parse(m[DatabaseHelper.colPartidaFecha] as String),
    // Si el campo viniera nulo por compatibilidad con registros antiguos, asume 4 por defecto
    tamanoTablero: (m[DatabaseHelper.colPartidaTamanoTablero] as int?) ?? 4,
  );
}
