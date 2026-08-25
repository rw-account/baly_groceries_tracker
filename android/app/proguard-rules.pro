## 1. Preserving Annotations & Reflection
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

## 2. Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

## 3. Timezone Support (ThreeTenABP)
-keep class com.jakewharton.threetenabp.** { *; }
-dontwarn com.jakewharton.threetenabp.**

## 4. SharedPreferences & Core Plugins
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.**

## 5. Flutter WorkManager Plugin
-keep class dev.fluttercommunity.workmanager.** { *; }

## 6. AndroidX WorkManager Core (Optimized)
-dontwarn androidx.work.**
-keepclassmembers class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}

## 7. Flutter Engine & Background Execution
-keep class io.flutter.plugin.common.PluginRegistry { *; }
-keep class io.flutter.view.FlutterCallbackInformation { *; }
-keep class io.flutter.embedding.engine.FlutterJNI {
    native <methods>;
}