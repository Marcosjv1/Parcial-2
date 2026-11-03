# Bitácora — Parcial 2

App de diario personal hecha en Flutter. En cada entrada puedes:

- 📷 Tomar una foto con la **cámara** o elegirla de la **galería**
- 🎤 **Dictar** el texto con el micrófono (voz a texto)
- 📍 Guardar automáticamente tu **ubicación GPS** y verla en **Google Maps**

Todo se guarda en el teléfono con **SQLite**.

## Estructura del proyecto

```
lib/
├── main.dart                      Arranque de la app y rutas
├── models/
│   └── entrada.dart               Clase Entrada (los datos de un día)
├── database/
│   └── db_helper.dart             Guardar, leer y borrar en SQLite
├── services/
│   ├── camara_service.dart        Cámara y galería
│   ├── voz_service.dart           Micrófono → texto
│   └── ubicacion_service.dart     GPS
└── screens/
    ├── inicio_screen.dart         Lista de entradas + menú lateral
    ├── nueva_entrada_screen.dart  Formulario
    └── detalle_screen.dart        Ver una entrada + Google Maps
```

## Cómo ejecutarla

1. Abrir el emulador de Android (o conectar un celular con depuración USB).
2. Abrir esta carpeta en VS Code.
3. En la terminal: `flutter pub get`
4. Presionar **F5** (o `flutter run`).

## Requerimientos cubiertos

| Requerimiento | Dónde |
|---|---|
| Scaffold, AppBar y Drawer | `inicio_screen.dart` |
| Rutas y Navigator | `main.dart` (rutas `/`, `/nueva`, `/detalle`) |
| Animación Hero | foto en `inicio_screen.dart` → `detalle_screen.dart` |
| SQLite | `db_helper.dart` |
| try-catch | pantallas `nueva_entrada` y `detalle` |
| FutureBuilder | `inicio_screen.dart` |
| Cámara y galería | `camara_service.dart` |
| Micrófono / dictado | `voz_service.dart` |
| GPS + Google Maps | `ubicacion_service.dart`, `detalle_screen.dart` |
