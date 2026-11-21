import 'package:flutter/material.dart';
import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../theme/app_theme.dart';
import '../widgets/async_data_view.dart';
import '../widgets/stat_card.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final PartidaDao _dao = PartidaDao();

  // Futuros para cargar los 3 bloques de datos
  late Future<List<Partida>> _futureTop10;
  late Future<Map<String, num>> _futureGlobal;
  late Future<List<Map<String, Object?>>> _futurePorJugador;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Carga los datos llamando al DAO
  void _cargarDatos() {
    setState(() {
      _futureTop10 = _dao.ranking(limite: 10);
      _futureGlobal = _dao.estadisticasGlobales();
      _futurePorJugador = _dao.estadisticasPorJugador();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking y Estadísticas'),
        actions: [
          // RefreshIndicator manual mediante botón
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
          )
        ],
      ),
      // RefreshIndicator para tirar hacia abajo y recargar
      body: RefreshIndicator(
        onRefresh: () async => _cargarDatos(),
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.espaciadoM),
          children: [
            // ─────────── ESTADÍSTICAS GLOBALES ───────────
            Text('Estadísticas Globales', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppTheme.espaciadoM),

            AsyncDataView<Map<String, num>>(
              future: _futureGlobal,
              builder: (stats) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2, // 2 columnas
                  childAspectRatio: 1.2,
                  mainAxisSpacing: AppTheme.espaciadoS,
                  crossAxisSpacing: AppTheme.espaciadoS,
                  children: [
                    StatCard(
                        titulo: 'Partidas',
                        valor: '${stats['partidas']}',
                        icono: Icons.videogame_asset
                    ),
                    StatCard(
                        titulo: 'Puntuación Máx',
                        valor: '${stats['maxPuntuacion']}',
                        icono: Icons.emoji_events
                    ),
                    StatCard(
                        titulo: 'Puntuación Media',
                        valor: '${stats['avgPuntuacion']!.toStringAsFixed(1)}', // Redondeamos a 1 decimal
                        icono: Icons.analytics
                    ),
                    StatCard(
                        titulo: 'Ficha Máxima',
                        valor: '${stats['maxFicha']}',
                        icono: Icons.grid_on
                    ),
                  ],
                );
              },
            ),

            const Divider(height: AppTheme.espaciadoXL),

            // ─────────── TOP 10 PARTIDAS ───────────
            Text('Top 10 Mejores Partidas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppTheme.espaciadoM),

            AsyncDataView<List<Partida>>(
              future: _futureTop10,
              builder: (partidas) {
                if (partidas.isEmpty) return const Text('No hay partidas aún');

                // Usamos un Card con un ListView interno
                return Card(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: partidas.length,
                    itemBuilder: (context, index) {
                      final p = partidas[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: index == 0
                              ? Colors.amber
                              : (index == 1 ? Colors.grey : (index == 2 ? Colors.brown : Colors.blueGrey)),
                          child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text('${p.puntuacion} puntos'),
                        subtitle: Text('Jugador: ${p.usuario} · Ficha: ${p.fichaMaxima}'),
                      );
                    },
                  ),
                );
              },
            ),

            const Divider(height: AppTheme.espaciadoXL),

            // ─────────── ESTADÍSTICAS POR JUGADOR ───────────
            Text('Mejores Jugadores', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppTheme.espaciadoM),

            AsyncDataView<List<Map<String, Object?>>>(
              future: _futurePorJugador,
              builder: (jugadores) {
                if (jugadores.isEmpty) return const Text('No hay jugadores aún');

                return Card(
                  child: Column(
                    children: jugadores.map((j) {
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text('${j['usuario']}'),
                        subtitle: Text('Partidas jugadas: ${j['totalPartidas']}'),
                        trailing: Text(
                            '${j['mejorPuntuacion']} pts',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}