-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

## Fixing the app startup crash issue for WorkManager (NoSuchMethodException)
-keep class androidx.work.impl.WorkDatabase_Impl {
    public <init>(...);
}
-keep class * extends androidx.room.RoomDatabase {
    public <init>(...);
}