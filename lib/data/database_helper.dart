import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Clase Singleton que gestiona la creación, apertura y migración
/// de la base de datos local SQLite de la aplicación.
class DatabaseHelper {
  // ─────────────────────────────────────────────
  // PATRÓN SINGLETON
  // ─────────────────────────────────────────────
  
  // Única instancia privada y estática de la clase
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  
  // Constructor factory que siempre devuelve la misma instancia existente
  factory DatabaseHelper() => _instance;
  
  // Constructor privado para evitar que se instancie desde fuera de la clase
  DatabaseHelper._internal();

  // Referencia estática a la conexión activa con la base de datos
  static Database? _db;

  /// Getter asíncrono para obtener la instancia de la base de datos.
  /// Si aún no se ha inicializado, ejecuta [_initDb] antes de devolverla.
  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  // ─────────────────────────────────────────────
  // CONSTANTES (Evitan errores tipográficos en los DAOs)
  // ─────────────────────────────────────────────
  
  // Nombre del archivo físico de la base de datos y versión actual del esquema
  static const String dbName = 'game2048.db';
  static const int dbVersion = 2; // Versión 2 para aplicar la migración

  // Definición de la tabla 'usuarios' y sus columnas
  static const String tablaUsuarios = 'usuarios';
  static const String colUsuarioId = 'id';
  static const String colUsuarioNombre = 'usuario';
  static const String colUsuarioFechaRegistro = 'fecha_registro';
  static const String colUsuarioEmail = 'email';
  static const String colUsuarioContrasena = 'contrasena';

  // Definición de la tabla 'partidas' (historial) y sus columnas
  static const String tablaPartidas = 'partidas';
  static const String colPartidaId = 'id';
  static const String colPartidaUsuario = 'usuario';
  static const String colPartidaPuntuacion = 'puntuacion';
  static const String colPartidaFichaMaxima = 'ficha_maxima';
  static const String colPartidaMovimientos = 'movimientos';
  static const String colPartidaDuracion = 'duracion_segundos';
  static const String colPartidaFecha = 'fecha';
  static const String colPartidaTamanoTablero = 'tamano_tablero'; // Columna añadida en v2

  // Definición de la tabla 'partida_guardada' (estado en curso) y sus columnas
  static const String tablaPartidaGuardada = 'partida_guardada';
  static const String colGuardadaId = 'id';
  static const String colGuardadaTablero = 'tablero';
  static const String colGuardadaPuntuacion = 'puntuacion';
  static const String colGuardadaMovimientos = 'movimientos';
  static const String colGuardadaSegundos = 'segundos_transcurridos';

  // ─────────────────────────────────────────────
  // APERTURA Y CONFIGURACIÓN
  // ─────────────────────────────────────────────
  
  /// Construye la ruta en el dispositivo y abre (o crea) la base de datos.
  Future<Database> _initDb() async {
    // Obtiene el directorio estándar de bases de datos según el SO (Android/iOS)
    final ruta = join(await getDatabasesPath(), dbName);

    return openDatabase(
      ruta,
      version: dbVersion,
      // Se ejecuta cada vez que se abre la BD, antes de crear o actualizar tablas
      onConfigure: (db) async {
        // Requisito A.1: Activar claves foráneas si normalizamos el modelo
        await db.execute('PRAGMA foreign_keys = ON');
      },
      // Callback que se lanza si el archivo de BD no existía previamente
      onCreate: _onCreate,
      // Callback que se lanza si `dbVersion` es mayor que la versión guardada en disco
      onUpgrade: _onUpgrade,
    );
  }

  // ─────────────────────────────────────────────
  // CREACIÓN DE TABLAS (Se ejecuta solo la primera vez)
  // ─────────────────────────────────────────────
  
  /// Crea desde cero todas las tablas necesarias cuando se instala la app por primera vez.
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

    // 2. Crear tabla partidas (incluye ya el campo 'tamano_tablero' por defecto a 4)
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

    // 3. Crear tabla partida_guardada (sin AUTOINCREMENT porque usa un ID fijo)
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

  
  // MIGRACIÓN
  
  
  /// Gestiona las actualizaciones del esquema cuando sube la versión de la base de datos.
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

  // UTILIDADES


  /// Borra la fila de partida en curso (usar al terminar o reiniciar).
  Future<void> borrarPartidaGuardada() async {
    final db = await database;
    await db.delete(tablaPartidaGuardada);
  }
}
