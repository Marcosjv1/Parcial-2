import 'package:flutter/material.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../../services/maps_launcher_service.dart';
import '../../services/media_service.dart';
import '../widgets/entry_image.dart';
import '../widgets/location_map.dart';

/// Vista de detalle de una entrada del diario.
///
/// - La foto llega con animación [Hero] desde la lista.
/// - Muestra un mapa interactivo con la ubicación guardada.
/// - Botón para abrir las coordenadas en Google Maps.
/// - Permite eliminar la entrada (devuelve `true` a la lista al hacerlo).
class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({
    super.key,
    required this.entry,
    required this.repository,
    required this.mediaService,
    required this.mapsLauncher,
  });

  final DiaryEntry entry;
  final DiaryRepository repository;
  final MediaService mediaService;
  final MapsLauncherService mapsLauncher;

  Future<void> _openInGoogleMaps(BuildContext context) async {
    final location = entry.location;
    if (location == null) return;
    try {
      await mapsLauncher.openInMaps(location);
    } on AppException catch (e) {
      if (!context.mounted) return;
      _showError(context, e.message);
    }
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('¿Eliminar esta entrada?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || entry.id == null) return;

    try {
      await repository.delete(entry.id!);
      if (entry.hasImage) await mediaService.deleteImage(entry.imagePath!);
      if (!context.mounted) return;
      Navigator.pop(context, true); // Avisamos a la lista que recargue.
    } on AppException catch (e) {
      if (!context.mounted) return;
      _showError(context, e.message);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final location = entry.location;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            actions: [
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmAndDelete(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: EntryImage.heroTag(entry),
                child: EntryImage(imagePath: entry.imagePath, iconSize: 96),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(entry.title, style: textTheme.headlineSmall),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.event, size: 16, color: scheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        DateFormatter.fullDateTime(entry.createdAt),
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Text(entry.content, style: textTheme.bodyLarge),
                const SizedBox(height: 32),
                Text('Ubicación', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                if (location != null) ...[
                  LocationMap(point: location),
                  const SizedBox(height: 8),
                  Text(
                    location.formatted,
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _openInGoogleMaps(context),
                    icon: const Icon(Icons.map),
                    label: const Text('Abrir en Google Maps'),
                  ),
                ] else
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.location_off, color: scheme.outline),
                      title: const Text('Sin ubicación registrada'),
                      subtitle: const Text(
                        'No se pudo obtener el GPS al guardar esta entrada.',
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
