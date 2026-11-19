import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  const StatCard({super.key, required this.titulo, required this.valor, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.espaciadoM),
        child: Column(
          children: [
            Icon(icono, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(titulo, style: const TextStyle(fontSize: 12)),
            Text(valor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}