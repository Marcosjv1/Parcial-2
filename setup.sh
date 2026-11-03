#!/usr/bin/env bash
# Script de configuración para macOS / Linux.
# Genera las carpetas nativas (sin sobrescribir el AndroidManifest con permisos)
# y descarga las dependencias.
set -e
flutter create . --project-name bitacora --org com.marcos --platforms android,ios
flutter pub get
echo ""
echo "Listo. Conecta tu celular o abre un emulador y ejecuta: flutter run"
