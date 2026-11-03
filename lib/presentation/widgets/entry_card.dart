import 'package:flutter/material.dart';

import '../../core/utils/date_formatter.dart';
import '../../domain/entities/diary_entry.dart';
import 'entry_image.dart';

/// Tarjeta de una entrada en la lista principal.
class EntryCard extends StatelessWidget {
  const EntryCard({super.key, required this.entry, required this.onTap});

  final DiaryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 104,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen con Hero: "vuela" hacia la pantalla de detalle.
              SizedBox(
                width: 104,
                child: Hero(
                  tag: EntryImage.heroTag(entry),
                  child: EntryImage(imagePath: entry.imagePath),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.event, size: 14, color: scheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${DateFormatter.shortDate(entry.createdAt)} · '
                            '${DateFormatter.time(entry.createdAt)}',
                            style: textTheme.labelSmall,
                          ),
                          const Spacer(),
                          if (entry.hasLocation)
                            Icon(Icons.place, size: 16, color: scheme.primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
