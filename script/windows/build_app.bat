@echo off
setlocal enabledelayedexpansion

set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "CYAN=[96m"
set "WHITE=[97m"
set "RESET=[0m"

set "PROJECT_DIR=C:\Users\%USERNAME%\meu-projeto"
cd /d "%PROJECT_DIR%"

echo %CYAN%╔══════════════════════════════════════════════════════╗%RESET%
echo %CYAN%║            Building Android App                      ║%RESET%
echo %CYAN%╚══════════════════════════════════════════════════════╝%RESET%
echo.

:: ─── Limpar build anterior ───────────────────────────────────────────────────
echo %YELLOW%[1/3] Limpando builds anteriores...%RESET%
call gradlew.bat clean
if %errorlevel% neq 0 (
    echo %RED%  ✗ Erro ao limpar o projeto.%RESET%
    pause
    exit /b 1
)
echo %GREEN%  ✓ Limpeza concluida%RESET%
echo.

:: ─── Build Debug APK ─────────────────────────────────────────────────────────
echo %YELLOW%[2/3] Compilando APK Debug...%RESET%
call gradlew.bat assembleDebug
if %errorlevel% neq 0 (
    echo %RED%  ✗ BUILD FAILED!%RESET%
    echo %WHITE%  Execute para ver detalhes do erro:%RESET%
    echo %WHITE%    .\gradlew.bat assembleDebug --stacktrace%RESET%
    pause
    exit /b 1
)
echo.

:: ─── Resultado ───────────────────────────────────────────────────────────────
echo %YELLOW%[3/3] Verificando APK...%RESET%
set "APK=app\build\outputs\apk\debug\app-debug.apk"
if exist "%APK%" (
    echo %GREEN%  ✓ BUILD SUCCESSFUL!%RESET%
    echo %GREEN%  ✓ APK gerado em:%RESET%
    echo %WHITE%    %APK%%RESET%
) else (
    echo %RED%  ✗ APK nao encontrado.%RESET%
)
echo.

:: ─── Instalar no dispositivo ─────────────────────────────────────────────────
echo %CYAN%╔══════════════════════════════════════════════════════╗%RESET%
echo %CYAN%║           Instalar no Dispositivo                    ║%RESET%
echo %CYAN%╚══════════════════════════════════════════════════════╝%RESET%
echo.
adb devices
echo.
set /p INSTALAR=%YELLOW%Deseja instalar o APK no dispositivo? (s/n): %RESET%
if /i "%INSTALAR%"=="s" (
    adb install "%APK%"
    if %errorlevel% neq 0 (
        echo %RED%  ✗ Erro ao instalar o APK.%RESET%
    ) else (
        echo %GREEN%  ✓ APK instalado com sucesso!%RESET%
    )
)
echo.

:: ─── Outros comandos uteis ───────────────────────────────────────────────────
echo %WHITE%  Outros comandos uteis:%RESET%
echo %WHITE%    .\gradlew.bat assembleRelease    :: Build versao Release%RESET%
echo %WHITE%    .\gradlew.bat installDebug       :: Instala no dispositivo conectado%RESET%
echo %WHITE%    .\gradlew.bat build              :: Build completo com testes%RESET%
echo.
pause
