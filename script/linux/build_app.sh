#!/bin/bash
set -e 

# Building Android App

PROJECT_DIR="/home/"
cd "$PROJECT_DIR"

# Limpar build anterior
echo "[1/3] Limpando builds anteriores..."
./gradlew clean

# Build Debug APK
echo "[2/3] Compilando APK Debug..."
./gradlew assembleDebug

# Mostrar resultado
if [ $? -eq 0 ]; then
    echo "  BUILD SUCCESSFUL!"
    echo " APK gerado em:"
    find app/build/outputs/apk/debug -name "*.apk" 2>/dev/null
    echo "Para instalar no dispositivo:"
    echo "  adb install app/build/outputs/apk/debug/app-debug.apk"
    echo ""
else
    echo " BUILD FAILED!"
    echo "Execute para ver detalhes do erro:"
    echo "  ./gradlew assembleDebug --stacktrace"
fi

echo "  ./gradlew assembleRelease    # Build versão Release"
echo "  ./gradlew installDebug       # Instala no dispositivo conectado"
echo "  ./gradlew build              # Build completo com testes"

