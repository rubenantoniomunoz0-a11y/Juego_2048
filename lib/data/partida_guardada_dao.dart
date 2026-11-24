import 'package:sqflite/sqflite.dart';
import '../models/partida_guardada.dart';
import 'database_helper.dart';

/// Objeto de Acceso a Datos (DAO) encargado de gestionar la persistencia 
/// de la partida guardada en curso dentro de la base de datos SQLite.
class PartidaGuardadaDao {
  // Instancia del helper para obtener la conexión a la base de datos
  final DatabaseHelper _helper = DatabaseHelper();
  
  // Identificador fijo para garantizar que solo exista un único registro de guardado
  static const int _idUnico = 1;

  /// Guarda o actualiza la partida en curso en la base de datos.
  /// Si ya existe un registro con el mismo ID, lo sobrescribe gracias a `ConflictAlgorithm.replace`.
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

  /// Recupera la partida guardada de la base de datos.
  /// Devuelve una instancia de [PartidaGuardada] si existe, o `null` si no hay ninguna.
  Future<PartidaGuardada?> cargar() async {
    final db = await _helper.database;
    
    // Consulta parametrizada para buscar el registro por su ID único
    final rows = await db.query(
      DatabaseHelper.tablaPartidaGuardada,
      where: '${DatabaseHelper.colGuardadaId} = ?',
      whereArgs: [_idUnico],
      limit: 1,
    );
    
    // Si no hay resultados devuelve null; de lo contrario, convierte el mapa a objeto
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

  /// Elimina cualquier registro existente en la tabla de partida guardada.
  /// Útil cuando la partida finaliza o el jugador decide descartarla.
  Future<void> borrar() async {
    final db = await _helper.database;
    await db.delete(DatabaseHelper.tablaPartidaGuardada);
  }
}
