@echo off
setlocal enabledelayedexpansion

set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "CYAN=[96m"
set "WHITE=[97m"
set "RESET=[0m"

cls
echo %CYAN%╔══════════════════════════════════════════════════════╗%RESET%
echo %CYAN%║            Building Android App                      ║%RESET%
echo %CYAN%╚══════════════════════════════════════════════════════╝%RESET%
echo.

:: ─── Detectar pasta do projeto ───────────────────────────────────────────────
if not exist "gradlew.bat" (
    echo %RED%  ✗ gradlew.bat nao encontrado em: %CD%%RESET%
    echo %WHITE%    Execute este script dentro da pasta do projeto.%RESET%
    pause
    exit /b 1
)
echo %GREEN%  ✓ Projeto encontrado: %CD%%RESET%
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
    echo %WHITE%    Execute para ver detalhes:%RESET%
    echo %WHITE%      .\gradlew.bat assembleDebug --stacktrace%RESET%
    pause
    exit /b 1
)
echo.

:: ─── Resultado ───────────────────────────────────────────────────────────────
echo %YELLOW%[3/3] Verificando APK...%RESET%
set "APK=app\build\outputs\apk\debug\app-debug.apk"
if exist "%APK%" (
    echo %GREEN%  ✓ BUILD SUCCESSFUL!%RESET%
    echo %GREEN%  ✓ APK gerado em: %APK%%RESET%
) else (
    echo %RED%  ✗ APK nao encontrado.%RESET%
    pause
    exit /b 1
)
echo.

:: ─── Instalar no dispositivo ─────────────────────────────────────────────────
echo %CYAN%╔══════════════════════════════════════════════════════╗%RESET%
echo %CYAN%║           Instalar no Dispositivo                    ║%RESET%
echo %CYAN%╚══════════════════════════════════════════════════════╝%RESET%
echo.
adb devices
echo.
set /p INSTALAR=Deseja instalar o APK no dispositivo? (s/n): 
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
echo %WHITE%    .\gradlew.bat test               :: Executa testes unitarios%RESET%
echo %WHITE%    .\gradlew.bat lint               :: Analisa qualidade do codigo%RESET%
echo.
pause
