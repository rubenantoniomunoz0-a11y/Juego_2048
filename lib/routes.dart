import 'package:flutter/material.dart';
import 'models/partida_guardada.dart';
import 'screens/ajustes_screen.dart';
import 'screens/detalle_screen.dart';
import 'screens/historial_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/juego_screen.dart';
import 'screens/login_screen.dart'; // <--- IMPORT NUEVO
import 'screens/ranking_screen.dart';

class Routes {
  static const String login = '/login'; // <--- RUTA NUEVA
  static const String inicio = '/';
  static const String juego = '/juego';
  static const String historial = '/historial';
  static const String ranking = '/ranking';
  static const String ajustes = '/ajustes';
  static const String detalle = '/detalle';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen(), settings: settings);

      case juego:
        final guardada = settings.arguments is PartidaGuardada
            ? settings.arguments as PartidaGuardada
            : null;
        return MaterialPageRoute(
          builder: (_) => JuegoScreen(partidaGuardada: guardada),
          settings: settings,
        );
      case historial:
        return MaterialPageRoute(builder: (_) => const HistorialScreen(), settings: settings);
      case ranking:
        return MaterialPageRoute(builder: (_) => const RankingScreen(), settings: settings);
      case ajustes:
        return MaterialPageRoute(builder: (_) => const AjustesScreen(), settings: settings);
      case detalle:
        final partidaId = settings.arguments;
        if (partidaId is! int) {
          return MaterialPageRoute(builder: (_) => const InicioScreen(), settings: settings);
        }
        return MaterialPageRoute(
          builder: (_) => DetalleScreen(partidaId: partidaId),
          settings: settings,
        );
      case inicio:
      default:
        return MaterialPageRoute(builder: (_) => const InicioScreen(), settings: settings);
    }
  }
}