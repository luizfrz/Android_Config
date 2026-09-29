@echo off
:: Compila o APK (debug ou release) via Gradle Wrapper e, opcionalmente, instala via ADB.
::
:: Uso: scripts\windows\build-apk.bat [/release] [/install ^| /noinstall] [/noclean] [PROJECT_DIR]
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
call "%~dp0lib\colors.bat"

set "VARIANT=debug"
set "TASK=assembleDebug"
set "INSTALL=ask"
set "CLEAN=1"
set "PROJECT_DIR=%CD%"

:parse_args
if "%~1"=="" goto :args_done
if /i "%~1"=="/release"   (set "VARIANT=release" & set "TASK=assembleRelease") else ^
if /i "%~1"=="/install"   (set "INSTALL=yes") else ^
if /i "%~1"=="/noinstall" (set "INSTALL=no") else ^
if /i "%~1"=="/noclean"   (set "CLEAN=0") else ^
if /i "%~1"=="/?"         (goto :usage) else (set "PROJECT_DIR=%~f1")
shift
goto :parse_args
:args_done

if not exist "%PROJECT_DIR%\gradlew.bat" (
    echo %RED%  [X] gradlew.bat nao encontrado em %PROJECT_DIR%%RESET%
    call :pause_if_interactive
    exit /b 1
)
pushd "%PROJECT_DIR%"

echo.
echo %CYAN%== Build Android - %VARIANT% ==%RESET%
echo %GREEN%  [OK] Projeto: %CD%%RESET%

if "%CLEAN%"=="1" (
    echo %YELLOW%[1/3] gradlew clean%RESET%
    call gradlew.bat clean || goto :build_failed
)

echo %YELLOW%[2/3] gradlew %TASK%%RESET%
call gradlew.bat %TASK% || goto :build_failed

echo %YELLOW%[3/3] Localizando APK%RESET%
:: Cobre modulos com nomes customizados e product flavors; pega o mais recente.
set "APK="
for /f "usebackq tokens=*" %%f in (`powershell -NoProfile -Command "Get-ChildItem -Recurse -Filter *.apk -Path . | Where-Object { $_.FullName -match '\\build\\outputs\\apk\\' -and $_.FullName -match '\\%VARIANT%\\' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName"`) do set "APK=%%f"
if not defined APK (
    echo %RED%  [X] APK nao encontrado em *\build\outputs\apk\**\%VARIANT%\%RESET%
    popd & call :pause_if_interactive & exit /b 1
)
echo %GREEN%  [OK] APK: %APK%%RESET%

if /i "%VARIANT%"=="release" (
    echo "%APK%" | findstr /i "unsigned" >nul
    if not errorlevel 1 (
        echo %YELLOW%  [!] APK release nao assinado - configure signingConfigs para instalar.%RESET%
        set "INSTALL=no"
    )
)

if "%INSTALL%"=="ask" (
    where adb >nul 2>&1 && adb devices -l
    set /p "REPLY=Instalar o APK no dispositivo? [s/N] "
    if /i "!REPLY!"=="s" (set "INSTALL=yes") else (set "INSTALL=no")
)

if "%INSTALL%"=="yes" (
    where adb >nul 2>&1 || (echo %RED%  [X] adb nao encontrado no PATH%RESET% & popd & exit /b 1)
    rem -r: reinstala mantendo dados; -t: permite APKs de teste ^(debug^)
    adb install -r -t "%APK%"
    if errorlevel 1 (echo %RED%  [X] Falha em adb install%RESET%) else (echo %GREEN%  [OK] APK instalado%RESET%)
)

echo.
echo %WHITE%    Outros comandos: gradlew installDebug ^| test ^| lint ^| assembleRelease ^| bundleRelease%RESET%
popd
call :pause_if_interactive
exit /b 0

:build_failed
echo %RED%  [X] BUILD FAILED%RESET%
echo %WHITE%    Diagnostico: gradlew.bat %TASK% --stacktrace --info%RESET%
popd
call :pause_if_interactive
exit /b 1

:usage
echo Uso: build-apk.bat [/release] [/install ^| /noinstall] [/noclean] [PROJECT_DIR]
exit /b 0

:pause_if_interactive
echo %CMDCMDLINE% | findstr /i /c:"/c" >nul && pause
exit /b 0
