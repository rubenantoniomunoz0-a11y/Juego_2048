import 'package:flutter/material.dart';
import '../game/direccion.dart';
import '../theme/app_theme.dart';
import 'tile_widget.dart';

/// Widget que dibuja la cuadrícula del tablero y captura los gestos de deslizamiento.
/// Gestos para mover las piezas.
class BoardWidget extends StatelessWidget {
  final List<int> tablero;
  final Function(Direccion) onSwipe;

  const BoardWidget({super.key, required this.tablero, required this.onSwipe});

  @override
  Widget build(BuildContext context) {
    // GestureDetector para detectar swipes horizontales y verticales
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        // Si la velocidad supera un umbral (200), es un swipe válido
        if (details.primaryVelocity! > 200) {
          onSwipe(Direccion.derecha); // Swipe a la derecha
        } else if (details.primaryVelocity! < -200) {
          onSwipe(Direccion.izquierda); // Swipe a la izquierda
        }
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 200) {
          onSwipe(Direccion.abajo); // Swipe hacia abajo
        } else if (details.primaryVelocity! < -200) {
          onSwipe(Direccion.arriba); // Swipe hacia arriba
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.espaciadoS),
        decoration: BoxDecoration(
          // Color del fondo del tablero según el tema
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2C2A26)
              : const Color(0xFFBBADA0),
          borderRadius: BorderRadius.circular(AppTheme.radioBorde),
        ),
        child: AspectRatio(
          aspectRatio: 1, // Para que el tablero sea siempre cuadrado
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // Sin scroll
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4 columnas
              mainAxisSpacing: AppTheme.espaciadoS,
              crossAxisSpacing: AppTheme.espaciadoS,
            ),
            itemCount: 16, // 16 huecos
            itemBuilder: (context, index) => TileWidget(valor: tablero[index]),
          ),
        ),
      ),
    );
  }
}