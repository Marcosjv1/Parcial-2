import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../widgets/app_drawer.dart';
import '../widgets/entry_card.dart';

/// Pantalla principal: lista de entradas del diario.
///
/// Estructura: Scaffold + AppBar + Drawer + FloatingActionButton.
/// Los datos se cargan de SQLite de forma asíncrona con [FutureBuilder].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  /// Se recibe la abstracción, no SQLite directamente (DIP).
  final DiaryRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<DiaryEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = widget.repository.getAll();
  }

  /// Vuelve a consultar la base de datos y redibuja la lista.
  Future<void> _reload() async {
    final future = widget.repository.getAll();
    setState(() => _entriesFuture = future);
    try {
      await future;
    } catch (_) {
      // El error ya lo muestra el FutureBuilder; aquí sólo evitamos que
      // el RefreshIndicator reciba una excepción no controlada.
    }
  }

  Future<void> _openNewEntry() async {
    final created = await Navigator.pushNamed(context, AppRoutes.newEntry);
    if (created == true && mounted) {
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrada guardada en tu bitácora ✔')),
      );
    }
  }

  Future<void> _openDetail(DiaryEntry entry) async {
    final deleted = await Navigator.pushNamed(
      context,
      AppRoutes.detail,
      arguments: entry,
    );
    if (deleted == true && mounted) {
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrada eliminada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Bitácora'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      drawer: AppDrawer(
        currentRoute: AppRoutes.home,
        onNewEntry: _openNewEntry,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewEntry,
        icon: const Icon(Icons.add),
        label: const Text('Nueva entrada'),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<DiaryEntry>>(
          future: _entriesFuture,
          builder: (context, snapshot) {
            // 1) Cargando
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            // 2) Error (p. ej. StorageException del repositorio)
            if (snapshot.hasError) {
              return _MessageView(
                icon: Icons.error_outline,
                title: 'No se pudo cargar tu diario',
                message: snapshot.error.toString(),
                actionLabel: 'Reintentar',
                onAction: _reload,
              );
            }
            // 3) Sin datos
            final entries = snapshot.data ?? const <DiaryEntry>[];
            if (entries.isEmpty) {
              return _MessageView(
                icon: Icons.auto_stories_outlined,
                title: 'Tu bitácora está vacía',
                message: 'Toca "Nueva entrada" para escribir, dictar o '
                    'fotografiar lo que pasó hoy.',
                actionLabel: 'Escribir mi primera entrada',
                onAction: _openNewEntry,
              );
            }
            // 4) Lista de entradas
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 96),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return EntryCard(
                  entry: entry,
                  onTap: () => _openDetail(entry),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Vista reutilizable para estados vacíos o de error.
/// Es desplazable para que funcione el "jalar para recargar".
class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        Icon(icon, size: 72, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center, style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: textTheme.bodyMedium),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.tonal(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ),
      ],
    );
  }
}
