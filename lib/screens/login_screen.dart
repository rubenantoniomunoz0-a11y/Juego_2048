import 'package:flutter/material.dart';
import '../data/usuario_dao.dart';
import '../services/preferencias_service.dart'; // <-- IMPORT AÑADIDO
import '../theme/app_theme.dart';
import '../routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuarioDao = UsuarioDao();
  final _formKey = GlobalKey<FormState>();

  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _emailController = TextEditingController();

  bool _esLogin = true;
  bool _cargando = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      if (_esLogin) {
        // INICIAR SESIÓN
        final user = await _usuarioDao.login(
          usuario: _userController.text.trim(),
          contrasena: _passController.text,
        );

        if (user != null) {
          // GUARDAMOS EL NOMBRE DEL JUGADOR EN PREFERENCIAS
          final prefs = await PreferenciasService.crear();
          await prefs.guardarUltimoJugador(user.usuario);

          if (mounted) {
            Navigator.pushReplacementNamed(context, Routes.inicio);
          }
        } else {
          _mostrarError('Usuario o contraseña incorrectos');
        }
      } else {
        // REGISTRARSE
        await _usuarioDao.registrar(
          usuario: _userController.text.trim(),
          email: _emailController.text.trim(),
          contrasena: _passController.text,
        );

        _mostrarExito('¡Usuario registrado! Ahora puedes iniciar sesión.');
        setState(() => _esLogin = true);
      }
    } catch (e) {
      _mostrarError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  void _mostrarExito(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.espaciadoL),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.grid_on, size: 80, color: Colors.orange),
                const SizedBox(height: AppTheme.espaciadoM),
                Text(
                  _esLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppTheme.espaciadoXL),

                TextFormField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: AppTheme.espaciadoM),

                if (!_esLogin) ...[
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (v) {
                      if (v!.isEmpty) return 'Campo requerido';
                      if (!UsuarioDao.emailValido(v)) return 'Email no válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.espaciadoM),
                ],

                TextFormField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (v) => v!.length < 4 ? 'Mínimo 4 caracteres' : null,
                ),
                const SizedBox(height: AppTheme.espaciadoXL),

                if (_cargando)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(_esLogin ? 'ENTRAR' : 'REGISTRARSE'),
                  ),

                const SizedBox(height: AppTheme.espaciadoM),

                TextButton(
                  onPressed: () => setState(() => _esLogin = !_esLogin),
                  child: Text(_esLogin
                      ? '¿No tienes cuenta? Regístrate'
                      : '¿Ya tienes cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}