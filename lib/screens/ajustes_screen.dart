import 'package:flutter/material.dart';
import '../data/partida_dao.dart';
import '../routes.dart';
import '../services/preferencias_service.dart';
import '../theme/app_theme.dart';
import '../widgets/confirm_dialog.dart';
import 'app.dart'; // Importa las extensiones de BuildContext (themeNotifier y prefsService)

/// Pantalla de configuración general de la aplicación (`AjustesScreen`).
///
/// Responsabilidades principales:
/// 1. Permitir al usuario alternar entre tema claro, oscuro o automático del sistema.
/// 2. Eliminar de forma permanente el historial de partidas guardadas en SQLite.
/// 3. Cerrar la sesión del jugador activo limpiando las preferencias locales y
///    reiniciando la pila de navegación hacia la pantalla de login.
class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  // Instancia del DAO (Data Access Object) que encapsula las consultas SQL
  // sobre la tabla 'partidas'. Se declara a nivel de estado para reutilizarla.
  final PartidaDao _partidaDao = PartidaDao();

  /// Gestiona el borrado completo del historial de partidas en la base de datos.
  ///
  /// Flujo de ejecución:
  /// 1. Muestra un diálogo modal de confirmación ([ConfirmDialog]) para evitar
  ///    eliminaciones accidentales.
  /// 2. Si el usuario confirma (`confirmado == true`), llama a `eliminarTodo()` en SQLite.
  /// 3. Muestra una notificación visual ([SnackBar]) informando del éxito o del error.
  Future<void> _borrarHistorial() async {
    // `showDialog<bool>` detiene la ejecución de este método hasta que el usuario
    // pulse "Cancelar" (false/null) o "Borrar todo" (true).
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmDialog(
        titulo: 'Borrar historial',
        mensaje: '¿Estás seguro de que quieres borrar TODAS las partidas? Esta acción no se puede deshacer.',
        textoAceptar: 'Borrar todo',
      ),
    );

    // Solo procedemos si el usuario aceptó explícitamente la acción destructiva
    if (confirmado == true) {
      try {
        // Ejecutamos el DELETE en la base de datos local de forma asíncrona
        await _partidaDao.eliminarTodo();

        // Verificamos `mounted` tras el `await`: si el usuario cerró la pantalla
        // mientras se borraban los datos, `context` ya no sería válido y lanzaría error.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Historial borrado correctamente')),
          );
        }
      } catch (e) {
        // Capturamos cualquier fallo de SQLite y notificamos al usuario sin cerrar la app
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al borrar: $e')),
          );
        }
      }
    }
  }

  /// Gestiona el cierre de sesión del usuario actual.
  ///
  /// Flujo de ejecución:
  /// 1. Solicita confirmación mediante [ConfirmDialog].
  /// 2. Limpia el nombre del último jugador en `SharedPreferences` para que la app
  ///    no vuelva a iniciar sesión automáticamente al abrirse.
  /// 3. Redirige a [Routes.login] destruyendo todo el historial de navegación previo.
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
      // Obtenemos la instancia del servicio de preferencias locales
      final prefs = await PreferenciasService.crear();
      
      // Sobrescribimos el jugador guardado con una cadena vacía para invalidar la sesión
      await prefs.guardarUltimoJugador('');

      if (mounted) {
        // `pushNamedAndRemoveUntil` navega al Login y elimina todas las rutas anteriores
        // de la pila (gracias al predicado `(route) => false`). Esto impide que el
        // usuario pueda volver atrás a pantallas privadas usando el botón de retroceso.
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
    // Leemos el valor actual del tema desde el ValueNotifier global expuesto a través
    // de la extensión de BuildContext definida en `app.dart`. Si fuera nulo, usa `system`.
    final modoActual = context.themeNotifier?.value ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      // Usamos `ListView` en lugar de `Column` para permitir scroll vertical si la
      // pantalla del dispositivo es pequeña o si el usuario aumenta el tamaño de fuente.
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.espaciadoM),
        children: [
          // ─────────────────────────────────────────────────────────────────
          // SECCIÓN 1: APARIENCIA (Selección de tema claro / oscuro / sistema)
          // ─────────────────────────────────────────────────────────────────
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

                  // Widget de Material 3 que permite elegir una única opción entre varias.
                  // Sincroniza tanto la UI reactiva en memoria como la persistencia en disco.
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
                    // `selected` recibe un Set con el modo activo para marcar el botón correspondiente
                    selected: {modoActual},
                    // Al pulsar un segmento (`sel` contiene el nuevo ThemeMode elegido):
                    onSelectionChanged: (sel) {
                      // 1. Notifica a toda la app para repintar los colores en tiempo real
                      context.themeNotifier?.value = sel.first;
                      // 2. Guarda la elección en SharedPreferences para futuros reinicios
                      context.prefsService?.guardarModoTema(sel.first);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.espaciadoL),

       
          // SECCIÓN 2: DATOS Y CUENTA (Acciones sensibles de borrado y salida)
 
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

                  // Botón relleno de alto énfasis en rojo para advertir que borra datos
                  ElevatedButton.icon(
                    onPressed: _borrarHistorial,
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    label: const Text('Borrar todo el historial'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      // Ocupa todo el ancho disponible de la tarjeta con altura táct
