// Aquí he puesto la lógica del juego separada de la interfaz.
// Lo hice así porque en clase nos dijeron que es mejor no mezclar la lógica con los widgets.
import 'dart:math';
import 'direccion.dart';

class GameLogic {
  // El tablero es una lista de 16 enteros (4x4). Los 0 son huecos vacíos.
  List<int> tablero;
  int puntuacion = 0;
  int movimientos = 0;
  final int tamano = 4; // El juego siempre es 4x4

  // Constructor: si me pasan un tablero lo uso (por si quiero cargar una partida guardada),
  // si no, creo uno nuevo y meto un par de fichas al azar para empezar.
  GameLogic({List<int>? tableroInicial}) {
    if (tableroInicial != null && tableroInicial.length == 16) {
      tablero = List.from(tableroInicial);
    } else {
      tablero = List.filled(tamano * tamano, 0); // Relleno todo de 0
      añadirFichaAleatoria();
      añadirFichaAleatoria(); // Empiezo con 2 fichas
    }
  }

  // Método para sacar la ficha más alta y así mostrarla o guardarla en la BD.
  int get fichaMaxima => tablero.fold(0, (max, v) => v > max ? v : max);

  // El método más importante: mover las fichas.
  bool mover(Direccion dir) {
    // Guardo cómo estaba el tablero antes para saber si ha cambiado algo
    final antes = List.from(tablero);

    // Recorro las 4 filas o columnas (según la dirección) y las proceso
    for (int i = 0; i < tamano; i++) {
      final linea = _extraerLinea(dir, i); // Saco los 4 números de esa línea
      final procesada = _deslizarYFusionar(linea); // Los deslizo y fusiono
      _insertarLinea(dir, i, procesada); // Los vuelvo a meter en el tablero
    }

    // Si el tablero ha cambiado, significa que el movimiento fue válido
    final huboCambio = !_listasIguales(antes, tablero);
    if (huboCambio) {
      añadirFichaAleatoria(); // Añado una nueva ficha (2 o 4)
      movimientos++; // Sumo un movimiento
    }
    return huboCambio; // Devuelvo true si el jugador se movió
  }

  // Esta función añade un 2 (90% de las veces) o un 4 (10%) en un hueco vacío
  void añadirFichaAleatoria() {
    // Busco todos los índices que están a 0 (vacíos)
    final vacios = [for (int i = 0; i < tablero.length; i++) if (tablero[i] == 0) i];
    if (vacios.isEmpty) return; // Si no hay huecos, no hago nada

    final random = Random();
    final pos = vacios[random.nextInt(vacios.length)]; // Elijo uno al azar
    tablero[pos] = random.nextDouble() < 0.9 ? 2 : 4; // 90% para el 2
  }

  // Función para saber si el jugador ha perdido (no hay más movimientos).
  bool hayMovimientosPosibles() {
    if (tablero.contains(0)) return true; // Si hay huecos, se puede jugar

    // Si el tablero está lleno, compruebo si hay dos fichas iguales juntas
    for (int i = 0; i < tamano; i++) {
      for (int j = 0; j < tamano; j++) {
        final v = tablero[i * tamano + j];
        // Miro si la de la derecha es igual
        if (j < tamano - 1 && tablero[i * tamano + j + 1] == v) return true;
        // Miro si la de abajo es igual
        if (i < tamano - 1 && tablero[(i + 1) * tamano + j] == v) return true;
      }
    }
    return false; // Si llego aquí, no hay movimientos y he perdido
  }

  // --- Funciones privadas de ayuda ---

  // Extrae una línea del tablero (fila o columna) según la dirección.
  // Si muevo a la izquierda, saco la fila normal. Si muevo a la derecha, la saco al revés
  // para que al fusionar sea más fácil.
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

  // Vuelve a meter la línea procesada en el tablero (al revés de como la saqué).
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

  // Aquí está el truco del 2048: quitar los 0, juntar los iguales y volver a rellenar con 0.
  List<int> _deslizarYFusionar(List<int> linea) {
    final noCeros = linea.where((v) => v != 0).toList(); // Quito los huecos
    final fusionada = <int>[];

    for (int i = 0; i < noCeros.length; i++) {
      // Si la siguiente es igual, las junto y sumo los puntos
      if (i + 1 < noCeros.length && noCeros[i] == noCeros[i + 1]) {
        final suma = noCeros[i] * 2;
        fusionada.add(suma);
        puntuacion += suma; // Sumo puntos a la puntuación global
        i++; // Salto la siguiente porque ya la he usado
      } else {
        fusionada.add(noCeros[i]); // Si no es igual, la dejo como está
      }
    }

    // Relleno con 0 al final hasta que vuelva a tener 4 elementos
    while (fusionada.length < tamano) { fusionada.add(0); }
    return fusionada;
  }

  // Compara dos listas para ver si son iguales.
  bool _listasIguales(List<int> a, List<int> b) {
    for (int i = 0; i < a.length; i++) { if (a[i] != b[i]) return false; }
    return true;
  }
}