import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String textoAceptar;
  final String textoCancelar;

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
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(textoCancelar)),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(textoAceptar)),
      ],
    );
  }
}