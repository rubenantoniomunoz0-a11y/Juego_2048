import 'package:flutter/material.dart';

/// Widget reutilizable que muestra los datos resumidos de una partida en el historial.
/// Elemento de lista.
class PartidaListItem extends StatelessWidget {
  final int puntuacion;
  final int fichaMaxima;
  final String fecha;
  final VoidCallback onTap;

  const PartidaListItem({
    super.key,
    required this.puntuacion,
    required this.fichaMaxima,
    required this.fecha,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          '$fichaMaxima',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text('Puntuación: $puntuacion'),
      subtitle: Text(fecha),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap, // Al pulsar, se navega al detalle (gesto onTap)
    );
  }
}