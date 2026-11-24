import 'dart:math';
import 'direccion.dart';

/// Clase que encapsula toda la lógica y reglas del juego 2048.
/// Gestiona el estado del tablero, los movimientos, fusiones y puntuación.
class GameLogic {
  // Representación unidimensional del tablero 4x4 (16 celdas en total; 0 = vacía)
  late List<int> tablero;
  
  // Puntuación acumulada en la partida actual
  int puntuacion = 0;
  
  // Contador de movimientos válidos realizados por el jugador
  int movimientos = 0;
  
  // Dimensión del tablero cuadrado (4 filas x 4 columnas)
  final int tamano = 4;

  /// Constructor principal. Permite restaurar una partida guardada si se pasa
  /// un [tableroInicial] válido de 16 posiciones, o iniciar una partida nueva desde cero.
  GameLogic({List<int>? tableroInicial, int puntuacionInicial = 0, int movimientosInicial = 0}) {
    puntuacion = puntuacionInicial;
    movimientos = movimientosInicial;

    if (tableroInicial != null && tableroInicial.length == 16) {
      // Crea una copia de la lista recibida para evitar modificar la original por referencia
      tablero = List<int>.from(tableroInicial);
    } else {
      // Inicializa el tablero vacío (lleno de ceros) y genera las 2 fichas iniciales
      tablero = List<int>.filled(tamano * tamano, 0);
      anadirFichaAleatoria();
      anadirFichaAleatoria();
    }
  }

  /// Getter que devuelve el valor de la ficha más alta presente en el tablero.
  int get fichaMaxima => tablero.fold(0, (max, v) => v > max ? v : max);

  /// Ejecuta un movimiento en la [dir] indicada (arriba, abajo, izquierda, derecha).
  /// Devuelve `true` si el tablero sufrió algún cambio, o `false` si fue un movimiento inválido.
  bool mover(Direccion dir) {
    // Guardamos una instantánea del tablero antes de mover para comprobar si hubo cambios
    final antes = List<int>.from(tablero);
    
    // Procesamos cada fila o columna de forma independiente según la dirección
    for (int i = 0; i < tamano; i++) {
      final linea = _extraerLinea(dir, i);
      final procesada = _deslizarYFusionar(linea);
      _insertarLinea(dir, i, procesada);
    }
    
    // Si alguna ficha se desplazó o fusionó, generamos una nueva ficha e incrementamos turnos
    final huboCambio = !_listasIguales(antes, tablero);
    if (huboCambio) {
      anadirFichaAleatoria();
      movimientos++;
    }
    return huboCambio;
  }

  /// Coloca una nueva ficha en una casilla vacía elegida al azar.
  /// Sigue la regla clásica de 2048: 90% de probabilidad de generar un `2` y 10% un `4`.
  void anadirFichaAleatoria() {
    // Recopilamos los índices de todas las celdas que actualmente valen 0
    final vacios = <int>[for (int i = 0; i < tablero.length; i++) if (tablero[i] == 0) i];
    if (vacios.isEmpty) return;
    
    final random = Random();
    final pos = vacios[random.nextInt(vacios.length)];
    tablero[pos] = random.nextDouble() < 0.9 ? 2 : 4;
  }

  /// Comprueba si el jugador aún puede realizar algún movimiento (condición de Game Over).
  /// Devuelve `true` si quedan huecos libres o fichas adyacentes iguales que puedan fusionarse.
  bool hayMovimientosPosibles() {
    // Si existe al menos un cero, siempre se puede mover
    if (tablero.contains(0)) return true;
    
    // Recorremos el tablero comprobando parejas iguales hacia la derecha y hacia abajo
    for (int i = 0; i < tamano; i++) {
      for (int j = 0; j < tamano; j++) {
        final v = tablero[i * tamano + j];
        // Comprobar vecino derecho
        if (j < tamano - 1 && tablero[i * tamano + j + 1] == v) return true;
        // Comprobar vecino inferior
        if (i < tamano - 1 && tablero[(i + 1) * tamano + j] == v) return true;
      }
    }
    return false;
  }

  /// Extrae una fila o columna del tablero unidimensional orientándola siempre
  /// de izquierda a derecha según la dirección del movimiento para unificar el algoritmo.
  List<int> _extraerLinea(Direccion dir, int index) {
    final linea = <int>[];
    for (int i = 0; i < tamano; i++) {
      switch (dir) {
        case Direccion.izquierda: linea.add(tablero[index * tamano + i]);
        case Direccion.derecha:   linea.add(tablero[index * tamano + (tamano - 1 - i)]);
        case Direccion.arriba:    linea.add(tablero[i * tamano + index]);
        case Direccion.abajo:     linea.add(tablero[(tamano - 1 - i) * tamano + index]);
      }
    }
    return linea;
  }

  /// Vuelve a escribir una línea ya procesada en su posición y orientación original
  /// dentro del tablero unidimensional.
  void _insertarLinea(Direccion dir, int index, List<int> linea) {
    for (int i = 0; i < tamano; i++) {
      switch (dir) {
        case Direccion.izquierda: tablero[index * tamano + i] = linea[i];
        case Direccion.derecha:   tablero[index * tamano + (tamano - 1 - i)] = linea[i];
        case Direccion.arriba:    tablero[i * tamano + index] = linea[i];
        case Direccion.abajo:     tablero[(tamano - 1 - i) * tamano + index] = linea[i];
      }
    }
  }

  /// Compacta una línea eliminando ceros, fusiona fichas adyacentes iguales
  /// (sumando los puntos obtenidos) y rellena los huecos restantes con ceros al final.
  List<int> _deslizarYFusionar(List<int> linea) {
    // 1. Filtramos los ceros para agrupar todas las fichas con valor hacia el inicio
    final noCeros = linea.where((v) => v != 0).toList();
    final fusionada = <int>[];
    
    // 2. Recorremos las fichas buscando parejas contiguas idénticas
    for (int i = 0; i < noCeros.length; i++) {
      if (i + 1 < noCeros.length && noCeros[i] == noCeros[i + 1]) {
        final suma = noCeros[i] * 2;
        fusionada.add(suma);
        puntuacion += suma; // Sumamos el valor de la nueva ficha al marcador
        i++; // Saltamos la siguiente ficha porque ya ha sido absorbida en esta fusión
      } else {
        fusionada.add(noCeros[i]);
      }
    }
    
    // 3. Rellenamos con ceros a la derecha hasta completar el tamaño de la fila/columna
    while (fusionada.length < tamano) { fusionada.add(0); }
