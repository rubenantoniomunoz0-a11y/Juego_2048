import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget de presentación sin estado (*Stateless*) que dibuja una ficha del tablero
/// según su [valor] numérico y el brillo actual del tema (claro u oscuro).
///
/// Requisito Parte D: Widget de presentación (Stateless).
class TileWidget extends StatelessWidget {
  /// Valor numérico de la ficha (`0` representa una casilla vacía).
  final int valor;

  /// Constructor constante que recibe la clave opcional y el [valor] obligatorio de la ficha.
  const TileWidget({super.key, required this.valor});

  @override
  Widget build(BuildContext context) {
    // Obtiene el brillo del tema activo (Brightness.light o Brightness.dark)
    final brillo = Theme.of(context).brightness;

    // Animación implícita requerida: transiciona suavemente los cambios de color o decoración
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        // Aplica el color de fondo correspondiente al valor y al modo claro/oscuro
        color: ColoresFicha.porValor(valor, brillo),
        borderRadius: BorderRadius.circular(AppTheme.radioFicha),
      ),
      child: Center(
        // Si el valor es 0, no muestra texto (ocupa espacio mínimo); si no, dibuja el número
        child: valor == 0
            ? const SizedBox.shrink()
            : Text(
          '$valor',
          style: TextStyle(
            // Ajusta el color del texto según el valor y el brillo del tema
            color: ColoresFicha.textoPorValor(valor, brillo),
            // Reduce el tamaño de fuente en números grandes (1024 o superior) para evitar desbordes
            fontSize: valor >= 1024 ? 24 : 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}