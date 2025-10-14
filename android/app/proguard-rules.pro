# Flutter / Plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Kotlin
-dontwarn kotlin.**
-keep class kotlin.** { *; }

# PDFBox-Android y dependencias Apache Commons
-keep class org.apache.pdfbox.** { *; }
-dontwarn org.apache.pdfbox.**
-keep class com.tom_roush.pdfbox.** { *; }
-dontwarn com.tom_roush.pdfbox.**
-keep class org.apache.commons.compress.** { *; }
-dontwarn org.apache.commons.compress.**
-keep class org.apache.commons.io.** { *; }
-dontwarn org.apache.commons.io.**

# AndroidX
-keep class androidx.** { *; }
-dontwarn javax.annotation.**
