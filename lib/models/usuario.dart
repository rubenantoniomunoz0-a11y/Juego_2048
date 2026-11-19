import '../data/database_helper.dart';

class Usuario {
  final int? id;
  final String usuario;
  final DateTime fechaRegistro;
  final String email;
  final String contrasenaHash;

  const Usuario({
    this.id,
    required this.usuario,
    required this.fechaRegistro,
    required this.email,
    required this.contrasenaHash,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) DatabaseHelper.colUsuarioId: id,
    DatabaseHelper.colUsuarioNombre: usuario,
    DatabaseHelper.colUsuarioFechaRegistro: fechaRegistro.toIso8601String(),
    DatabaseHelper.colUsuarioEmail: email,
    DatabaseHelper.colUsuarioContrasena: contrasenaHash,
  };

  factory Usuario.fromMap(Map<String, dynamic> m) => Usuario(
    id: m[DatabaseHelper.colUsuarioId] as int?,
    usuario: m[DatabaseHelper.colUsuarioNombre] as String,
    fechaRegistro: DateTime.parse(m[DatabaseHelper.colUsuarioFechaRegistro] as String),
    email: m[DatabaseHelper.colUsuarioEmail] as String,
    contrasenaHash: m[DatabaseHelper.colUsuarioContrasena] as String,
  );
}