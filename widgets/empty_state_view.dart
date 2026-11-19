import 'package:flutter/material.dart';

/// Widget de presentación sin estado (*Stateless*) que muestra un estado vacío
/// centrado con un icono y un mensaje descriptivo cuando no hay datos disponibles.
///
/// Requisito Parte D: Mensaje e icono para cuando no hay datos.
class EmptyStateView extends StatelessWidget {
  /// Texto explicativo que indica la ausencia de datos o contenido.
  final String mensaje;

  /// Icono ilustrativo mostrado encima del mensaje.
  final IconData icono;

  /// Constructor constante que recibe el [mensaje] obligatorio y un [icono] opcional
  /// (por defecto [Icons.inbox_outlined]).
  const EmptyStateView({
    super.key,
    required this.mensaje,
    this.icono = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    // Centra todo el bloque vertical y horizontalmente en el espacio disponible
    return Center(
      child: Column(
        // Centra los hijos a lo largo del eje principal (vertical)
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono de gran tamaño en tono gris para denotar estado inactivo o vacío
          Icon(icono, size: 64, color: Colors.grey),
          // Separación vertical entre el icono y el texto
          const SizedBox(height: 16),
          // Mensaje descriptivo en gris y tamaño legible
          Text(
            mensaje,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}