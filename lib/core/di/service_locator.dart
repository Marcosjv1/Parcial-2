import '../../data/datasources/database_helper.dart';
import '../../data/repositories/sqlite_diary_repository.dart';
import '../../domain/repositories/diary_repository.dart';
import '../../services/location_service.dart';
import '../../services/maps_launcher_service.dart';
import '../../services/media_service.dart';
import '../../services/speech_service.dart';

/// Contenedor sencillo de dependencias (Inyección de Dependencias manual).
///
/// Es el ÚNICO lugar donde se eligen las implementaciones concretas.
/// Las pantallas reciben las abstracciones por constructor, por lo que en
/// pruebas se puede crear un [ServiceLocator] con implementaciones falsas.
class ServiceLocator {
  const ServiceLocator({
    required this.diaryRepository,
    required this.locationService,
    required this.mediaService,
    required this.speechService,
    required this.mapsLauncher,
  });

  /// Configuración real usada por la app.
  factory ServiceLocator.production() {
    return ServiceLocator(
      diaryRepository: SqliteDiaryRepository(DatabaseHelper.instance),
      locationService: const GeolocatorLocationService(),
      mediaService: ImagePickerMediaService(),
      speechService: SpeechToTextService(),
      mapsLauncher: const GoogleMapsLauncherService(),
    );
  }

  final DiaryRepository diaryRepository;
  final LocationService locationService;
  final MediaService mediaService;
  final SpeechService speechService;
  final MapsLauncherService mapsLauncher;
}
