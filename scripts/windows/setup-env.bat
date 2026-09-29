@echo off
:: Verifica e configura o ambiente Android (JDK, SDK, ADB, Gradle) e instala
:: as extensoes do VS Code para Kotlin + Jetpack Compose.
::
:: Uso: scripts\windows\setup-env.bat [PROJECT_DIR]
::   PROJECT_DIR  projeto Android a validar (padrao: diretorio atual)
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
call "%~dp0lib\colors.bat"

set "TEMPLATES_DIR=%~dp0..\..\templates"
set "PROJECT_DIR=%~1"
if "%PROJECT_DIR%"=="" set "PROJECT_DIR=%CD%"
set /a ERRORS=0

echo.
echo %CYAN%== Setup Android - Kotlin + Jetpack Compose ==%RESET%
echo.

:: --- 1. JDK ----------------------------------------------------------------
echo %YELLOW%[1/7] JDK%RESET%
where java >nul 2>&1
if errorlevel 1 (
    echo %RED%  [X] java nao encontrado. Instale o JDK 17: https://adoptium.net%RESET%
    set /a ERRORS+=1
) else (
    for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do echo %GREEN%  [OK] Java %%~v%RESET%
    where javac >nul 2>&1
    if errorlevel 1 (
        echo %YELLOW%  [!] javac ausente ^(apenas JRE^). Instale um JDK completo.%RESET%
    ) else (
        for /f "tokens=*" %%v in ('javac -version 2^>^&1') do echo %GREEN%  [OK] %%v%RESET%
    )
    if defined JAVA_HOME (echo %GREEN%  [OK] JAVA_HOME = !JAVA_HOME!%RESET%) else (echo %WHITE%    JAVA_HOME nao definido ^(recomendado no Windows^)%RESET%)
)

:: --- 2. Kotlin (opcional) --------------------------------------------------
echo %YELLOW%[2/7] Kotlin CLI (opcional)%RESET%
where kotlinc >nul 2>&1
if errorlevel 1 (
    echo %WHITE%    kotlinc nao instalado - normal: o Kotlin e gerenciado pelo Gradle.%RESET%
) else (
    echo %GREEN%  [OK] kotlinc encontrado%RESET%
)

:: --- 3. ANDROID_HOME -------------------------------------------------------
echo %YELLOW%[3/7] ANDROID_HOME%RESET%
if not defined ANDROID_HOME (
    set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
    setx ANDROID_HOME "!ANDROID_HOME!" >nul
    echo %YELLOW%  [!] ANDROID_HOME nao definido - gravado como !ANDROID_HOME! ^(variavel de usuario^)%RESET%
) else (
    echo %GREEN%  [OK] ANDROID_HOME = %ANDROID_HOME%%RESET%
)
if not exist "%ANDROID_HOME%" (
    echo %RED%  [X] Diretorio do SDK nao existe. Instale via Android Studio ^> SDK Manager.%RESET%
    set /a ERRORS+=1
)

:: --- 4. Componentes do SDK + PATH do usuario -------------------------------
echo %YELLOW%[4/7] Componentes do Android SDK%RESET%
for %%t in (platform-tools emulator cmdline-tools\latest\bin build-tools platforms) do (
    if exist "%ANDROID_HOME%\%%t" (echo %GREEN%  [OK] %%t%RESET%) else (echo %YELLOW%  [!] %%t ausente em %ANDROID_HOME%\%%t%RESET%)
)
:: Atualiza somente o PATH do USUARIO, sem duplicar entradas e sem o limite de
:: 1024 caracteres do setx (que truncaria o PATH).
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$sdk=$env:ANDROID_HOME; $want=@('platform-tools','emulator','cmdline-tools\latest\bin') | ForEach-Object { Join-Path $sdk $_ };" ^
  "$cur=[Environment]::GetEnvironmentVariable('Path','User'); $parts=@(); if ($cur) { $parts=@($cur -split ';' | Where-Object { $_ }) };" ^
  "$add=@($want | Where-Object { $parts -notcontains $_ });" ^
  "if ($add.Count) { [Environment]::SetEnvironmentVariable('Path', (($parts + $add) -join ';'), 'User'); $add | ForEach-Object { Write-Host ('    PATH += ' + $_) } }" ^
  "else { Write-Host '    PATH do usuario ja contem as ferramentas do SDK' }"
