import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import '../models/usuario.dart';
import 'database_helper.dart';

/// Objeto de Acceso a Datos (DAO) encargado de gestionar la autenticación
/// (registro, inicio de sesión y consultas) de los usuarios en SQLite.
class UsuarioDao {
  // Instancia del helper para obtener la conexión activa con la base de datos
  final DatabaseHelper _helper = DatabaseHelper();

  /// Genera un resumen criptográfico (hash) de la contraseña usando SHA-256.
  /// Evita almacenar contraseñas en texto plano por seguridad.
  static String hashContrasena(String contrasena) {
    // Convierte el texto a bytes UTF-8, aplica SHA-256 y lo devuelve como String hexadecimal
    return sha256.convert(utf8.encode(contrasena)).toString();
  }

  /// Valida mediante una expresión regular que el correo electrónico
  /// tenga una estructura básica válida (`texto@dominio.ext`).
  static bool emailValido(String email) {
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(email);
  }

  /// Registra un nuevo usuario tras validar sus datos y comprobar que no exista previamente.
  /// Devuelve el `id` autogenerado del nuevo registro en la base de datos.
  Future<int> registrar({
    required String usuario,
    required String email,
    required String contrasena,
  }) async {
    // 1. Validaciones de formato y longitud antes de tocar la base de datos
    if (!emailValido(email)) {
      throw const FormatException('El email no es válido');
    }
    if (usuario.trim().isEmpty) {
      throw const FormatException('El nombre de usuario no puede estar vacío');
    }
    if (contrasena.length < 4) {
      throw const FormatException('La contraseña debe tener al menos 4 caracteres');
    }

    final db = await _helper.database;

    // 2. Comprobación de unicidad: verifica si ya existe el mismo nombre de usuario o email
    final existentes = await db.query(
      DatabaseHelper.tablaUsuarios,
      where: '${DatabaseHelper.colUsuarioNombre} = ? OR ${DatabaseHelper.colUsuarioEmail} = ?',
      whereArgs: [usuario, email],
      limit: 1,
    );
    if (existentes.isNotEmpty) {
      throw Exception('Ya existe un usuario con ese nombre o email');
    }

    // 3. Construcción del modelo con la fecha actual y la contraseña encriptada
    final nuevo = Usuario(
      usuario: usuario,
      email: email,
      fechaRegistro: DateTime.now(),
      contrasenaHash: hashContrasena(contrasena),
    );

    // 4. Inserción en la tabla 'usuarios' capturando posibles errores nativos de SQLite
    try {
      return await db.insert(DatabaseHelper.tablaUsuarios, nuevo.toMap());
    } on DatabaseException catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  /// Verifica las credenciales de acceso comparando el usuario y el hash de su contraseña.
  /// Devuelve el objeto [Usuario] si coincide, o `null` si las credenciales son incorrectas.
  Future<Usuario?> login({
    required String usuario,
    required String contrasena,
  }) async {
    final db = await _helper.database;
    
    // Hasheamos la contraseña introducida para compararla con el hash guardado en la BD
    final hash = hashContrasena(contrasena);

    // Consulta parametrizada (previene inyección SQL) filtrando por usuario y contraseña
    final rows = await db.query(
      DatabaseHelper.tablaUsuarios,
      where: '${DatabaseHelper.colUsuarioNombre} = ? AND ${DatabaseHelper.colUsuarioContrasena} = ?',
      whereArgs: [usuario, hash],
      limit: 1,
    );

    // Si hay coincidencia reconstruye el objeto Usuario; si no, devuelve null
    return rows.isEmpty ? null : Usuario.fromMap(rows.first);
  }

  /// Busca y recupera los datos de un usuario específico a partir de su nombre de usuario.
  /// Devuelve `null` si no se encuentra ningún registro con ese nombre.
  Future<Usuario?> porNombre(String usuario) async {
    final db = await _helper.database;
    
    final rows = await db.query(
      DatabaseHelper.tablaUsuarios,
      where: '${DatabaseHelper.colUsuarioNombre} = ?',
      whereArgs: [usuario],
      limit: 1,
    );
    
    return rows.isEmpty ? null : Usuario.fromMap(rows.first);
  }
}
