
import 'package:flutter/material.dart';
import '../data/partida_dao.dart';
import '../routes.dart';
import '../services/preferencias_service.dart';
import '../theme/app_theme.dart';
import '../widgets/confirm_dialog.dart';
import 'app.dart'; // Para acceder al themeNotifier

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final PartidaDao _partidaDao = PartidaDao();

  // Función para borrar todo el historial
  Future<void> _borrarHistorial() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmDialog(
        titulo: 'Borrar historial',
        mensaje: '¿Estás seguro de que quieres borrar TODAS las partidas? Esta acción no se puede deshacer.',
        textoAceptar: 'Borrar todo',
      ),
    );

    if (confirmado == true) {
      try {
        await _partidaDao.eliminarTodo();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Historial borrado correctamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al borrar: $e')),
          );
        }
      }
    }
  }

  // Función para cerrar sesión
  Future<void> _cerrarSesion() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmDialog(
        titulo: 'Cerrar Sesión',
        mensaje: '¿Estás seguro de que quieres salir de tu cuenta?',
        textoAceptar: 'Salir',
      ),
    );

    if (confirmado == true) {
      final prefs = await PreferenciasService.crear();
      // Limpiamos el nombre del jugador
      await prefs.guardarUltimoJugador('');

      if (mounted) {
        // Volvemos al Login borrando todo el historial de navegación
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.login,
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final modoActual = context.themeNotifier?.value ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.espaciadoM),
        children: [
          // ─────────── SECCIÓN: TEMA ───────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.espaciadoM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Apariencia', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppTheme.espaciadoM),
                  const Text('Selecciona el modo de tema:'),
                  const SizedBox(height: AppTheme.espaciadoM),

                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode),
                        label: Text('Claro'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto),
                        label: Text('Sistema'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode),
                        label: Text('Oscuro'),
                      ),
                    ],
                    selected: {modoActual},
                    onSelectionChanged: (sel) {
                      context.themeNotifier?.value = sel.first;
                      context.prefsService?.guardarModoTema(sel.first);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.espaciadoL),

          // ─────────── SECCIÓN: DATOS Y CUENTA ───────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.espaciadoM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Datos y Cuenta', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppTheme.espaciadoM),
                  const Text('Puedes borrar el historial de partidas o cerrar tu sesión actual.'),
                  const SizedBox(height: AppTheme.espaciadoM),

                  // Botón para borrar todo el historial
                  ElevatedButton.icon(
                    onPressed: _borrarHistorial,
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    label: const Text('Borrar todo el historial'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),

                  const SizedBox(height: AppTheme.espaciadoM),

                  // Botón para cerrar sesión
                  OutlinedButton.icon(
                    onPressed: _cerrarSesion,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



