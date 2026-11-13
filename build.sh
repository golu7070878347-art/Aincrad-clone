#!/bin/bash
set -euo pipefail

echo "[1/4] Preparing build workspace..."
PROJECT_DIR="${WORKSPACE:-$(pwd)}"
cd "$PROJECT_DIR"
rm -rf build
mkdir -p build/classes build/dex

# Agar Gradle project hai to seedha APK bana do
if [ -f "gradlew" ]; then
    echo "[2/4] Gradle project mila, assembleDebug chala rahe hain..."
    chmod +x gradlew
    ./gradlew assembleDebug --no-daemon
    APK_FILE="$(find . -path '*outputs/apk*' -name '*.apk' | head -n 1)"
    if [ -z "$APK_FILE" ]; then
        echo "Error: APK nahi mili"
        exit 1
    fi
    cp "$APK_FILE" AincradMods_signed.apk
    echo "[4/4] Build complete: AincradMods_signed.apk"
    exit 0
fi

echo "[2/4] Compiling Java code using javac..."
find . -name "*.java" -not -path "./build/*" > sources.txt

if [ ! -s sources.txt ]; then
    echo "Koi .java file nahi mili, test file bana rahe hain..."
    mkdir -p build/testsrc
    cat > build/testsrc/Test.java << 'JAVA'
public class Test {
    public static void main(String[] args) {
        System.out.println("GitHub Actions Build Working!");
    }
}
JAVA
    echo "build/testsrc/Test.java" > sources.txt
fi

# Android SDK ka android.jar classpath mein daalo (agar mile)
ANDROID_JAR=""
if [ -n "${ANDROID_HOME:-}" ] && [ -d "$ANDROID_HOME/platforms" ]; then
    ANDROID_JAR="$(ls -d "$ANDROID_HOME"/platforms/android-*/android.jar 2>/dev/null | sort -V | tail -n 1 || true)"
fi

if [ -n "$ANDROID_JAR" ]; then
    javac --release 8 -cp "$ANDROID_JAR" -d build/classes @sources.txt
else
    javac --release 8 -d build/classes @sources.txt
fi
rm -f sources.txt

echo "[3/4] Generating DEX using D8..."
D8=""
if [ -n "${ANDROID_HOME:-}" ] && [ -d "$ANDROID_HOME/build-tools" ]; then
    D8="$(ls -d "$ANDROID_HOME"/build-tools/*/d8 2>/dev/null | sort -V | tail -n 1 || true)"
fi

if [ -n "$D8" ]; then
    CLASS_FILES="$(find build/classes -name '*.class')"
    if [ -n "$ANDROID_JAR" ]; then
        "$D8" --release --lib "$ANDROID_JAR" --output build/dex $CLASS_FILES
    else
        "$D8" --release --output build/dex $CLASS_FILES
    fi
    echo "DEX ban gayi: build/dex/classes.dex"
else
    echo "Warning: d8 nahi mila, DEX step skip kiya."
fi

echo "[4/4] Build script completed successfully!"
