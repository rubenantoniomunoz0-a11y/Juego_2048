import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget de presentación sin estado (*Stateless*) que muestra una etiqueta descriptiva
/// junto con un valor (por ejemplo, puntuación actual o mejor puntuación).
///
/// Requisito Parte D: Muestra etiqueta y valor numérico.
class ScoreCard extends StatelessWidget {
/// Texto descriptivo que identifica el dato mostrado (ej. "PUNTOS" o "MEJOR").
final String etiqueta;

/// Valor formateado como texto para su visualización en pantalla.
final String valor;

/// Constructor constante que recibe la clave opcional, la [etiqueta] y el [valor].
const ScoreCard({super.key, required this.etiqueta, required this.valor});

/// Construye la tarjeta visual con la etiqueta superior y el valor destacado inferior.
@override
Widget build(BuildContext context) {
  return Container(
    // Aplica espaciado horizontal y vertical según las constantes del tema
    padding: const EdgeInsets.symmetric(
      horizontal: AppTheme.espaciadoM,
      vertical: AppTheme.espaciadoS,
    ),
    decoration: BoxDecoration(
      // Usa el color de superficie elevado del tema actual (claro u oscuro)
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppTheme.radioBorde),
    ),
    child: Column(
      // Ajusta la altura de la columna al contenido mínimo necesario
      mainAxisSize: MainAxisSize.min,
      children: [
        // Etiqueta superior en tamaño pequeño y negrita
        Text(
          etiqueta,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        // Valor principal en tamaño mayor y negrita
        Text(
          valor,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
}