plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.bibi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.bibi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Disable Impeller (GPU rendering engine that can cause crashes on some devices)
        manifestPlaceholders["enableImpeller"] = "false"
        
        // Optimize for GPU rendering - reduce memory pressure
        multiDexEnabled = true
    }
    
    buildTypes {
        getByName("debug") {
            // Disable ProGuard/R8 for debug builds to improve build speed
            isMinifyEnabled = false
            // Ensure Impeller is disabled for debug builds
            manifestPlaceholders["enableImpeller"] = "false"
        }
        
        getByName("release") {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            
            // Disable minification to avoid R8 issues with Google Play Core
            isMinifyEnabled = false
            isShrinkResources = false
            // Ensure Impeller is disabled for release builds
            manifestPlaceholders["enableImpeller"] = "false"
        }
    }
}

flutter {
    source = "../.."
}
