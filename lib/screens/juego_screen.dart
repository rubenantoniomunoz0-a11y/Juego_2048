import 'package:flutter/material.dart';
import '../game/direccion.dart';
import '../game/game_logic.dart';
import '../widgets/board_widget.dart';
import '../widgets/score_card.dart';
import '../theme/app_theme.dart';
import '../data/partida_guardada_dao.dart'; // Para el guardado automático

class JuegoScreen extends StatefulWidget {
  const JuegoScreen({super.key});

  @override
  State<JuegoScreen> createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> {
  // Instancio la lógica del juego y el DAO para guardar
  late GameLogic _logic;
  final _guardadaDao = PartidaGuardadaDao();

  @override
  void initState() {
    super.initState();
    _logic = GameLogic(); // Empiezo una partida nueva nada más entrar
  }

  // Esta función se llama desde el BoardWidget cuando el usuario hace un swipe
  void _mover(Direccion dir) {
    setState(() {
      _logic.mover(dir); // Muevo las fichas y actualizo la pantalla
    });

    // Compruebo si después del movimiento el jugador ha perdido
    if (!_logic.hayMovimientosPosibles()) {
      _mostrarFinDePartida();
    }
  }

  // Muestro un diálogo cuando se acaba la partida
  void _mostrarFinDePartida() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¡Fin del juego!'),
        content: Text('Puntuación final: ${_logic.puntuacion}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _logic = GameLogic()); // Reinicio el juego
            },
            child: const Text('Jugar de nuevo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego'),
        actions: [
          // Botón para reiniciar la partida en cualquier momento
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _logic = GameLogic()),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.espaciadoM),
        child: Column(
          children: [
            // Arriba pongo las tarjetas de puntuación y movimientos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ScoreCard(etiqueta: 'PUNTOS', valor: '${_logic.puntuacion}'),
                ScoreCard(etiqueta: 'MOVS', valor: '${_logic.movimientos}'),
              ],
            ),
            const SizedBox(height: AppTheme.espaciadoL),

            // El tablero, que recibe el estado actual y la función para moverse
            BoardWidget(tablero: _logic.tablero, onSwipe: _mover),
          ],
        ),
      ),
    );
  }
}