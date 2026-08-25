## 1. Preserving Annotations & Reflection
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

## 2. Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

## 3. Timezone Support
-keep class com.jakewharton.threetenabp.** { *; }
-dontwarn com.jakewharton.threetenabp.**

## 4. SharedPreferences & Core Android Plugins
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.**

## 5. Flutter WorkManager Plugin
-keep class dev.fluttercommunity.workmanager.** { *; }

## 6. AndroidX WorkManager Core
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker { *; }

## 7. Flutter Background Execution
-keep class io.flutter.app.FlutterPluginRegistry { *; }
-keep class io.flutter.plugin.common.PluginRegistry { *; }
-keep class io.flutter.view.FlutterCallbackInformation { *; }
-keep class io.flutter.embedding.engine.FlutterJNI {
    native void nativeInit(...);
    native void nativeRecordStartTimestamp(...);
}
