#!/bin/bash
set -e

PROJECT_ROOT="$HOME/AincradMods"
ANDROID_JAR="$PREFIX/share/java/android.jar"
if [ ! -f "$ANDROID_JAR" ]; then
    ANDROID_JAR="$PREFIX/share/aapt/android.jar"
fi
D8_JAR="$PREFIX/share/java/d8.jar"

BUILD_DIR="$PROJECT_ROOT/build"
OUT_APK="$PROJECT_ROOT/AincradMods_signed.apk"
UNSIGNED_APK="$BUILD_DIR/app-unsigned.apk"

echo "[1/4] Preparing build workspace..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/obj" "$BUILD_DIR/dex" "$PROJECT_ROOT/app/src/main/jniLibs/arm64-v8a"

if [ -f "$PROJECT_ROOT/libaincrad.so" ]; then
    cp "$PROJECT_ROOT/libaincrad.so" "$PROJECT_ROOT/app/src/main/jniLibs/arm64-v8a/"
fi

echo "[2/4] Compiling Java code using safe ecj command..."
ecj -source 1.8 -target 1.8 \
    -sourcepath "$PROJECT_ROOT/app/src/main/java" \
    -classpath "$ANDROID_JAR" \
    -d "$BUILD_DIR/obj" \
    $(find "$PROJECT_ROOT/app/src/main/java" -name "*.java")

echo "[3/4] Converting classes to DEX using D8..."
java -cp "$D8_JAR" com.android.tools.r8.D8 \
    --release \
    --min-api 26 \
    --output "$BUILD_DIR/dex" \
    $(find "$BUILD_DIR/obj" -name "*.class")

echo "[4/4] Creating and Packaging final APK..."
aapt package -f \
    -M "$PROJECT_ROOT/app/src/main/AndroidManifest.xml" \
    -I "$ANDROID_JAR" \
    -F "$UNSIGNED_APK"

cd "$BUILD_DIR/dex"
aapt add "$UNSIGNED_APK" classes.dex

if [ -d "$PROJECT_ROOT/app/src/main/jniLibs" ]; then
    cd "$PROJECT_ROOT/app/src/main"
    aapt add "$UNSIGNED_APK" jniLibs/arm64-v8a/libaincrad.so
fi

echo "[✓] Signing final APK..."
apksigner sign --out "$OUT_APK" "$UNSIGNED_APK" 2>/dev/null || {
    apksigner sign --out "$OUT_APK" "$UNSIGNED_APK"
}

if [ -f "$OUT_APK" ]; then
    cp "$OUT_APK" /sdcard/Download/
    echo "=========================================="
    echo "SUCCESS! APK generated successfully:"
    echo "/sdcard/Download/AincradMods_signed.apk"
    echo "=========================================="
else
    echo "Build failed."
fi
