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

/// Pantalla principal donde se desarrolla la partida de 2048.
///
/// Recibe opcionalmente una [partidaGuardada]: si es distinta de `null`,
/// restaura el tablero, puntuación y movimientos previos; si es `null`,
/// inicia una partida nueva desde cero.
class JuegoScreen extends StatefulWidget {
  final PartidaGuardada? partidaGuardada;

  const JuegoScreen({super.key, this.partidaGuardada});

  @override
  State<JuegoScreen> createState() => _JuegoScreenState();
}

/// Estado de [JuegoScreen].
/// Implementa [WidgetsBindingObserver] para escuchar eventos del ciclo de vida
/// de la aplicación (como pasar a segundo plano) y autoguardar la partida.
class _JuegoScreenState extends State<JuegoScreen> with WidgetsBindingObserver {
  // Motor de reglas y estado matemático del tablero 4x4
  late GameLogic _logic;

  // DAOs para persistir la partida en curso y el historial de partidas terminadas
  final _guardadaDao = PartidaGuardadaDao();
  final _partidaDao = PartidaDao();

  // Futuro que resolverá el servicio de preferencias para leer el usuario activo
  final _prefs = PreferenciasService.crear();

  // Marca temporal del inicio de la sesión de juego para calcular la duración
  DateTime _inicioPartida = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Registramos esta pantalla como observadora del ciclo de vida de Flutter
    WidgetsBinding.instance.addObserver(this);

    // Si recibimos una partida guardada por argumentos de ruta, restauramos su estado;
    // de lo contrario, inicializamos un tablero nuevo con 2 fichas aleatorias.
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
    // Eliminamos el observador del ciclo de vida al destruir la pantalla para evitar fugas de memoria
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Se ejecuta automáticamente cuando cambia el estado de la app en el sistema operativo.
  /// Si el usuario minimiza la app o bloquea el móvil (`paused`), guarda el progreso.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _guardarPartida();
    }
  }

  /// Empaqueta el estado actual del tablero y lo persiste en la tabla `partida_guardada`.
  Future<void> _guardarPartida() async {
    final pGuardada = PartidaGuardada(
      tablero: _logic.tablero,
      puntuacion: _logic.puntuacion,
      movimientos: _logic.movimientos,
      segundosTranscurridos: DateTime.now().difference(_inicioPartida).inSeconds,
    );
    await _guardadaDao.guardar(pGuardada);
  }

  /// Gestiona el fin de partida (Game Over): guarda el resultado en el historial,
  /// borra la partida en curso y muestra el diálogo con el resumen final.
  void _mostrarFinDePartida() async {
    final prefs = await _prefs;
    final usuario = prefs.leerUltimoJugador() ?? 'Invitado';

    // Construimos el registro histórico de la partida finalizada
    final pFinal = Partida(
      usuario: usuario,
      puntuacion: _logic.puntuacion,
      fichaMaxima: _logic.fichaMaxima,
      movimientos: _logic.movimientos,
      duracionSegundos: DateTime.now().difference(_inicioPartida).inSeconds,
      fecha: DateTime.now(),
    );

    // Guarda en `partidas` y limpia `partida_guardada` en una transacción/operación atómica
    await _partidaDao.finalizarPartida(pFinal);

    if (!mounted) return;

    // Diálogo modal no descartable (`barrierDismissible: false`) con opciones post-partida
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('¡Fin del juego!'),
        content: Text('Puntuación: ${_logic.puntuacion}\nFicha máxima: ${_logic.fichaMaxima}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              Navigator.pop(context); // Vuelve a la pantalla de inicio
            },
            child: const Text('Volver al inicio'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              // Reinicia el tablero y el cronómetro para jugar otra partida al instante
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

  /// Ejecuta un movimiento en la dirección indicada (por gesto táctil o botón),
  /// actualiza la interfaz y comprueba si quedan movimientos posibles.
  void _mover(Direccion dir) {
    setState(() {
      _logic.mover(dir);
    });
    // Si el tablero está bloqueado sin fusiones posibles, dispara el fin del juego
    if (!_logic.hayMovimientosPosibles()) {
      _mostrarFinDePartida();
    }
  }

  /// Intercepta el intento de abandonar la pantalla para preguntar al usuario
  /// si desea conservar o descartar su progreso actual.
  Future<void> _onWillPop() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir de la partida?'),
        content: const Text('Puedes guardar tu progreso para continuar después.'),
        actions: [
          // Opción 1: Cierra el diálogo y continúa jugando
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          // Opción 2: Elimina cualquier guardado previo en SQLite y sale al menú
          TextButton(
            onPressed: () async {
              await _guardadaDao.borrar();
              if (context.mounted) {
                Navigator.pop(context); // Cierra diálogo
                Navigator.pop(context); // Sale de JuegoScreen
              }
            },
            child: const Text('Salir sin guardar', style: TextStyle(color: Colors.red)),
          ),
          // Opción 3: Guarda el estado actual en SQLite y sale al menú
          ElevatedButton(
            onPressed: () async {
              await _guardarPartida();
              if (context.mounted) {
                Navigator.pop(context); // Cierra diálogo
                Navigator.pop(context); // Sale de JuegoScreen
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
    // `PopScope` con `canPop: false` bloquea el cierre directo de la pantalla
    // para forzar la ejecución de `_onWillPop` al pulsar atrás.
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
            // Botón superior para reiniciar la partida en curso desde cero
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
              // ─────────── MARCADORES SUPERIORES (PUNTOS Y MOVIMIENTOS) ───────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gesto de doble toque sobre la puntuación para consultar el tiempo transcurrido
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

              // ─────────── TABLERO INTERACTIVO (GESTOS SWIPE) ───────────
              BoardWidget(tablero: _logic.tablero, onSwipe: _mover),

              // ─────────── CONTROLES DIRECCIONALES ALTERNATIVOS (ACCESIBILIDAD) ───────────
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