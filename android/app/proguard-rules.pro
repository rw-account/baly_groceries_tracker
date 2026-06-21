-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

##  حل مشكلة انهيار إقلاع التطبيق لـ WorkManager (NoSuchMethodException)
-keep class androidx.work.impl.WorkDatabase_Impl {
    public <init>(...);
}
-keep class * extends androidx.room.RoomDatabase {
    public <init>(...);
}