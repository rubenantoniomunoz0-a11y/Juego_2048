import '../data/database_helper.dart';

class Partida {
  final int? id;
  final String usuario;
  final int puntuacion;
  final int fichaMaxima;
  final int movimientos;
  final int duracionSegundos;
  final DateTime fecha;
  final int tamanoTablero;
  
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


  Map<String, dynamic> toMap() => {
    if (id != null) DatabaseHelper.colPartidaId: id,
    DatabaseHelper.colPartidaUsuario: usuario,
    DatabaseHelper.colPartidaPuntuacion: puntuacion,
    DatabaseHelper.colPartidaFichaMaxima: fichaMaxima,
    DatabaseHelper.colPartidaMovimientos: movimientos,
    DatabaseHelper.colPartidaDuracion: duracionSegundos,
    DatabaseHelper.colPartidaFecha: fecha.toIso8601String(),
    DatabaseHelper.colPartidaTamanoTablero: tamanoTablero,
  };

  factory Partida.fromMap(Map<String, dynamic> m) => Partida(
    id: m[DatabaseHelper.colPartidaId] as int?,
    usuario: m[DatabaseHelper.colPartidaUsuario] as String,
    puntuacion: m[DatabaseHelper.colPartidaPuntuacion] as int,
    fichaMaxima: m[DatabaseHelper.colPartidaFichaMaxima] as int,
    movimientos: m[DatabaseHelper.colPartidaMovimientos] as int,
    duracionSegundos: m[DatabaseHelper.colPartidaDuracion] as int,
    fecha: DateTime.parse(m[DatabaseHelper.colPartidaFecha] as String),
    tamanoTablero: (m[DatabaseHelper.colPartidaTamanoTablero] as int?) ?? 4,
  );
}