set "PATH=%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\emulator;%ANDROID_HOME%\cmdline-tools\latest\bin"

:: --- 5. ADB ----------------------------------------------------------------
echo %YELLOW%[5/7] ADB%RESET%
where adb >nul 2>&1
if errorlevel 1 (
    echo %RED%  [X] adb nao encontrado ^(instale SDK Platform-Tools^)%RESET%
    set /a ERRORS+=1
) else (
    for /f "tokens=*" %%v in ('adb --version 2^>^&1 ^| findstr /i "Bridge"') do echo %GREEN%  [OK] %%v%RESET%
)

:: --- 6. Gradle Wrapper -----------------------------------------------------
echo %YELLOW%[6/7] Gradle Wrapper em %PROJECT_DIR%%RESET%
if exist "%PROJECT_DIR%\gradlew.bat" (
    pushd "%PROJECT_DIR%"
    for /f "tokens=*" %%v in ('call gradlew.bat --version 2^>nul ^| findstr /b "Gradle"') do echo %GREEN%  [OK] %%v%RESET%
    if exist "gradle\libs.versions.toml" (
        echo %GREEN%  [OK] Version catalog: gradle\libs.versions.toml%RESET%
    ) else (
        echo %WHITE%    Sem version catalog - modelo em templates\gradle\libs.versions.toml%RESET%
    )
    popd
) else (
    echo %WHITE%    gradlew.bat nao encontrado ^(execute dentro do projeto ou passe PROJECT_DIR^)%RESET%
)

:: --- 7. Dispositivos -------------------------------------------------------
echo %YELLOW%[7/7] Dispositivos conectados%RESET%
where adb >nul 2>&1 && adb devices -l

:: --- Extensoes VS Code -----------------------------------------------------
echo.
echo %CYAN%== Extensoes VS Code ==%RESET%
where code >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%  [!] CLI 'code' nao esta no PATH - instale as extensoes de templates\vscode\extensions.json manualmente%RESET%
) else (
    call code --uninstall-extension fwcd.kotlin >nul 2>&1
    for /f "usebackq tokens=*" %%e in (`powershell -NoProfile -Command "(Get-Content -Raw '%TEMPLATES_DIR%\vscode\extensions.json' | ConvertFrom-Json).recommendations"`) do (
        call code --install-extension %%e --force >nul 2>&1
        if errorlevel 1 (echo %YELLOW%  [!] Falha ao instalar %%e%RESET%) else (echo %GREEN%  [OK] %%e%RESET%)
    )
)

echo.
echo %CYAN%== Dependencias ==%RESET%
echo %WHITE%    Version catalog:          templates\gradle\libs.versions.toml%RESET%
echo %WHITE%    Exemplo build.gradle.kts: templates\gradle\app.build.gradle.kts%RESET%
echo %WHITE%    Documentacao:             docs\reference\gradle-compose.md%RESET%
echo %WHITE%    Abra um NOVO terminal para que ANDROID_HOME/PATH tenham efeito.%RESET%
echo.

if %ERRORS% gtr 0 (
    echo %RED%  [X] Setup concluido com %ERRORS% erro^(s^).%RESET%
    call :pause_if_interactive
    exit /b 1
)
echo %GREEN%  [OK] Setup concluido.%RESET%
call :pause_if_interactive
exit /b 0

:pause_if_interactive
:: Pausa apenas quando aberto por duplo clique (cmd /c).
echo %CMDCMDLINE% | findstr /i /c:"/c" >nul && pause
exit /b 0
