import '../data/database_helper.dart';

/// Modelo de datos que representa a un usuario registrado en la aplicación.
/// Contiene su información básica de perfil y las credenciales encriptadas.
class Usuario {
  // Identificador único autogenerado en la base de datos (nulo antes de insertarse)
  final int? id;
  
  // Nombre de usuario único utilizado para iniciar sesión y mostrar en el ranking
  final String usuario;
  
  // Fecha y hora exactas en las que el usuario creó su cuenta
  final DateTime fechaRegistro;
  
  // Dirección de correo electrónico asociada al usuario
  final String email;
  
  // Contraseña encriptada mediante SHA-256 (nunca se almacena en texto plano)
  final String contrasenaHash;

  /// Constructor constante de la clase [Usuario].
  const Usuario({
    this.id,
    required this.usuario,
    required this.fechaRegistro,
    required this.email,
    required this.contrasenaHash,
  });

  /// Convierte la instancia de [Usuario] en un [Map] clave-valor listo para
  /// ser insertado o actualizado en la tabla `usuarios` de SQLite.
  Map<String, dynamic> toMap() => {
    // Solo incluimos el ID si ya existe, dejando que SQLite lo genere automáticamente si es nulo
    if (id != null) DatabaseHelper.colUsuarioId: id,
    DatabaseHelper.colUsuarioNombre: usuario,
    // Serializa el DateTime en formato estándar ISO-8601 para almacenarlo como TEXT en SQLite
    DatabaseHelper.colUsuarioFechaRegistro: fechaRegistro.toIso8601String(),
    DatabaseHelper.colUsuarioEmail: email,
    DatabaseHelper.colUsuarioContrasena: contrasenaHash,
  };

  /// Constructor factory que reconstruye un objeto [Usuario] a partir de una fila
  /// (mapa de columnas) recuperada de una consulta en SQLite.
  factory Usuario.fromMap(Map<String, dynamic> m) => Usuario(
    id: m[DatabaseHelper.colUsuarioId] as int?,
    usuario: m[DatabaseHelper.colUsuarioNombre] as String,
    // Parsea la cadena de texto ISO-8601 de vuelta a un objeto DateTime de Dart
    fechaRegistro: DateTime.parse(m[DatabaseHelper.colUsuarioFechaRegistro] as String),
    email: m[DatabaseHelper.colUsuarioEmail] as String,
    contrasenaHash: m[DatabaseHelper.colUsuarioContrasena] as String,
  );
}
