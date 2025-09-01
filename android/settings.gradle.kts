pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    plugins {
        id("com.android.application") version "8.7.0"
        id("com.android.library") version "8.7.0"
        id("org.jetbrains.kotlin.android") version "2.0.20"
        id("dev.flutter.flutter-gradle-plugin") version "1.0.0"
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "FitQuest"
include(":app")
