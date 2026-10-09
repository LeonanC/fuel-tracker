plugins {
    id("com.android.application")
<<<<<<< HEAD
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "br.com.fuel_tracker"
=======
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "br.com.fuel_tracker_app"
>>>>>>> 03b2b30e5e7d1cb189ce9a40f4069407d600b62f
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
<<<<<<< HEAD
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
=======
        isCoreLibraryDesugaringEnabled = true 
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
>>>>>>> 03b2b30e5e7d1cb189ce9a40f4069407d600b62f
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
<<<<<<< HEAD
        applicationId = "br.com.fuel_tracker"
=======
        applicationId = "br.com.fuel_tracker_app"
>>>>>>> 03b2b30e5e7d1cb189ce9a40f4069407d600b62f
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
<<<<<<< HEAD
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
=======

    dependencies {
        implementation(platform("com.google.firebase:firebase-bom:34.9.0"))
        implementation("com.google.firebase:firebase-analytics")
>>>>>>> 03b2b30e5e7d1cb189ce9a40f4069407d600b62f
    }
}

flutter {
    source = "../.."
}

dependencies {
<<<<<<< HEAD
=======
    // Esta linha fornece o código de compatibilidade para Java 8+ em versões antigas do Android.
>>>>>>> 03b2b30e5e7d1cb189ce9a40f4069407d600b62f
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}