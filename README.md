# ReportaCalle - Proyecto final (ordinario)

Proyecto final de **Programación de Dispositivos Móviles** (Universidad Anáhuac Mayab).

App de Flutter para **reportar problemas de la ciudad** (baches, luminarias apagadas, basura, fugas de agua). Cada reporte lleva foto, ubicación GPS, urgencia de 1 a 5, referencia del lugar y si es peligroso. Los reportes se guardan en el teléfono (SQLite) y se mandan a un servidor Node.js que los guarda en PostgreSQL.

## Qué hace

- Login con **huella digital** y bienvenida con carrusel que avanza solo.
- Formulario de 4 pasos: foto (cámara o galería), tipo, descripción (se puede **dictar por voz**) y detalles.
- **GPS** automático al enviar.
- Se guarda en **SQLite** y en archivos de texto (`historial.txt`), aunque no haya internet.
- Se envía al **servicio web** (Node.js + Express + PostgreSQL) y se pueden leer los reportes de todos.
- Se puede marcar un reporte como **Resuelto** y el cambio llega al servidor.

## Estructura

```
lib/            App Flutter (screens, services, models, database, widgets)
servidor/       API en Node.js + Express
  server.js     Rutas: GET/POST /api/reportes, GET /api/reportes/:id/foto, PUT /api/reportes/:id/estado
  schema.sql    Tabla reportes de PostgreSQL
  .env.example  Datos de conexión (copiar a .env)
assets/images/  Imágenes de la app
```

## Cómo correrlo

### 1. Servidor y base de datos

1. Tener **PostgreSQL** instalado y crear la base de datos con el script `servidor/schema.sql`.
2. En `servidor/`, copiar `.env.example` a `.env` y poner los datos de conexión.
3. En una terminal dentro de `servidor/`:

```
npm install
npm start
```

El servidor queda en `http://localhost:3000`. Para ver los datos: `http://localhost:3000/api/reportes`.

### 2. App (Android Studio)

1. Abrir la carpeta en **Android Studio** (con los plugins de Flutter y Dart).
2. Abrir el emulador en **Device Manager** y elegirlo arriba.
3. Presionar **Run**.
4. En el emulador, la huella se simula con **... > Fingerprint > Touch the sensor**.

La app llega al servidor desde el emulador con la dirección `10.0.2.2:3000` (el equivalente de `localhost` de la laptop).

## Requisitos del proyecto

| Requisito | Dónde |
|---|---|
| Interfaz con imágenes | `assets/images/`, carrusel de bienvenida, ilustraciones por tipo |
| Widget con desplazamiento automático | `bienvenida_screen.dart` |
| Navegación con paso de datos | `main.dart`, de la lista al detalle |
| Formulario (texto, número, booleano, fecha) | `nuevo_reporte_screen.dart` |
| Al menos 2 gadgets | cámara, micrófono, GPS y huella |
| Almacenamiento físico | `db_helper.dart` (SQLite) y archivos de texto |
| Servicio web que escribe y lee en una BD | `servidor/server.js` + `api_service.dart` |
