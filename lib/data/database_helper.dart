import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Clase Singleton que gestiona la creación y apertura de la base de datos SQLite.
class DatabaseHelper {
  // ─────────────────────────────────────────────
  // PATRÓN SINGLETON
  // ─────────────────────────────────────────────
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  /// Getter para obtener la base de datos. Si no está abierta, la abre.
  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  // ─────────────────────────────────────────────
  // CONSTANTES (Evitan errores tipográficos en los DAOs)
  // ─────────────────────────────────────────────
  static const String dbName = 'game2048.db';
  static const int dbVersion = 2; // Versión 2 para aplicar la migración

  // Tabla usuarios
  static const String tablaUsuarios = 'usuarios';
  static const String colUsuarioId = 'id';
  static const String colUsuarioNombre = 'usuario';
  static const String colUsuarioFechaRegistro = 'fecha_registro';
  static const String colUsuarioEmail = 'email';
  static const String colUsuarioContrasena = 'contrasena';

  // Tabla partidas
  static const String tablaPartidas = 'partidas';
  static const String colPartidaId = 'id';
  static const String colPartidaUsuario = 'usuario';
  static const String colPartidaPuntuacion = 'puntuacion';
  static const String colPartidaFichaMaxima = 'ficha_maxima';
  static const String colPartidaMovimientos = 'movimientos';
  static const String colPartidaDuracion = 'duracion_segundos';
  static const String colPartidaFecha = 'fecha';
  static const String colPartidaTamanoTablero = 'tamano_tablero'; // Columna añadida en v2

  // Tabla partida_guardada
  static const String tablaPartidaGuardada = 'partida_guardada';
  static const String colGuardadaId = 'id';
  static const String colGuardadaTablero = 'tablero';
  static const String colGuardadaPuntuacion = 'puntuacion';
  static const String colGuardadaMovimientos = 'movimientos';
  static const String colGuardadaSegundos = 'segundos_transcurridos';

  // ─────────────────────────────────────────────
  // APERTURA Y CONFIGURACIÓN
  // ─────────────────────────────────────────────
  Future<Database> _initDb() async {
    final ruta = join(await getDatabasesPath(), dbName);

    return openDatabase(
      ruta,
      version: dbVersion,
      onConfigure: (db) async {
        // Requisito A.1: Activar claves foráneas si normalizamos el modelo
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ─────────────────────────────────────────────
  // CREACIÓN DE TABLAS (Se ejecuta solo la primera vez)
  // ─────────────────────────────────────────────
  Future<void> _onCreate(Database db, int version) async {
    // 1. Crear tabla usuarios
    await db.execute('''
      CREATE TABLE $tablaUsuarios (
        $colUsuarioId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colUsuarioNombre TEXT NOT NULL,
        $colUsuarioFechaRegistro TEXT NOT NULL,
        $colUsuarioEmail TEXT NOT NULL,
        $colUsuarioContrasena TEXT NOT NULL
      )
    ''');

    // 2. Crear tabla partidas
    await db.execute('''
      CREATE TABLE $tablaPartidas (
        $colPartidaId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colPartidaUsuario TEXT NOT NULL,
        $colPartidaPuntuacion INTEGER NOT NULL,
        $colPartidaFichaMaxima INTEGER NOT NULL,
        $colPartidaMovimientos INTEGER NOT NULL,
        $colPartidaDuracion INTEGER NOT NULL,
        $colPartidaFecha TEXT NOT NULL,
        $colPartidaTamanoTablero INTEGER NOT NULL DEFAULT 4
      )
    ''');

    // 3. Crear tabla partida_guardada
    await db.execute('''
      CREATE TABLE $tablaPartidaGuardada (
        $colGuardadaId INTEGER PRIMARY KEY,
        $colGuardadaTablero TEXT NOT NULL,
        $colGuardadaPuntuacion INTEGER NOT NULL,
        $colGuardadaMovimientos INTEGER NOT NULL,
        $colGuardadaSegundos INTEGER NOT NULL
      )
    ''');
  }

  // ─────────────────────────────────────────────
  // MIGRACIÓN
  // ─────────────────────────────────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Si la BD era la versión 1, le añadimos la columna 'tamano_tablero'
      // sin perder los datos que ya hubiera.
      await db.execute(
        'ALTER TABLE $tablaPartidas '
            'ADD COLUMN $colPartidaTamanoTablero INTEGER NOT NULL DEFAULT 4',
      );
    }
  }

  // ─────────────────────────────────────────────
  // UTILIDADES
  // ─────────────────────────────────────────────

  /// Borra la fila de partida en curso (usar al terminar o reiniciar).
  Future<void> borrarPartidaGuardada() async {
    final db = await database;
    await db.delete(tablaPartidaGuardada);
  }
}