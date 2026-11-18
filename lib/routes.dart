import 'package:flutter/material.dart';
import 'screens/inicio_screen.dart';
import 'screens/juego_screen.dart';
import 'screens/historial_screen.dart';
import 'screens/detalle_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/ajustes_screen.dart';
import 'models/partida_guardada.dart';

/// Sistema de rutas centralizado.
/// Requisito 4.1.1: Un único archivo para definir las rutas de la app.
class Routes {
  static const String inicio = '/';
  static const String juego = '/juego';
  static const String historial = '/historial';
  static const String detalle = '/detalle';
  static const String ranking = '/ranking';
  static const String ajustes = '/ajustes';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case inicio:
        return MaterialPageRoute(
          builder: (_) => const InicioScreen(),
          settings: settings,
        );

      case juego:
      // Recibimos la PartidaGuardada (o null si es una nueva partida)
        final partida = settings.arguments as PartidaGuardada?;
        return MaterialPageRoute(
          builder: (_) => JuegoScreen(partidaGuardada: partida),
          settings: settings,
        );

      case historial:
        return MaterialPageRoute(
          builder: (_) => const HistorialScreen(),
          settings: settings,
        );

      case detalle:
      // Pasamos solo el ID a la pantalla de detalle.
        final id = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => DetalleScreen(partidaId: id),
          settings: settings,
        );

      case ranking:
        return MaterialPageRoute(
          builder: (_) => const RankingScreen(),
          settings: settings,
        );

      case ajustes:
        return MaterialPageRoute(
          builder: (_) => const AjustesScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Ruta desconocida: ${settings.name}')),
          ),
        );
    }
  }
}