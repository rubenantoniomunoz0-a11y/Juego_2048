import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScoreCard extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const ScoreCard({super.key, required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.espaciadoM, vertical: AppTheme.espaciadoS),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radioBorde),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(etiqueta, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}