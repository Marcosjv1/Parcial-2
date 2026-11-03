import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/repositories/diary_repository.dart';
import '../../services/location_service.dart';
import '../../services/media_service.dart';
import '../../services/speech_service.dart';

/// Formulario para crear una nueva entrada del diario.
///
/// Integra los tres gadgets:
///  1. Cámara / galería  -> [MediaService]
///  2. Micrófono (dictado de voz a texto) -> [SpeechService]
///  3. GPS al guardar -> [LocationService]
///
/// Al guardar con éxito hace `Navigator.pop(context, true)` para que la lista
/// sepa que debe recargarse.
class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({
    super.key,
    required this.repository,
    required this.mediaService,
    required this.speechService,
    required this.locationService,
  });

  final DiaryRepository repository;
  final MediaService mediaService;
  final SpeechService speechService;
  final LocationService locationService;

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String? _imagePath;
  bool _isListening = false;
  bool _isSaving = false;
  bool _wasSaved = false;

  /// Texto que ya existía antes de empezar a dictar; lo dictado se agrega
  /// al final sin borrar lo que el usuario escribió a mano.
  String _textBeforeDictation = '';

  @override
  void dispose() {
    if (_isListening) widget.speechService.stopListening();
    // Si el usuario sale sin guardar, borramos la foto que se copió.
    if (!_wasSaved && _imagePath != null) {
      widget.mediaService.deleteImage(_imagePath!);
    }
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ===================================================================
  // Gadget 1: Cámara y galería
  // ===================================================================
  Future<void> _pickImage({required bool fromCamera}) async {
    try {
      final path = fromCamera
          ? await widget.mediaService.takePhoto()
          : await widget.mediaService.pickFromGallery();
      if (path == null || !mounted) return; // Canceló.

      final previous = _imagePath;
      setState(() => _imagePath = path);
      // Si reemplazó una foto anterior, eliminamos la que ya no se usa.
      if (previous != null) await widget.mediaService.deleteImage(previous);
    } on AppException catch (e) {
      _showSnack(e.message, isError: true);
    }
  }

  Future<void> _removeImage() async {
    final path = _imagePath;
    setState(() => _imagePath = null);
    if (path != null) await widget.mediaService.deleteImage(path);
  }

  // ===================================================================
  // Gadget 2: Micrófono y dictado
  // ===================================================================
  Future<void> _toggleDictation() async {
    if (_isListening) {
      await widget.speechService.stopListening();
      return;
    }
    _textBeforeDictation = _contentController.text.trim();
    try {
      await widget.speechService.startListening(
        onResult: _onSpeechResult,
        onListeningChanged: (listening) {
          if (mounted) setState(() => _isListening = listening);
        },
      );
    } on AppException catch (e) {
      if (mounted) setState(() => _isListening = false);
      _showSnack(e.message, isError: true);
    }
  }

  void _onSpeechResult(String words, bool isFinal) {
    final text = _textBeforeDictation.isEmpty
        ? words
        : '$_textBeforeDictation $words';
    _contentController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  // ===================================================================
  // Gadget 3: GPS + guardado en SQLite
  // ===================================================================
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isListening) await widget.speechService.stopListening();

    setState(() => _isSaving = true);
    try {
      // 1. Capturar la posición GPS actual.
      GeoPoint? location;
      try {
        location = await widget.locationService.getCurrentPosition();
      } on LocationException catch (e) {
        // Sin GPS se puede guardar igual, pero preguntamos al usuario.
        final saveAnyway = await _askSaveWithoutLocation(e.message);
        if (!saveAnyway) return;
      }

      // 2. Crear la entidad y guardarla en SQLite.
      final entry = DiaryEntry(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: DateTime.now(),
        imagePath: _imagePath,
        location: location,
      );
      await widget.repository.insert(entry);

      _wasSaved = true;
      if (!mounted) return;
      Navigator.pop(context, true);
    } on AppException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (e) {
      _showSnack('Ocurrió un error inesperado: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _askSaveWithoutLocation(String reason) async {
    if (!mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.location_off),
        title: const Text('No se obtuvo la ubicación'),
        content: Text('$reason\n\n¿Quieres guardar la entrada sin ubicación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Guardar sin ubicación'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  // ===================================================================
  // UI
  // ===================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva entrada'),
        leading: IconButton(
          tooltip: 'Cerrar',
          icon: const Icon(Icons.close),
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
        ),
      ),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              _buildImagePicker(),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ej. Día de campo en Progreso',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Escribe un título'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 6,
                maxLines: 12,
                decoration: const InputDecoration(
                  labelText: '¿Qué pasó hoy?',
                  hintText: 'Escribe o usa el micrófono para dictar...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Escribe o dicta el contenido de tu día'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildDictationButton(),
              const SizedBox(height: 16),
              _buildLocationHint(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _save,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: Text(_isSaving ? 'Obteniendo GPS...' : 'Guardar'),
      ),
    );
  }

  Widget _buildImagePicker() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            // AnimatedSwitcher: transición suave al cambiar la foto.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _imagePath == null
                  ? Container(
                      key: const ValueKey('empty'),
                      color: scheme.surfaceContainerHighest,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              size: 48, color: scheme.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text('Agrega una foto de tu día',
                              style: TextStyle(color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    )
                  : Stack(
                      key: ValueKey(_imagePath),
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(_imagePath!), fit: BoxFit.cover),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton.filledTonal(
                            tooltip: 'Quitar foto',
                            onPressed: _removeImage,
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(fromCamera: true),
                icon: const Icon(Icons.photo_camera),
                label: const Text('Cámara'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(fromCamera: false),
                icon: const Icon(Icons.photo_library),
                label: const Text('Galería'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDictationButton() {
    final scheme = Theme.of(context).colorScheme;
    // AnimatedContainer: el botón cambia de color y tamaño mientras escucha.
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(_isListening ? 12 : 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: _isListening ? scheme.errorContainer : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filled(
              iconSize: 36,
              style: IconButton.styleFrom(
                backgroundColor:
                    _isListening ? scheme.error : scheme.primary,
                foregroundColor:
                    _isListening ? scheme.onError : scheme.onPrimary,
              ),
              tooltip: _isListening ? 'Detener dictado' : 'Dictar con voz',
              onPressed: _toggleDictation,
              icon: Icon(_isListening ? Icons.stop : Icons.mic),
            ),
            const SizedBox(height: 4),
            Text(
              _isListening ? 'Escuchando... toca para detener' : 'Dictar',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHint() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.my_location,
            color: Theme.of(context).colorScheme.primary),
        title: const Text('Ubicación automática'),
        subtitle: const Text(
          'Al guardar se registrará tu posición GPS actual para mostrarla '
          'en el mapa.',
        ),
      ),
    );
  }
}
