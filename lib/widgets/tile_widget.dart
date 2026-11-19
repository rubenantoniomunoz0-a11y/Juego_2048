import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TileWidget extends StatelessWidget {
  final int valor;
  const TileWidget({super.key, required this.valor});

  @override
  Widget build(BuildContext context) {
    final brillo = Theme.of(context).brightness;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: ColoresFicha.porValor(valor, brillo),
        borderRadius: BorderRadius.circular(AppTheme.radioFicha),
      ),
      child: Center(
        child: valor == 0 ? const SizedBox.shrink() : Text(
          '$valor',
          style: TextStyle(
            color: ColoresFicha.textoPorValor(valor, brillo),
            fontSize: valor >= 1024 ? 24 : 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}