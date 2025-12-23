// ✅ CRITICAL: Required imports for signing configuration
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 🔐 Chargement des propriétés de signature depuis key.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.musclemaster.fitness"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // 🔐 Configuration de signature Release
    signingConfigs {
        create("release") {
            // ✅ Safe casting with null checks for GitHub Actions
            keyAlias = keystoreProperties.getProperty("keyAlias") ?: ""
            keyPassword = keystoreProperties.getProperty("keyPassword") ?: ""
            storeFile = if (keystoreProperties.containsKey("storeFile")) {
                rootProject.file(keystoreProperties.getProperty("storeFile"))
            } else {
                null
            }
            storePassword = keystoreProperties.getProperty("storePassword") ?: ""
        }
    }

    defaultConfig {
        applicationId = "com.musclemaster.fitness"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ✅ Utilisation de la signature Release
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}


