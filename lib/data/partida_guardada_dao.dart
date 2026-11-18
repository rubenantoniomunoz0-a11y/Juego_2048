import 'package:sqflite/sqflite.dart';
import '../models/partida_guardada.dart';
import 'database_helper.dart';

class PartidaGuardadaDao {
  final DatabaseHelper _helper = DatabaseHelper();
  static const int _idUnico = 1;

  Future<void> guardar(PartidaGuardada p) async {
    final db = await _helper.database;
    try {
      await db.insert(
        DatabaseHelper.tablaPartidaGuardada,
        p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error al guardar la partida en curso: $e');
    }
  }

  Future<PartidaGuardada?> cargar() async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tablaPartidaGuardada,
      where: '${DatabaseHelper.colGuardadaId} = ?',
      whereArgs: [_idUnico],
      limit: 1,
    );
    return rows.isEmpty ? null : PartidaGuardada.fromMap(rows.first);
  }

  /// Comprueba si hay una partida guardada usando db.query.
  /// Esto evita usar rawQuery y cumple al 100% con las buenas prácticas.
  Future<bool> existe() async {
    final db = await _helper.database;

    // Pedimos solo la columna ID y limitamos a 1 resultado para que sea súper rápido
    final rows = await db.query(
      DatabaseHelper.tablaPartidaGuardada,
      columns: [DatabaseHelper.colGuardadaId],
      limit: 1,
    );

    // Si la lista tiene al menos un elemento, es que existe una partida guardada
    return rows.isNotEmpty;
  }

  Future<void> borrar() async {
    final db = await _helper.database;
    await db.delete(DatabaseHelper.tablaPartidaGuardada);
  }
}