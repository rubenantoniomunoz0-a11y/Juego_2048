import 'package:flutter/material.dart';

class EmptyStateView extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  const EmptyStateView({super.key, required this.mensaje, this.icono = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(mensaje, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}