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
echo %YELLOW%[1/6] Verificando Java...%RESET%
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%  ✗ Java nao encontrado. Instale o JDK 17:%RESET%
    echo %WHITE%    https://adoptium.net%RESET%
) else (
    for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do (
        echo %GREEN%  ✓ Java encontrado: %%v%RESET%
    )
)
echo.

:: ─── ADB ────────────────────────────────────────────────────────────────────
echo %YELLOW%[2/6] Verificando ADB...%RESET%
adb --version >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%  ✗ ADB nao encontrado. Verifique o Android SDK.%RESET%
) else (
    echo %GREEN%  ✓ ADB encontrado%RESET%
)
echo.

:: ─── ANDROID_HOME ───────────────────────────────────────────────────────────
echo %YELLOW%[3/6] Verificando ANDROID_HOME...%RESET%
if "%ANDROID_HOME%"=="" (
    echo %RED%  ✗ ANDROID_HOME nao definido.%RESET%
    echo %WHITE%    Adicionando automaticamente...%RESET%
    setx ANDROID_HOME "%LOCALAPPDATA%\Android\Sdk" >nul
    set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
    echo %GREEN%  ✓ ANDROID_HOME definido: %ANDROID_HOME%%RESET%
) else (
    echo %GREEN%  ✓ ANDROID_HOME = %ANDROID_HOME%%RESET%
)
echo.

:: ─── PATH ───────────────────────────────────────────────────────────────────
echo %YELLOW%[4/6] Configurando PATH do Android SDK...%RESET%
setx PATH "%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\emulator;%ANDROID_HOME%\cmdline-tools\latest\bin" >nul
echo %GREEN%  ✓ platform-tools adicionado%RESET%
echo %GREEN%  ✓ emulator adicionado%RESET%
echo %GREEN%  ✓ cmdline-tools adicionado%RESET%
echo.

:: ─── Gradle Wrapper ─────────────────────────────────────────────────────────
echo %YELLOW%[5/6] Verificando Gradle Wrapper...%RESET%
if exist "gradlew.bat" (
    echo %GREEN%  ✓ gradlew.bat encontrado%RESET%
) else (
    echo %RED%  ✗ gradlew.bat nao encontrado nesta pasta.%RESET%
    echo %WHITE%    Execute este script dentro da pasta do projeto.%RESET%
)
echo.

:: ─── Dispositivos ───────────────────────────────────────────────────────────
echo %YELLOW%[6/6] Dispositivos conectados:%RESET%
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
