import 'package:flutter/material.dart';
import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../theme/app_theme.dart';
import '../widgets/async_data_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/stat_card.dart';

class DetalleScreen extends StatefulWidget {
  // Recibe solo el ID
  final int partidaId;

  const DetalleScreen({super.key, required this.partidaId});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  final PartidaDao _dao = PartidaDao();
  late Future<Partida?> _futurePartida;

  @override
  void initState() {
    super.initState();
    // Consultamos la BD con el ID recibido
    _futurePartida = _dao.porId(widget.partidaId);
  }

  Future<void> _eliminar() async {
    // 1. Pedimos confirmación
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmDialog(
        titulo: 'Eliminar partida',
        mensaje: '¿Seguro que quieres borrar esta partida?',
        textoAceptar: 'Eliminar',
      ),
    );

    if (ok == true) {
      // 2. Borramos de la BD
      await _dao.eliminar(widget.partidaId);

      // 3. Devolvemos 'true' al Historial para que sepa que se ha borrado
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Partida'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: _eliminar,
          ),
        ],
      ),
      body: AsyncDataView<Partida?>(
        future: _futurePartida,
        builder: (partida) {
          if (partida == null) {
            return const Center(child: Text('Partida no encontrada'));
          }

          // Formateamos la fecha para que se vea bonita
          final fecha = partida.fecha.toLocal().toString().split('.')[0];

          return Padding(
            padding: const EdgeInsets.all(AppTheme.espaciadoM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tarjeta principal con la puntuación
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.espaciadoL),
                    child: Column(
                      children: [
                        Text('PUNTUACIÓN FINAL', style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          '${partida.puntuacion}',
                          style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Jugador: ${partida.usuario}'),
                        Text('Fecha: $fecha'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.espaciadoL),

                // Fila con los StatCard 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StatCard(
                        titulo: 'Ficha',
                        valor: '${partida.fichaMaxima}',
                        icono: Icons.grid_on
                    ),
                    StatCard(
                        titulo: 'Movs',
                        valor: '${partida.movimientos}',
                        icono: Icons.swap_horiz
                    ),
                    StatCard(
                        titulo: 'Segundos',
                        valor: '${partida.duracionSegundos}',
                        icono: Icons.timer
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}