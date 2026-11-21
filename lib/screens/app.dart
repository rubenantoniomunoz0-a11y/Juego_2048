import 'package:flutter/material.dart';
import '../routes.dart'; // <--- AHORA ES ASÍ
import '../services/preferencias_service.dart';
import '../theme/app_theme.dart';

class App extends StatefulWidget {
  final PreferenciasService prefs;
  const App({super.key, required this.prefs});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final ValueNotifier<ThemeMode> _themeNotifier;

  @override
  void initState() {
    super.initState();
    _themeNotifier = ValueNotifier(widget.prefs.leerModoTema());
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (context, modo, _) {
        return MaterialApp(
          title: '2048',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: modo,
          onGenerateRoute: Routes.onGenerateRoute,
          initialRoute: Routes.login,
          builder: (context, child) => _ThemeScope(
            notifier: _themeNotifier,
            prefs: widget.prefs,
            child: child!,
          ),
        );
      },
    );
  }
}

class _ThemeScope extends InheritedWidget {
  final ValueNotifier<ThemeMode> notifier;
  final PreferenciasService prefs;
  const _ThemeScope({required this.notifier, required this.prefs, required super.child});

  static _ThemeScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ThemeScope>();

  @override
  bool updateShouldNotify(_ThemeScope oldWidget) =>
      notifier != oldWidget.notifier || prefs != oldWidget.prefs;
}

extension ThemeScopeX on BuildContext {
  ValueNotifier<ThemeMode>? get themeNotifier => _ThemeScope.of(this)?.notifier;
  PreferenciasService? get prefsService => _ThemeScope.of(this)?.prefs;
}