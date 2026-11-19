import 'package:flutter/material.dart';

/// Widget sin estado (*Stateless*) que representa un diálogo modal de confirmación
/// reutilizable basado en [AlertDialog].
///
/// Devuelve `true` al cerrar si el usuario acepta o `false` si cancela.
/// Requisito Parte D: Diálogo de confirmación reutilizable.
class ConfirmDialog extends StatelessWidget {
  /// Título principal mostrado en la cabecera del diálogo.
  final String titulo;

  /// Texto descriptivo o pregunta mostrada en el cuerpo del diálogo.
  final String mensaje;

  /// Etiqueta del botón de confirmación positiva. Por defecto es `'Aceptar'`.
  final String textoAceptar;

  /// Etiqueta del botón de cancelación o rechazo. Por defecto es `'Cancelar'`.
  final String textoCancelar;

  /// Constructor constante que inicializa el título, mensaje y etiquetas de los botones.
  const ConfirmDialog({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.textoAceptar = 'Aceptar',
    this.textoCancelar = 'Cancelar',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        // Cierra el diálogo devolviendo false como resultado de la ruta
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(textoCancelar),
        ),
        // Cierra el diálogo devolviendo true como resultado de la ruta
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(textoAceptar),
        ),
      ],
    );
  }
}