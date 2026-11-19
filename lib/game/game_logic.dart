import 'dart:math';
import 'direccion.dart';

class GameLogic {
  late List<int> tablero;
  int puntuacion = 0;
  int movimientos = 0;
  final int tamano = 4;

  GameLogic({List<int>? tableroInicial, int puntuacionInicial = 0, int movimientosInicial = 0}) {
    puntuacion = puntuacionInicial;
    movimientos = movimientosInicial;

    if (tableroInicial != null && tableroInicial.length == 16) {
      tablero = List<int>.from(tableroInicial);
    } else {
      tablero = List<int>.filled(tamano * tamano, 0);
      anadirFichaAleatoria();
      anadirFichaAleatoria();
    }
  }

  int get fichaMaxima => tablero.fold(0, (max, v) => v > max ? v : max);

  bool mover(Direccion dir) {
    final antes = List<int>.from(tablero);
    for (int i = 0; i < tamano; i++) {
      final linea = _extraerLinea(dir, i);
      final procesada = _deslizarYFusionar(linea);
      _insertarLinea(dir, i, procesada);
    }
    final huboCambio = !_listasIguales(antes, tablero);
    if (huboCambio) {
      anadirFichaAleatoria();
      movimientos++;
    }
    return huboCambio;
  }

  void anadirFichaAleatoria() {
    final vacios = <int>[for (int i = 0; i < tablero.length; i++) if (tablero[i] == 0) i];
    if (vacios.isEmpty) return;
    final random = Random();
    final pos = vacios[random.nextInt(vacios.length)];
    tablero[pos] = random.nextDouble() < 0.9 ? 2 : 4;
  }

  bool hayMovimientosPosibles() {
    if (tablero.contains(0)) return true;
    for (int i = 0; i < tamano; i++) {
      for (int j = 0; j < tamano; j++) {
        final v = tablero[i * tamano + j];
        if (j < tamano - 1 && tablero[i * tamano + j + 1] == v) return true;
        if (i < tamano - 1 && tablero[(i + 1) * tamano + j] == v) return true;
      }
    }
    return false;
  }

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

  List<int> _deslizarYFusionar(List<int> linea) {
    final noCeros = linea.where((v) => v != 0).toList();
    final fusionada = <int>[];
    for (int i = 0; i < noCeros.length; i++) {
      if (i + 1 < noCeros.length && noCeros[i] == noCeros[i + 1]) {
        final suma = noCeros[i] * 2;
        fusionada.add(suma);
        puntuacion += suma;
        i++;
      } else {
        fusionada.add(noCeros[i]);
      }
    }
    while (fusionada.length < tamano) { fusionada.add(0); }
    return fusionada;
  }

  bool _listasIguales(List<int> a, List<int> b) {
    for (int i = 0; i < a.length; i++) { if (a[i] != b[i]) return false; }
    return true;
  }
}