import 'package:flutter/material.dart';
import '../game/direccion.dart';
import '../game/game_logic.dart';
import '../widgets/board_widget.dart';
import '../widgets/score_card.dart';
import '../theme/app_theme.dart';
import '../data/partida_guardada_dao.dart';
import '../data/partida_dao.dart';
import '../models/partida_guardada.dart';
import '../models/partida.dart';
import '../services/preferencias_service.dart';

class JuegoScreen extends StatefulWidget {
  final PartidaGuardada? partidaGuardada;

  const JuegoScreen({super.key, this.partidaGuardada});

  @override
  State<JuegoScreen> createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> with WidgetsBindingObserver {
  late GameLogic _logic;
  final _guardadaDao = PartidaGuardadaDao();
  final _partidaDao = PartidaDao();
  final _prefs = PreferenciasService.crear();

  DateTime _inicioPartida = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.partidaGuardada != null) {
      _logic = GameLogic(
        tableroInicial: widget.partidaGuardada!.tablero,
        puntuacionInicial: widget.partidaGuardada!.puntuacion,
        movimientosInicial: widget.partidaGuardada!.movimientos,
      );
    } else {
      _logic = GameLogic();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _guardarPartida();
    }
  }

  Future<void> _guardarPartida() async {
    final pGuardada = PartidaGuardada(
      tablero: _logic.tablero,
      puntuacion: _logic.puntuacion,
      movimientos: _logic.movimientos,
      segundosTranscurridos: DateTime.now().difference(_inicioPartida).inSeconds,
    );
    await _guardadaDao.guardar(pGuardada);
  }

  void _mostrarFinDePartida() async {
    final prefs = await _prefs;
    final usuario = prefs.leerUltimoJugador() ?? 'Invitado';

    final pFinal = Partida(
      usuario: usuario,
      puntuacion: _logic.puntuacion,
      fichaMaxima: _logic.fichaMaxima,
      movimientos: _logic.movimientos,
      duracionSegundos: DateTime.now().difference(_inicioPartida).inSeconds,
      fecha: DateTime.now(),
    );

    await _partidaDao.finalizarPartida(pFinal);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('¡Fin del juego!'),
        content: Text('Puntuación: ${_logic.puntuacion}\nFicha máxima: ${_logic.fichaMaxima}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Volver al inicio'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _logic = GameLogic();
                _inicioPartida = DateTime.now();
              });
            },
            child: const Text('Jugar de nuevo'),
          ),
        ],
      ),
    );
  }

  void _mover(Direccion dir) {
    setState(() {
      _logic.mover(dir);
    });
    if (!_logic.hayMovimientosPosibles()) {
      _mostrarFinDePartida();
    }
  }

  Future<void> _onWillPop() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir de la partida?'),
        content: const Text('Puedes guardar tu progreso para continuar después.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _guardadaDao.borrar();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Salir sin guardar', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _guardarPartida();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar y salir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onWillPop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Juego'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onWillPop,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {
                _logic = GameLogic();
                _inicioPartida = DateTime.now();
              }),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppTheme.espaciadoM),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // DOBLE TOQUE EN LA PUNTUACIÓN
                  GestureDetector(
                    onDoubleTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Detalles de la partida'),
                          content: Text('Tiempo jugado: ${DateTime.now().difference(_inicioPartida).inSeconds} segundos'),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                        ),
                      );
                    },
                    child: ScoreCard(etiqueta: 'PUNTOS', valor: '${_logic.puntuacion}'),
                  ),
                  ScoreCard(etiqueta: 'MOVS', valor: '${_logic.movimientos}'),
                ],
              ),
              const SizedBox(height: AppTheme.espaciadoL),

              // TABLERO
              BoardWidget(tablero: _logic.tablero, onSwipe: _mover),

              // BOTONES DE FLECHAS (ACCESIBILIDAD)
              const SizedBox(height: AppTheme.espaciadoM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, size: 32), onPressed: () => _mover(Direccion.izquierda)),
                  Column(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_upward, size: 32), onPressed: () => _mover(Direccion.arriba)),
                      IconButton(icon: const Icon(Icons.arrow_downward, size: 32), onPressed: () => _mover(Direccion.abajo)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.arrow_forward, size: 32), onPressed: () => _mover(Direccion.derecha)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}