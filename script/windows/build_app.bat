@echo off
echo === Build App ===

cd /d "%~dp0..\.."

echo Compilando projeto...
call gradlew.bat build
if %errorlevel% neq 0 (
    echo Erro ao compilar o projeto.
    pause
    exit /b 1
)

echo Gerando APK debug...
call gradlew.bat assembleDebug
if %errorlevel% neq 0 (
    echo Erro ao gerar APK.
    pause
    exit /b 1
)

echo APK gerado em: app\build\outputs\apk\debug\app-debug.apk

echo.
echo Dispositivos conectados:
adb devices

set /p INSTALAR=Deseja instalar o APK no dispositivo? (s/n): 
if /i "%INSTALAR%"=="s" (
    adb install app\build\outputs\apk\debug\app-debug.apk
)

pause
