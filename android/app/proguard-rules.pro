# Keep sqflite classes from being stripped by R8
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**
