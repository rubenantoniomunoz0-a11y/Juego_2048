import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget de presentación sin estado (*Stateless*) que muestra una tarjeta
/// con un icono, un título descriptivo y un valor para vistas de estadísticas.
///
/// Requisito Parte D: Tarjeta con título, valor e icono para estadísticas.
class StatCard extends StatelessWidget {
  /// Etiqueta o título que describe la estadística mostrada.
  final String titulo;

  /// Valor formateado de la estadística (ej. número de partidas, promedio o récord).
  final String valor;

  /// Icono representativo de la métrica.
  final IconData icono;

  /// Constructor constante que recibe la clave opcional, el [titulo], el [valor] y el [icono].
  const StatCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    // Envuelve el contenido en un Card estándar de Material Design
    return Card(
      child: Padding(
        // Aplica relleno interno uniforme según el espaciado medio del tema
        padding: const EdgeInsets.all(AppTheme.espaciadoM),
        child: Column(
          children: [
            // Icono principal coloreado con el color primario del tema activo
            Icon(
              icono,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            // Separación vertical entre el icono y el título
            const SizedBox(height: 8),
            // Título descriptivo de la estadística
            Text(
              titulo,
              style: const TextStyle(fontSize: 12),
            ),
            // Valor destacado en negrita
            Text(
              valor,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}