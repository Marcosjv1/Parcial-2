# Script de configuración para Windows (PowerShell).
# Genera las carpetas nativas de Android (sin sobrescribir el AndroidManifest
# que ya trae los permisos) y descarga las dependencias.
#
# Uso:  abre una terminal en esta carpeta y ejecuta:  .\setup.ps1

flutter create . --project-name bitacora --org com.marcos --platforms android
flutter pub get
Write-Host ""
Write-Host "Listo. Conecta tu celular (depuracion USB) o abre un emulador y ejecuta: flutter run"
