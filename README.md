# Bitácora — Parcial 2

App de diario personal hecha en Flutter. En cada entrada puedes:

- 📷 Tomar una foto con la **cámara** o elegirla de la **galería**
- 🎤 **Dictar** el texto con el micrófono (voz a texto)
- 📍 Guardar automáticamente tu **ubicación GPS** y verla en **Google Maps**

- 🔒 Entrar con **huella digital** (login biométrico)

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
│   ├── auth_service.dart          Login con huella
│   ├── permisos_service.dart      Pedir permisos y manejar si los niegan
│   ├── camara_service.dart        Cámara y galería
│   ├── voz_service.dart           Micrófono → texto
│   └── ubicacion_service.dart     GPS
└── screens/
    ├── login_screen.dart          Pantalla de huella
    ├── inicio_screen.dart         Lista de entradas + menú lateral
    ├── nueva_entrada_screen.dart  Formulario
    └── detalle_screen.dart        Ver una entrada + Google Maps
```

## Cómo ejecutarla

1. Abrir la carpeta en **Android Studio** (con los plugins de Flutter y Dart).
2. Abrir el emulador: **Device Manager → ▶** (o conectar un celular con depuración USB).
3. Arriba, elegir el dispositivo **(mobile)** y presionar **▶ Run**.
4. En el emulador, la huella se simula con **⋯ → Fingerprint → Touch the sensor**.

## Requerimientos cubiertos

| Requerimiento | Dónde |
|---|---|
| Scaffold, AppBar y Drawer | `inicio_screen.dart` |
| Rutas y Navigator | `main.dart` (rutas `/`, `/nueva`, `/detalle`) |
| Animación Hero | foto en `inicio_screen.dart` → `detalle_screen.dart` |
| SQLite | `db_helper.dart` |
| try-catch | servicios y pantallas (`nueva_entrada`, `detalle`, `login`) |
| Login biométrico | `auth_service.dart`, `login_screen.dart` |
| Permisos denegados | `permisos_service.dart` |
| Serialización JSON | `entrada.dart` (`toJson` / `fromJson`) |
| FutureBuilder | `inicio_screen.dart` |
| Cámara y galería | `camara_service.dart` |
| Micrófono / dictado | `voz_service.dart` |
| GPS + Google Maps | `ubicacion_service.dart`, `detalle_screen.dart` |
