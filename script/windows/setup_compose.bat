@echo off
setlocal enabledelayedexpansion

set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "MAGENTA=[95m"
set "CYAN=[96m"
set "WHITE=[97m"
set "RESET=[0m"

cls
echo %CYAN%╔══════════════════════════════════════════════════════╗%RESET%
echo %CYAN%║     Kotlin + Jetpack Compose - Setup Android         ║%RESET%
echo %CYAN%╚══════════════════════════════════════════════════════╝%RESET%
echo.

:: ─── Java ───────────────────────────────────────────────────────────────────
echo %YELLOW%[1/7] Verificando Java...%RESET%
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%  ✗ Java nao encontrado. Instale o JDK 17:%RESET%
    echo %WHITE%    https://adoptium.net%RESET%
) else (
    for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do (
        echo %GREEN%  ✓ Java encontrado: %%v%RESET%
    )
    javac -version >nul 2>&1
    if errorlevel 1 (
        echo %YELLOW%  ⚠ javac nao encontrado: instale um JDK completo para Gradle/Android.%RESET%
    ) else (
        for /f "tokens=*" %%v in ('javac -version 2^>^&1') do echo %GREEN%  ✓ JDK completo encontrado: %%v%RESET%
    )
)
echo.

:: ─── Kotlin ──────────────────────────────────────────────────────────────────
echo %YELLOW%[2/7] Verificando Kotlin...%RESET%
kotlinc -version >nul 2>&1
if %errorlevel% neq 0 (
    echo %YELLOW%  ⚠ kotlinc nao encontrado globalmente (normal em projetos Android).%RESET%
    echo %WHITE%    O Kotlin e gerenciado pelo Gradle no projeto Android.%RESET%
) else (
    echo %GREEN%  ✓ Kotlin encontrado%RESET%
)
echo.

:: ─── ADB ────────────────────────────────────────────────────────────────────
echo %YELLOW%[3/7] Verificando ADB...%RESET%
adb --version >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%  ✗ ADB nao encontrado. Verifique o Android SDK.%RESET%
) else (
    for /f "tokens=1,2,3" %%a in ('adb --version 2^>^&1 ^| findstr /i "version"') do (
        echo %GREEN%  ✓ ADB encontrado: %%a %%b %%c%RESET%
    )
)
echo.

:: ─── ANDROID_HOME ───────────────────────────────────────────────────────────
echo %YELLOW%[4/7] Verificando ANDROID_HOME...%RESET%
if "%ANDROID_HOME%"=="" (
    echo %RED%  ✗ ANDROID_HOME nao definido.%RESET%
    echo %WHITE%    Adicionando automaticamente...%RESET%
    setx ANDROID_HOME "%LOCALAPPDATA%\Android\Sdk" >nul
    set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
    echo %GREEN%  ✓ ANDROID_HOME definido: %ANDROID_HOME%%RESET%
    echo %WHITE%    A variavel foi salva permanentemente para novos terminais.%RESET%
) else (
    echo %GREEN%  ✓ ANDROID_HOME = %ANDROID_HOME%%RESET%
)
echo.

:: ─── PATH e pastas do SDK ────────────────────────────────────────────────────
echo %YELLOW%[5/7] Verificando pastas do Android SDK...%RESET%
setx PATH "%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\emulator;%ANDROID_HOME%\cmdline-tools\latest\bin" >nul
set "PATH=%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\emulator;%ANDROID_HOME%\cmdline-tools\latest\bin"

if exist "%ANDROID_HOME%\platform-tools" (
    echo %GREEN%  ✓ platform-tools encontrado%RESET%
) else (
    echo %YELLOW%  ⚠ platform-tools nao encontrado em %ANDROID_HOME%\platform-tools%RESET%
)
if exist "%ANDROID_HOME%\emulator" (
    echo %GREEN%  ✓ emulator encontrado%RESET%
) else (
    echo %YELLOW%  ⚠ emulator nao encontrado em %ANDROID_HOME%\emulator%RESET%
)
if exist "%ANDROID_HOME%\cmdline-tools\latest\bin" (
    echo %GREEN%  ✓ cmdline-tools encontrado%RESET%
) else (
    echo %YELLOW%  ⚠ cmdline-tools nao encontrado em %ANDROID_HOME%\cmdline-tools\latest\bin%RESET%
)
echo.

:: ─── Gradle Wrapper ─────────────────────────────────────────────────────────
echo %YELLOW%[6/7] Verificando Gradle Wrapper...%RESET%
if exist "gradlew.bat" (
    for /f "tokens=*" %%v in ('call gradlew.bat --version 2^>nul ^| findstr /i "Gradle"') do (
        echo %GREEN%  ✓ %%v%RESET%
    )
) else (
    echo %RED%  ✗ gradlew.bat nao encontrado nesta pasta.%RESET%
    echo %WHITE%    Execute este script dentro da pasta do projeto.%RESET%
)
echo.

:: ─── Dispositivos ───────────────────────────────────────────────────────────
echo %YELLOW%[7/7] Dispositivos conectados:%RESET%
adb devices 2>nul
echo.

