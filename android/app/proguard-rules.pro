# Flutter/Dart Proguard configuration

# Google Play Core library (for dynamic features and app updates)
-keep class com.google.android.play.core.** {*;}
-keep interface com.google.android.play.core.** {*;}

# Lottie animation library
-keep class com.airbnb.lottie.** {*;}
-keep class com.airbnb.lottie.*$* {*;}
-keep interface com.airbnb.lottie.* {*;}

# DotLottie loader
-keep class com.dotlottie.** {*;}
-keep interface com.dotlottie.** {*;}

# Keep webview classes
-keep class android.webkit.** {*;}
-keep interface android.webkit.** {*;}

# Keep all native methods
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# Preserve Flutter-related classes
-keep class io.flutter.** {*;}
-keep interface io.flutter.** {*;}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Optimization settings
-optimizationpasses 5
-dontusemixedcaseclassnames
-allowaccessmodification
-verbose

# Rename obfuscated classes
-repackageclasses ''
