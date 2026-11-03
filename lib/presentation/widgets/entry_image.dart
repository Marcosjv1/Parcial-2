import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/diary_entry.dart';

/// Muestra la foto de una entrada o un marcador de posición si no tiene.
///
/// Se usa dentro de un [Hero] tanto en la lista como en el detalle, por eso
/// ambos lados usan el mismo widget y la animación se ve continua.
class EntryImage extends StatelessWidget {
  const EntryImage({
    super.key,
    required this.imagePath,
    this.borderRadius = BorderRadius.zero,
    this.iconSize = 32,
  });

  final String? imagePath;
  final BorderRadius borderRadius;
  final double iconSize;

  /// Etiqueta única del Hero para cada entrada.
  static String heroTag(DiaryEntry entry) => 'entry-image-${entry.id}';

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    return ClipRRect(
      borderRadius: borderRadius,
      child: (path == null || path.isEmpty)
          ? _Placeholder(iconSize: iconSize)
          : Image.file(
              File(path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              // Si el archivo se borró o está dañado, no truena la app.
              errorBuilder: (_, __, ___) =>
                  _Placeholder(iconSize: iconSize, broken: true),
            ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.iconSize, this.broken = false});

  final double iconSize;
  final bool broken;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.secondaryContainer,
      alignment: Alignment.center,
      child: Icon(
        broken ? Icons.broken_image_outlined : Icons.auto_stories_outlined,
        size: iconSize,
        color: scheme.onSecondaryContainer,
      ),
    );
  }
}