:: ─── Dependencias Compose ───────────────────────────────────────────────────
echo %CYAN%╔══════════════════════════════════════════════════════╗%RESET%
echo %CYAN%║         Dependencias Jetpack Compose                 ║%RESET%
echo %CYAN%╚══════════════════════════════════════════════════════╝%RESET%
echo.
echo %MAGENTA%  app/build.gradle.kts:%RESET%
echo.
echo %WHITE%  android {%RESET%
echo %WHITE%      buildFeatures { compose = true }%RESET%
echo %WHITE%      composeOptions {%RESET%
echo %WHITE%          kotlinCompilerExtensionVersion = "1.5.11"%RESET%
echo %WHITE%      }%RESET%
echo %WHITE%  }%RESET%
echo.
echo %WHITE%  dependencies {%RESET%
echo %GREEN%      // BOM - gerencia versoes automaticamente%RESET%
echo %WHITE%      implementation(platform("androidx.compose:compose-bom:2024.05.00"))%RESET%
echo %GREEN%      // UI Core%RESET%
echo %WHITE%      implementation("androidx.compose.ui:ui")%RESET%
echo %WHITE%      implementation("androidx.compose.ui:ui-tooling-preview")%RESET%
echo %GREEN%      // Material 3%RESET%
echo %WHITE%      implementation("androidx.compose.material3:material3")%RESET%
echo %GREEN%      // Activity Compose%RESET%
echo %WHITE%      implementation("androidx.activity:activity-compose:1.9.0")%RESET%
echo %GREEN%      // ViewModel%RESET%
echo %WHITE%      implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")%RESET%
echo %GREEN%      // Navigation%RESET%
echo %WHITE%      implementation("androidx.navigation:navigation-compose:2.7.7")%RESET%
echo %GREEN%      // Hilt (injecao de dependencia)%RESET%
echo %WHITE%      implementation("com.google.dagger:hilt-android:2.51")%RESET%
echo %GREEN%      // Coil (carregamento de imagens)%RESET%
echo %WHITE%      implementation("io.coil-kt:coil-compose:2.6.0")%RESET%
echo %GREEN%      // Coroutines%RESET%
echo %WHITE%      implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.0")%RESET%
echo %GREEN%      // Room (banco de dados local)%RESET%
echo %WHITE%      implementation("androidx.room:room-runtime:2.6.1")%RESET%
echo %WHITE%      implementation("androidx.room:room-ktx:2.6.1")%RESET%
echo %GREEN%      // Retrofit (requisicoes HTTP)%RESET%
echo %WHITE%      implementation("com.squareup.retrofit2:retrofit:2.11.0")%RESET%
echo %WHITE%      implementation("com.squareup.retrofit2:converter-gson:2.11.0")%RESET%
echo %GREEN%      // Debug%RESET%
echo %WHITE%      debugImplementation("androidx.compose.ui:ui-tooling")%RESET%
echo %WHITE%      debugImplementation("androidx.compose.ui:ui-test-manifest")%RESET%
echo %WHITE%  }%RESET%
echo.

:: ─── VS Code: colorizacao Kotlin + Jetpack Compose ──────────────────────────
echo %YELLOW%Configurando colorizacao global para Kotlin + Jetpack Compose...%RESET%
where code >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%  ⚠ Comando 'code' nao encontrado no PATH.%RESET%
    echo %WHITE%    Abra o VS Code e instale as extensoes listadas abaixo manualmente.%RESET%
) else (
    code --uninstall-extension fwcd.kotlin >nul 2>&1
    call :install_extension mathiasfrohlich.Kotlin
    call :install_extension vscjava.vscode-gradle
    call :install_extension vscjava.vscode-java-pack
    call :install_extension PKief.material-icon-theme
    echo %GREEN%  ✓ Arquivos .kt e .kts usam a linguagem Kotlin.%RESET%
    echo %WHITE%    Se necessario, use: Ctrl+Shift+P ^> Developer: Reload Window%RESET%
)
echo.

:: ─── Extensoes VS Code ──────────────────────────────────────────────────────
echo %CYAN%╔══════════════════════════════════════════════════════╗%RESET%
echo %CYAN%║           Extensoes VS Code                          ║%RESET%
echo %CYAN%╚══════════════════════════════════════════════════════╝%RESET%
echo.
echo %MAGENTA%  Kotlin:%RESET%
echo %WHITE%    https://marketplace.visualstudio.com/items?itemName=mathiasfrohlich.Kotlin%RESET%
echo %MAGENTA%  Java Dependency:%RESET%
echo %WHITE%    https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-dependency%RESET%
echo %MAGENTA%  Java Test:%RESET%
echo %WHITE%    https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-test%RESET%
echo %MAGENTA%  Gradle for Java:%RESET%
echo %WHITE%    https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-gradle%RESET%
echo %MAGENTA%  Android Emulator:%RESET%
echo %WHITE%    https://marketplace.visualstudio.com/items?itemName=DiemasMichiels.emulate%RESET%
echo.

echo %GREEN%╔══════════════════════════════════════════════════════╗%RESET%
echo %GREEN%║              Setup concluido!                        ║%RESET%
echo %GREEN%╚══════════════════════════════════════════════════════╝%RESET%
echo.
pause
exit /b 0

:install_extension
code --install-extension %~1 --force >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%  ⚠ Nao foi possivel instalar: %~1%RESET%
) else (
    echo %GREEN%  ✓ Extensao instalada: %~1%RESET%
)
exit /b 0
