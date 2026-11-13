#!/bin/bash
set -e

echo "[1/4] Preparing build workspace..."
PROJECT_DIR="${WORKSPACE:-$(pwd)}"
cd "$PROJECT_DIR"

if [ ! -f "app/src/main/AndroidManifest.xml" ]; then
    echo "Error: app/src/main/AndroidManifest.xml nahi mili"
    exit 1
fi

echo "[2/4] Gradle files check kar rahe hain..."

if [ ! -f "settings.gradle" ] && [ ! -f "settings.gradle.kts" ]; then
    echo "settings.gradle bana rahe hain"
    cat > settings.gradle << 'GRADLE_EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "AincradMods"
include ':app'
GRADLE_EOF
fi

if [ ! -f "gradle.properties" ]; then
    echo "gradle.properties bana rahe hain"
    cat > gradle.properties << 'PROP_EOF'
android.useAndroidX=true
org.gradle.jvmargs=-Xmx2g
PROP_EOF
fi

if [ ! -f "app/build.gradle" ] && [ ! -f "app/build.gradle.kts" ]; then
    echo "app/build.gradle bana rahe hain"
    cat > app/build.gradle << 'APP_EOF'
plugins {
    id 'com.android.application' version '8.5.2'
}

android {
    namespace 'com.aincrad.mods'
    compileSdk 34

    defaultConfig {
        applicationId 'com.aincrad.mods'
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName '1.0'
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

configurations.all {
    exclude group: 'org.jetbrains.kotlin', module: 'kotlin-stdlib-jdk7'
    exclude group: 'org.jetbrains.kotlin', module: 'kotlin-stdlib-jdk8'
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'androidx.core:core:1.12.0'
}
APP_EOF
fi

echo "[3/4] APK build ho raha hai (Gradle)..."
if [ -f "gradlew" ]; then
    chmod +x gradlew
    ./gradlew assembleDebug --no-daemon
else
    gradle assembleDebug --no-daemon
fi

echo "[4/4] APK copy kar rahe hain..."
APK_FILE="$(find . -path '*outputs/apk*' -name '*.apk' | head -n 1)"
if [ -z "$APK_FILE" ]; then
    echo "Error: APK nahi mili"
    exit 1
fi
cp "$APK_FILE" AincradMods_signed.apk
echo "Build completed successfully: AincradMods_signed.apk"
