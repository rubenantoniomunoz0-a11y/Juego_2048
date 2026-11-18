import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import '../models/usuario.dart';
import 'database_helper.dart';

/// DAO para gestionar el registro y login de usuarios.
/// Pantalla de login y registro.
class UsuarioDao {
  final DatabaseHelper _helper = DatabaseHelper();

  /// Encripta la contraseña usando SHA-256.
  /// La contraseña debe guardarse encriptada.
  static String hashContrasena(String contrasena) {
    return sha256.convert(utf8.encode(contrasena)).toString();
  }

  /// Valida que el email tenga un formato correcto (con '@' y dominio).
  static bool emailValido(String email) {
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(email);
  }

  /// Registra un nuevo usuario en la base de datos.
  Future<int> registrar({
    required String usuario,
    required String email,
    required String contrasena,
  }) async {
    // Validaciones previas
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

    // Comprobamos si el usuario o el email ya existen
    final existentes = await db.query(
      DatabaseHelper.tablaUsuarios,
      where: '${DatabaseHelper.colUsuarioNombre} = ? OR ${DatabaseHelper.colUsuarioEmail} = ?',
      whereArgs: [usuario, email],
      limit: 1,
    );
    if (existentes.isNotEmpty) {
      throw Exception('Ya existe un usuario con ese nombre o email');
    }

    // Creamos el objeto con la contraseña ya encriptada
    final nuevo = Usuario(
      usuario: usuario,
      email: email,
      fechaRegistro: DateTime.now(),
      contrasenaHash: hashContrasena(contrasena),
    );

    try {
      return await db.insert(DatabaseHelper.tablaUsuarios, nuevo.toMap());
    } on DatabaseException catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  /// Intenta iniciar sesión. Devuelve el Usuario si las credenciales son correctas, o null si no.
  Future<Usuario?> login({
    required String usuario,
    required String contrasena,
  }) async {
    final db = await _helper.database;
    final hash = hashContrasena(contrasena);

    final rows = await db.query(
      DatabaseHelper.tablaUsuarios,
      where: '${DatabaseHelper.colUsuarioNombre} = ? AND ${DatabaseHelper.colUsuarioContrasena} = ?',
      whereArgs: [usuario, hash],
      limit: 1,
    );

    return rows.isEmpty ? null : Usuario.fromMap(rows.first);
  }

  /// Busca un usuario por su nombre.
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