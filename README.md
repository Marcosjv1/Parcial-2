# Bitácora — Diario personal con fotos, voz y GPS

Proyecto **Parcial 2** · Desarrollo de Aplicaciones Móviles (Flutter)
Autor: **Marcos** · Universidad Anáhuac Mayab

Bitácora permite registrar el día en segundos: escribes **o dictas** lo que pasó,
agregas una **foto** (cámara o galería) y la app guarda automáticamente **dónde
estabas** (GPS). Cada entrada se puede ver en un mapa interactivo o abrir en
Google Maps. Todo se guarda localmente en **SQLite**, sin necesidad de internet.

---

## ✅ Cumplimiento de requerimientos

| Requerimiento | Dónde está |
|---|---|
| `Scaffold` + `AppBar` + `Drawer` | `presentation/screens/home_screen.dart`, `widgets/app_drawer.dart` |
| Rutas con nombre + `Navigator` (lista → detalle → formulario) | `core/routes/app_routes.dart` |
| Transición `Hero` de la imagen (lista → detalle) | `widgets/entry_card.dart` ↔ `screens/entry_detail_screen.dart` |
| Otras animaciones | `PageRouteBuilder` (fade / slide), `AnimatedSwitcher`, `AnimatedContainer` |
| SQLite con imagen y coordenadas | `data/datasources/database_helper.dart`, `data/repositories/sqlite_diary_repository.dart` |
| `try-catch` + excepciones propias | `core/errors/app_exception.dart` y todos los servicios/repositorio |
| `FutureBuilder` para carga asíncrona | `home_screen.dart` |
| Gadget: Cámara y galería | `services/media_service.dart` (`image_picker`) |
| Gadget: Micrófono → texto | `services/speech_service.dart` (`speech_to_text`) |
| Gadget: GPS al guardar | `services/location_service.dart` (`geolocator`) |
| Mapa interactivo + botón a Google Maps | `widgets/location_map.dart` (`flutter_map`), `services/maps_launcher_service.dart` |

## 🏗️ Arquitectura por capas

```
lib/
├── main.dart / app.dart        Arranque y MaterialApp
├── core/
│   ├── di/                     ServiceLocator (inyección de dependencias)
│   ├── errors/                 AppException y subclases
│   ├── routes/                 Rutas con nombre y transiciones
│   ├── theme/                  Tema Material 3
│   └── utils/                  DateFormatter
├── domain/                     ← No depende de Flutter ni de plugins
│   ├── entities/               DiaryEntry, GeoPoint
│   └── repositories/           DiaryRepository (abstracto)
├── data/
│   ├── datasources/            DatabaseHelper (SQLite)
│   └── repositories/           SqliteDiaryRepository
├── services/                   Hardware: GPS, cámara, micrófono, mapas
└── presentation/
    ├── screens/                Home, Detalle, Nueva entrada, Acerca de
    └── widgets/                EntryCard, EntryImage, AppDrawer, LocationMap
```

Principios SOLID aplicados:
- **S** – cada clase tiene una sola responsabilidad (p. ej. `DatabaseHelper` sólo abre la BD; el repositorio hace las consultas).
- **O** – para cambiar SQLite por otra tecnología se crea otra implementación de `DiaryRepository` sin tocar las pantallas.
- **L** – cualquier implementación de `LocationService`, `MediaService`, etc. es intercambiable (p. ej. versiones falsas para pruebas).
- **I** – interfaces pequeñas y específicas por gadget en lugar de un “servicio gigante”.
- **D** – las pantallas reciben abstracciones por constructor; las implementaciones concretas sólo se eligen en `ServiceLocator.production()`.

## ▶️ Cómo ejecutarlo

Requisitos: Flutter 3.27 o superior (`flutter --version`), Android Studio con un
emulador o un celular Android con depuración USB.

1. Abre esta carpeta en **VS Code** (instala la extensión *Flutter*).
2. Abre la terminal (`Ctrl + ñ` o *Terminal → New Terminal*) y ejecuta:
   - Windows: `./setup.ps1`
   - macOS / Linux: `bash setup.sh`

   Si Windows bloquea el script, ejecuta los comandos a mano:
   `flutter create . --project-name bitacora --org com.marcos --platforms android`
   y luego `flutter pub get`.

   Esto genera las carpetas nativas de Android **sin sobrescribir** el
   `AndroidManifest.xml` que ya incluye los permisos de cámara, micrófono, GPS
   e internet, y descarga las dependencias.
3. Ejecuta `flutter run` (o presiona **F5** en VS Code).
4. Pruebas unitarias: `flutter test`.

> 💡 Para probar cámara, micrófono y GPS es mejor un **celular real**. En el
> emulador: la ubicación se simula en *Extended controls → Location* y el
> micrófono requiere activar *Virtual microphone uses host audio input*.

### iOS (opcional, sólo en Mac)
Agregar a `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key><string>Para tomar la foto de tu día</string>
<key>NSPhotoLibraryUsageDescription</key><string>Para elegir una foto de tu galería</string>
<key>NSMicrophoneUsageDescription</key><string>Para dictar tus entradas</string>
<key>NSSpeechRecognitionUsageDescription</key><string>Para convertir tu voz en texto</string>
<key>NSLocationWhenInUseUsageDescription</key><string>Para guardar dónde escribiste cada entrada</string>
```

## 📦 Paquetes utilizados

`sqflite`, `path`, `path_provider`, `image_picker`, `speech_to_text`,
`geolocator`, `flutter_map`, `latlong2`, `url_launcher`.
