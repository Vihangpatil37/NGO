# Flutter Wrapper / Engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn com.google.android.play.core.**

# Dio / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepclassmembers class okhttp3.** { *; }
-keepclassmembers interface okhttp3.** { *; }

# Socket.IO
-dontwarn io.socket.**
-keep class io.socket.client.** { *; }
-keep class io.socket.engineio.client.** { *; }
-dontwarn org.json.**
