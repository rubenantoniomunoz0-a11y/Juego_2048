import 'package:flutter/material.dart';
import 'models/partida_guardada.dart';
import 'screens/ajustes_screen.dart';
import 'screens/detalle_screen.dart';
import 'screens/historial_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/juego_screen.dart';
import 'screens/login_screen.dart';
import 'screens/ranking_screen.dart';

/// Clase centralizada que define todas las rutas nombradas de la aplicación
/// y gestiona la navegación dinámica mediante [onGenerateRoute].
///
/// Responsabilidades principales:
/// 1. Proveer constantes estáticas con los nombres de las rutas para evitar
///    errores tipográficos al navegar desde las distintas pantallas.
/// 2. Validar y extraer los argumentos (`settings.arguments`) de forma segura
///    antes de instanciar pantallas que requieren parámetros (como [JuegoScreen]
///    o [DetalleScreen]).
class Routes {
  
  // CONSTANTES DE RUTAS NOMBRADAS

  static const String login = '/login';         // Pantalla de autenticación y registro
  static const String inicio = '/';             // Menú principal (ruta raíz por defecto)
  static const String juego = '/juego';         // Tablero principal del 2048
  static const String historial = '/historial'; // Listado cronológico de partidas jugadas
  static const String ranking = '/ranking';     // Clasificación global por mejores puntuaciones
  static const String ajustes = '/ajustes';     // Configuración de tema, datos y cierre de sesión
  static const String detalle = '/detalle';     // Vista detallada de una partida concreta

  /// Generador central de rutas invocado automáticamente por `MaterialApp`
  /// cada vez que se llama a `Navigator.pushNamed` o `Navigator.pushReplacementNamed`.
  ///
  /// Inspecciona `settings.name` para decidir qué pantalla construir y comprueba
  /// el tipo de `settings.arguments` para evitar excepciones en tiempo de ejecución.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Pantalla de inicio de sesión / registro (no requiere argumentos)
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      // Pantalla de juego: admite recibir opcionalmente una [PartidaGuardada]
      // si el usuario pulsa "Continuar partida", o `null` si inicia una nueva.
      case juego:
        final guardada = settings.arguments is PartidaGuardada
            ? settings.arguments as PartidaGuardada
            : null;
        return MaterialPageRoute(
          builder: (_) => JuegoScreen(partidaGuardada: guardada),
          settings: settings,
        );

      // Pantalla con el historial completo de partidas finalizadas
      case historial:
        return MaterialPageRoute(
          builder: (_) => const HistorialScreen(),
          settings: settings,
        );

      // Pantalla de mejores puntuaciones (Top ranking)
      case ranking:
        return MaterialPageRoute(
          builder: (_) => const RankingScreen(),
          settings: settings,
        );

      // Pantalla de preferencias y ajustes de cuenta
      case ajustes:
        return MaterialPageRoute(
          builder: (_) => const AjustesScreen(),
          settings: settings,
        );

      // Pantalla de detalle: exige recibir un `int` correspondiente al ID de la partida.
      // Si el argumento falta o no es un entero válido, redirige de forma segura al inicio.
      case detalle:
        final partidaId = settings.arguments;
        if (partidaId is! int) {
          return MaterialPageRoute(
            builder: (_) => const InicioScreen(),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => DetalleScreen(partidaId: partidaId),
          settings: settings,
        );

      // Ruta raíz ('/') y fallback de seguridad para cualquier ruta desconocida
      case inicio:
      default:
        return MaterialPageRoute(
          builder: (_) => const InicioScreen(),
          settings: settings,
        );
    }
  }
}
