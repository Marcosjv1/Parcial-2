// build.gradle.kts: instrucciones para que Gradle (el que compila en Android Studio)
// arme el .apk de la app. Casi todo lo generó "flutter create".
plugins {
    // Esto es una app de Android (no una librería)
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Paquete del código Kotlin (MainActivity)
    namespace = "com.marcos.reportacalle"
    // Versión de Android con la que se compila y herramientas nativas (las pone Flutter)
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // Versión de Java que se usa para compilar
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // ID único de la app en el teléfono (si cambia, Android cree que es otra app)
        applicationId = "com.marcos.reportacalle"
        // Android más viejo donde corre y Android para el que está pensada
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Salen de "version: 1.0.0+1" en pubspec.yaml
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Para el parcial firmamos con la llave de debug, así "flutter build apk" funciona sin más
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Kotlin también compila para Java 17
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

// Dónde está el proyecto de Flutter (dos carpetas arriba de android/app)
flutter {
    source = "../.."
}
