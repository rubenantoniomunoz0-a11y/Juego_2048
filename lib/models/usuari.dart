import '../data/database_helper.dart';

/// Modelo de datos que representa un usuario registrado en la aplicación.
///
/// Almacena la información básica de perfil y credenciales, junto con los métodos
/// necesarios para serializar y deserializar el objeto hacia/desde SQLite.
class Usuario {
  /// Identificador único autogenerado en la base de datos. Es nulo si aún no se ha guardado.
  final int? id;

  /// Nombre de usuario o alias único dentro de la aplicación.
  final String usuario;

  /// Fecha y hora en la que se registró la cuenta del usuario.
  final DateTime fechaRegistro;

  /// Correo electrónico asociado a la cuenta del usuario.
  final String email;

  /// Contraseña del usuario encriptada con SHA-256 (nunca se almacena en texto plano).
  final String contrasenaHash;

  /// Constructor constante para instanciar un objeto [Usuario].
  const Usuario({
    this.id,
    required this.usuario,
    required this.fechaRegistro,
    required this.email,
    required this.contrasenaHash,
  });

  /// Convierte la instancia actual de [Usuario] en un [Map] clave-valor
  /// compatible con las columnas definidas en [DatabaseHelper] para su persistencia en SQLite.
  Map<String, dynamic> toMap() => {
    // Solo incluye el ID si ya existe (útil al actualizar un registro)
    if (id != null) DatabaseHelper.colUsuarioId: id,
    DatabaseHelper.colUsuarioNombre: usuario,
    // Serializa la fecha a formato estándar ISO-8601 para guardarla como texto en SQLite
    DatabaseHelper.colUsuarioFechaRegistro: fechaRegistro.toIso8601String(),
    DatabaseHelper.colUsuarioEmail: email,
    DatabaseHelper.colUsuarioContrasena: contrasenaHash,
  };

  /// Constructor de fábrica (*factory*) que reconstruye una instancia de [Usuario]
  /// a partir de un [Map] obtenido desde una consulta a SQLite.
  factory Usuario.fromMap(Map<String, dynamic> m) => Usuario(
    id: m[DatabaseHelper.colUsuarioId] as int?,
    usuario: m[DatabaseHelper.colUsuarioNombre] as String,
    // Reconstruye el objeto DateTime desde la cadena ISO-8601 almacenada
    fechaRegistro: DateTime.parse(m[DatabaseHelper.colUsuarioFechaRegistro] as String),
    email: m[DatabaseHelper.colUsuarioEmail] as String,
    contrasenaHash: m[DatabaseHelper.colUsuarioContrasena] as String,
  );
}