import java.io.FileInputStream
import java.util.Properties
import com.android.build.gradle.internal.api.ApkVariantOutputImpl
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.baly_groceries_tracker.app"
    compileSdkExtension = 37
    compileSdk {
        version = release(37) {
            minorApiLevel = 0 // Force Gradle and transitive dependencies to use the android-37.0 directory
        }
    }
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }

    defaultConfig {
        applicationId = "com.baly_groceries_tracker.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val storeFilePath = keystoreProperties.getProperty("STORE_FILE")
                if (storeFilePath != null) {
                    storeFile = file(storeFilePath)
                    storePassword = keystoreProperties.getProperty("STORE_PASSWORD")
                    keyAlias = keystoreProperties.getProperty("KEY_ALIAS")
                    keyPassword = keystoreProperties.getProperty("KEY_PASSWORD")
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

android.applicationVariants.configureEach {
    val variant = this

    val abiCodes = mapOf(
        "armeabi-v7a" to 1,
        "arm64-v8a" to 2,
        "x86_64" to 3
    )

    variant.outputs.forEach { output ->
        val abiVersionCode =
            abiCodes[output.filters.find { it.filterType == "ABI" }?.identifier]

        if (abiVersionCode != null) {
            (output as ApkVariantOutputImpl).versionCodeOverride =
                variant.versionCode * 10 + abiVersionCode
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}