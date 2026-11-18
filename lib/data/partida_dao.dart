import 'package:sqflite/sqflite.dart';
import '../models/partida.dart';
import 'database_helper.dart';

/// DAO que encapsula todas las operaciones SQL relacionadas con las partidas.
/// Ninguna pantalla debe contener consultas SQL.
class PartidaDao {
  final DatabaseHelper _helper = DatabaseHelper();

  // ───────────── CRUD BÁSICO ─────────────

  /// Inserta una partida terminada en el historial.
  Future<int> insertar(Partida p) async {
    final db = await _helper.database;
    try {
      return await db.insert(DatabaseHelper.tablaPartidas, p.toMap());
    } on DatabaseException catch (e) {
      throw Exception('No se pudo insertar la partida: $e');
    }
  }

  /// Consulta el historial completo ordenado por fecha descendente.
  Future<List<Partida>> historial() async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tablaPartidas,
      orderBy: '${DatabaseHelper.colPartidaFecha} DESC',
    );
    return rows.map(Partida.fromMap).toList();
  }

  /// Consulta el detalle de una partida por su id.
  Future<Partida?> porId(int id) async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tablaPartidas,
      where: '${DatabaseHelper.colPartidaId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Partida.fromMap(rows.first);
  }

  /// Elimina una partida concreta del historial.
  Future<int> eliminar(int id) async {
    final db = await _helper.database;
    return db.delete(
      DatabaseHelper.tablaPartidas,
      where: '${DatabaseHelper.colPartidaId} = ?',
      whereArgs: [id],
    );
  }

  /// Elimina todo el historial de partidas.
  Future<void> eliminarTodo() async {
    final db = await _helper.database;
    await db.delete(DatabaseHelper.tablaPartidas);
  }

  // ───────────── CONSULTAS CON FILTROS ─────────────

  /// Filtra el historial por nombre de jugador y/o ficha máxima alcanzada.
  Future<List<Partida>> filtrar({String? usuario, int? fichaMinima}) async {
    final db = await _helper.database;
    final where = <String>[];
    final args = <Object?>[];

    if (usuario != null && usuario.trim().isNotEmpty) {
      where.add('${DatabaseHelper.colPartidaUsuario} = ?');
      args.add(usuario.trim());
    }
    if (fichaMinima != null && fichaMinima > 0) {
      where.add('${DatabaseHelper.colPartidaFichaMaxima} >= ?');
      args.add(fichaMinima);
    }

    final rows = await db.query(
      DatabaseHelper.tablaPartidas,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: '${DatabaseHelper.colPartidaFecha} DESC',
    );
    return rows.map(Partida.fromMap).toList();
  }

  // ───────────── AGREGACIONES ─────────────

  /// Ranking: las 10 mejores partidas por puntuación (ORDER BY + LIMIT).
  Future<List<Partida>> ranking({int limite = 10}) async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tablaPartidas,
      orderBy: '${DatabaseHelper.colPartidaPuntuacion} DESC',
      limit: limite,
    );
    return rows.map(Partida.fromMap).toList();
  }

  /// Estadísticas globales (COUNT, MAX, AVG, SUM).
  Future<Map<String, num>> estadisticasGlobales() async {
    final db = await _helper.database;
    final r = await db.rawQuery('''
      SELECT
        COUNT(*) AS partidas,
        COALESCE(MAX(${DatabaseHelper.colPartidaPuntuacion}), 0) AS maxPuntuacion,
        COALESCE(AVG(${DatabaseHelper.colPartidaPuntuacion}), 0) AS avgPuntuacion,
        COALESCE(MAX(${DatabaseHelper.colPartidaFichaMaxima}), 0) AS maxFicha,
        COALESCE(SUM(${DatabaseHelper.colPartidaDuracion}), 0) AS totalSegundos
      FROM ${DatabaseHelper.tablaPartidas}
    ''');

    final m = r.first;
    return {
      'partidas': (m['partidas'] as num?) ?? 0,
      'maxPuntuacion': (m['maxPuntuacion'] as num?) ?? 0,
      'avgPuntuacion': (m['avgPuntuacion'] as num?) ?? 0,
      'maxFicha': (m['maxFicha'] as num?) ?? 0,
      'totalSegundos': (m['totalSegundos'] as num?) ?? 0,
    };
  }

  /// Estadísticas por jugador (GROUP BY).
  Future<List<Map<String, Object?>>> estadisticasPorJugador() async {
    final db = await _helper.database;
    return db.rawQuery('''
      SELECT
        ${DatabaseHelper.colPartidaUsuario} AS usuario,
        MAX(${DatabaseHelper.colPartidaPuntuacion}) AS mejorPuntuacion,
        COUNT(*) AS totalPartidas
      FROM ${DatabaseHelper.tablaPartidas}
      GROUP BY ${DatabaseHelper.colPartidaUsuario}
      ORDER BY mejorPuntuacion DESC
    ''');
  }

  // ───────────── TRANSACCIÓN ─────────────

  /// Al terminar una partida, inserta en el historial y borra la partida en curso

  Future<void> finalizarPartida(Partida p) async {
    final db = await _helper.database;
    try {
      await db.transaction((txn) async {
        // 1. Insertamos la partida terminada
        await txn.insert(DatabaseHelper.tablaPartidas, p.toMap());
        // 2. Borramos la partida en curso
        await txn.delete(DatabaseHelper.tablaPartidaGuardada);
      });
    } on DatabaseException catch (e) {
      throw Exception('Error al finalizar partida: $e');
    }
  }
}