// Top-level build.gradle.kts

plugins {
    // No application plugin here, only dependencies for build system
    id("com.android.application") version "8.3.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
    id("dev.flutter.flutter-gradle-plugin") apply false
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
