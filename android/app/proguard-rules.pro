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