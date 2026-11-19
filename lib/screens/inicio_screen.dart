import 'package:flutter/material.dart';
import '../routes.dart'; // <--- AHORA ES ASÍ
import '../data/partida_guardada_dao.dart';
import '../models/partida_guardada.dart';
import '../theme/app_theme.dart';
import 'app.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _guardadaDao = PartidaGuardadaDao();
  PartidaGuardada? _partidaGuardada;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _comprobarPartidaGuardada();
  }

  Future<void> _comprobarPartidaGuardada() async {
    final p = await _guardadaDao.cargar();
    if (mounted) {
      setState(() {
        _partidaGuardada = p;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.prefsService;
    final modoActual = prefs?.leerModoTema() ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(title: const Text('2048')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.espaciadoM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.grid_on, size: 80, color: Colors.orange),
              const SizedBox(height: AppTheme.espaciadoL),
              Text(
                'Bienvenido al 2048',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.espaciadoXL),

              // BOTÓN CONTINUAR (solo si hay partida guardada)
              if (_partidaGuardada != null) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      Routes.juego,
                      arguments: _partidaGuardada,
                    ).then((_) => _comprobarPartidaGuardada());
                  },
                  icon: const Icon(Icons.play_circle),
                  label: const Text('Continuar partida'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.espaciadoM),
              ],

              // BOTÓN NUEVA PARTIDA
              ElevatedButton.icon(
                onPressed: () {
                  _guardadaDao.borrar();
                  Navigator.pushNamed(context,Routes.juego)
                      .then((_) => _comprobarPartidaGuardada());
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Nueva partida'),
              ),
              const SizedBox(height: AppTheme.espaciadoM),

              // BOTÓN HISTORIAL
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.historial),
                icon: const Icon(Icons.history),
                label: const Text('Ver Historial'),
              ),
              const SizedBox(height: AppTheme.espaciadoM),

              // BOTÓN RANKING
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.ranking),
                icon: const Icon(Icons.leaderboard),
                label: const Text('Ranking y Estadísticas'),
              ),
              const SizedBox(height: AppTheme.espaciadoM),

              // BOTÓN AJUSTES
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.ajustes),
                icon: const Icon(Icons.settings),
                label: const Text('Ajustes'),
              ),

              const SizedBox(height: AppTheme.espaciadoXL),
              const Text('Modo de tema:'),
              const SizedBox(height: AppTheme.espaciadoS),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text('Claro'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto),
                    label: Text('Sistema'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Oscuro'),
                  ),
                ],
                selected: {modoActual},
                onSelectionChanged: (sel) {
                  context.themeNotifier?.value = sel.first;
                  context.prefsService?.guardarModoTema(sel.first);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}