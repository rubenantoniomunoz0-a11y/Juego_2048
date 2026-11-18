import 'package:flutter/material.dart';
import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/async_data_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/partida_list_item.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final PartidaDao _dao = PartidaDao();
  late Future<List<Partida>> _futurePartidas;

  // Variables para los filtros (Requisito A.3)
  String? _filtroUsuario;
  int? _filtroFicha;

  @override
  void initState() {
    super.initState();
    _cargarPartidas();
  }

  // Carga las partidas aplicando los filtros
  void _cargarPartidas() {
    setState(() {
      _futurePartidas = _dao.filtrar(
        usuario: _filtroUsuario,
        fichaMinima: _filtroFicha,
      );
    });
  }

  // Elimina una partida y recarga la lista
  Future<void> _eliminarPartida(int id) async {
    try {
      await _dao.eliminar(id);
      _cargarPartidas(); // Refresca la lista
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partida eliminada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  // Muestra el diálogo de confirmación antes de borrar
  Future<bool?> _confirmarBorrado() {
    return showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmDialog(
        titulo: 'Eliminar partida',
        mensaje: '¿Estás seguro de que quieres eliminar esta partida del historial?',
        textoAceptar: 'Eliminar',
      ),
    );
  }

  // Menú de opciones al hacer LongPress
  void _mostrarMenuOpciones(Partida p) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Ver detalle'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, Routes.detalle, arguments: p.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(ctx);
                final confirmado = await _confirmarBorrado();
                if (confirmado == true && p.id != null) {
                  _eliminarPartida(p.id!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Partidas'),
        actions: [
          // Botón de filtro rápido
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                // Filtro de prueba: si no hay filtro, pone 1024; si lo hay, lo quita
                _filtroFicha = _filtroFicha == null ? 1024 : null;
              });
              _cargarPartidas();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Chip visual para indicar que hay un filtro activo
          if (_filtroFicha != null)
            Padding(
              padding: const EdgeInsets.all(AppTheme.espaciadoM),
              child: Chip(
                label: Text('Ficha >= $_filtroFicha'),
                onDeleted: () {
                  setState(() => _filtroFicha = null);
                  _cargarPartidas();
                },
              ),
            ),

          Expanded(
            // AsyncDataView gestiona el loading, error o los datos
            child: AsyncDataView<List<Partida>>(
              future: _futurePartidas,
              onRetry: _cargarPartidas,
              builder: (partidas) {
                if (partidas.isEmpty) {
                  return const EmptyStateView(
                    mensaje: 'No hay partidas jugadas aún',
                    icono: Icons.videogame_asset_off,
                  );
                }

                // RefreshIndicator para tirar hacia abajo y recargar
                return RefreshIndicator(
                  onRefresh: () async => _cargarPartidas(),
                  child: ListView.builder(
                    itemCount: partidas.length,
                    itemBuilder: (context, index) {
                      final p = partidas[index];

                      // Dismissible para borrar deslizando
                      return Dismissible(
                        key: Key('partida_${p.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppTheme.espaciadoL),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) => _confirmarBorrado(),
                        onDismissed: (_) {
                          if (p.id != null) _eliminarPartida(p.id!);
                        },
                        child: GestureDetector(
                          onLongPress: () => _mostrarMenuOpciones(p), // LongPress
                          child: PartidaListItem(
                            puntuacion: p.puntuacion,
                            fichaMaxima: p.fichaMaxima,
                            fecha: p.fecha.toLocal().toString().split(' ')[0],
                            onTap: () {
                              // Navegar al detalle pasando el ID
                              Navigator.pushNamed(context, Routes.detalle, arguments: p.id);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}