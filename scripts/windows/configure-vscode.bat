@echo off
:: Configura o VS Code como ambiente secundario para Kotlin / Jetpack Compose.
::
:: Uso:  scripts\windows\configure-vscode.bat [diretorio-do-projeto-android]
::
:: O que faz (idempotente):
::   1. Instala a extensao JetBrains Kotlin (LSP) + XML, TOML e EditorConfig; remove extensoes Kotlin conflitantes.
::   2. Gera e instala a extensao local "compose-colors" (templates\vscode\compose-colors).
::   3. Mescla configuracoes de usuario (realce, formatter, cores de tokens, JDK, TMPDIR do servidor).
::   4. Se informado um projeto: cria local.properties (sdk.dir).
:: Depois de rodar: FECHE o VS Code por completo e abra de novo.
setlocal EnableExtensions
chcp 65001 >nul
call "%~dp0lib\colors.bat"

set "TEMPLATES_DIR=%~dp0..\..\templates"
set "PROJECT=%~1"
set "KOTLIN_TMP=%LOCALAPPDATA%\vscode-kotlin-tmp"
set "BUILD=%LOCALAPPDATA%\compose-colors-build"
set "USER_DIR=%APPDATA%\Code\User"

:: --- detecta VS Code ---------------------------------------------------------
where code >nul 2>&1
if errorlevel 1 (
    echo %RED%  [X] CLI 'code' nao encontrada. Reinstale o VS Code marcando "Add to PATH".%RESET%
    call :pause_if_interactive
    exit /b 1
)
echo.
echo %CYAN%== Configurar VS Code - Kotlin Android ==%RESET%

:: --- JDK para resolucao de simbolos ------------------------------------------
set "JDK="
for /d %%d in ("%USERPROFILE%\.gradle\jdks\*21*") do set "JDK=%%~fd"
if not defined JDK if defined JAVA_HOME set "JDK=%JAVA_HOME%"
if defined JDK (echo %WHITE%>> JDK: %JDK%%RESET%) else (echo %WHITE%>> JDK: nao encontrado; ignorando%RESET%)

:: --- 1. extensoes ------------------------------------------------------------
echo %YELLOW%[1/4] Extensoes%RESET%
for %%e in (jetbrains.kotlin-server redhat.vscode-xml tamasfe.even-better-toml editorconfig.editorconfig) do (
    call code --install-extension %%e --force >nul 2>&1
    if errorlevel 1 (echo %YELLOW%  [!] Falha ao instalar %%e%RESET%) else (echo %GREEN%  [OK] %%e%RESET%)
)
for %%e in (mathiasfrohlich.kotlin fwcd.kotlin) do call code --uninstall-extension %%e >nul 2>&1

:: --- 2. extensao local compose-colors ---------------------------------------
echo %YELLOW%[2/4] Extensao compose-colors%RESET%
if not exist "%BUILD%" mkdir "%BUILD%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0lib\build-compose-colors.ps1" -Source "%TEMPLATES_DIR%\vscode\compose-colors" -Out "%BUILD%\compose-colors.vsix"
if errorlevel 1 (
    echo %RED%  [X] Falha ao gerar o .vsix%RESET%
    call :pause_if_interactive
    exit /b 1
)
call code --install-extension "%BUILD%\compose-colors.vsix" --force >nul 2>&1
if errorlevel 1 (echo %YELLOW%  [!] Falha ao instalar compose-colors%RESET%) else (echo %GREEN%  [OK] compose-colors%RESET%)

:: --- 3. configuracoes de usuario --------------------------------------------
echo %YELLOW%[3/4] Configuracoes de usuario%RESET%
if not exist "%USER_DIR%" mkdir "%USER_DIR%"
if not exist "%KOTLIN_TMP%" mkdir "%KOTLIN_TMP%"
if exist "%USER_DIR%\settings.json" (
    for /f %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMddHHmmss"') do copy /y "%USER_DIR%\settings.json" "%USER_DIR%\settings.json.bak.%%t" >nul
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0lib\merge-settings.ps1" -Path "%USER_DIR%\settings.json" -KotlinTmp "%KOTLIN_TMP%" -Jdk "%JDK%"
if errorlevel 1 (
    echo %RED%  [X] Falha ao atualizar settings.json%RESET%
    call :pause_if_interactive
    exit /b 1
)

:: --- 4. projeto (opcional) ---------------------------------------------------
if not "%PROJECT%"=="" (
    echo %YELLOW%[4/4] Projeto %PROJECT%%RESET%
    if not exist "%PROJECT%\" (
        echo %RED%  [X] Diretorio nao existe: %PROJECT%%RESET%
        call :pause_if_interactive
        exit /b 1
    )
    set "SDK=%ANDROID_HOME%"
    if not defined SDK set "SDK=%ANDROID_SDK_ROOT%"
    if not defined SDK set "SDK=%LOCALAPPDATA%\Android\Sdk"
    setlocal EnableDelayedExpansion
    if exist "!SDK!\" (
        set "SDK=!SDK:\=/!"
        findstr /b /c:"sdk.dir=" "%PROJECT%\local.properties" >nul 2>&1
        if errorlevel 1 (
            >>"%PROJECT%\local.properties" echo sdk.dir=!SDK!
            echo %GREEN%  [OK] local.properties: sdk.dir=!SDK!%RESET%
        )
    )
    endlocal
) else (
    echo %YELLOW%[4/4] Projeto%RESET% %WHITE%(nenhum informado, pulando)%RESET%
)

echo.
echo %GREEN%  [OK] Pronto. FECHE o VS Code por completo e abra de novo; depois abra um .kt e aguarde o import do Gradle.%RESET%
call :pause_if_interactive
exit /b 0

:pause_if_interactive
echo %CMDCMDLINE% | findstr /i /c:"/c" >nul && pause
exit /b 0
