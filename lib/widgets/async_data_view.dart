import 'package:flutter/material.dart';

/// Widget genérico que gestiona los estados de carga, error y datos de un Future.
/// Gestiona el loading, error o los datos.
class AsyncDataView<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T) builder;
  final VoidCallback? onRetry;

  const AsyncDataView({
    super.key,
    required this.future,
    required this.builder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        // 1. Estado de carga: muestra un indicador circular
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // 2. Estado de error: muestra el mensaje y un botón para reintentar
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${snapshot.error}'),
                if (onRetry != null)
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Reintentar'),
                  ),
              ],
            ),
          );
        }
        // 3. Estado de éxito: pasa los datos al builder
        return builder(snapshot.data as T);
      },
    );
  }
}