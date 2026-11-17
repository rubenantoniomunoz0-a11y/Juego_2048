import 'package:flutter/material.dart';
import 'screens/app.dart';
import 'services/preferencias_service.dart';

/// Punto de entrada de la aplicación 2048.
///
/// Requisito B.2.3 del enunciado: las preferencias (tema, etc.) se cargan
/// ANTES de runApp() para evitar el parpadeo del tema incorrecto al arrancar.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await PreferenciasService.crear();

  runApp(App(prefs: prefs));
}