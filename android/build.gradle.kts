// Top-level build.gradle.kts

plugins {
    id("com.android.application") version "8.10.2" apply false
    id("org.jetbrains.kotlin.android") version "2.0.20" apply false
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
}

task<Delete>("clean") {
    delete(rootProject.buildDir)
}
