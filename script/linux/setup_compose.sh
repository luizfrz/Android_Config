#!/bin/bash
set -e

RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
MAGENTA='\033[95m'
CYAN='\033[96m'
WHITE='\033[97m'
RESET='\033[0m'

clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║     Kotlin + Jetpack Compose - Setup Android         ║${RESET}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
echo

# ─── Java ────────────────────────────────────────────────────────────────────
echo -e "${YELLOW}[1/7] Verificando Java...${RESET}"
if ! java -version &>/dev/null; then
    echo -e "${RED}  ✗ Java nao encontrado. Instale o JDK 17:${RESET}"
    echo -e "${WHITE}    https://adoptium.net${RESET}"
else
    VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo -e "${GREEN}  ✓ Java encontrado: $VERSION${RESET}"
fi
echo

# ─── Kotlin ──────────────────────────────────────────────────────────────────
echo -e "${YELLOW}[2/7] Verificando Kotlin...${RESET}"
if ! kotlinc -version &>/dev/null; then
    echo -e "${YELLOW}  ⚠ kotlinc nao encontrado globalmente (normal em projetos Android).${RESET}"
    echo -e "${WHITE}    O Kotlin e gerenciado pelo Gradle no projeto Android.${RESET}"
else
    KOTLIN_VERSION=$(kotlinc -version 2>&1 | head -n 1)
    echo -e "${GREEN}  ✓ Kotlin encontrado: $KOTLIN_VERSION${RESET}"
fi
echo

# ─── ADB ─────────────────────────────────────────────────────────────────────
echo -e "${YELLOW}[3/7] Verificando ADB...${RESET}"
if ! adb --version &>/dev/null; then
    echo -e "${RED}  ✗ ADB nao encontrado. Verifique o Android SDK.${RESET}"
else
    ADB_VERSION=$(adb --version | head -n 1)
    echo -e "${GREEN}  ✓ $ADB_VERSION${RESET}"
fi
echo

# ─── ANDROID_HOME ────────────────────────────────────────────────────────────
echo -e "${YELLOW}[4/7] Verificando ANDROID_HOME...${RESET}"
if [ -z "$ANDROID_HOME" ]; then
    echo -e "${RED}  ✗ ANDROID_HOME nao definido.${RESET}"
    # Detectar arquivo RC do usuario (bash/zsh)
    if [ -n "${ZSH_VERSION-}" ] || [[ "$SHELL" == *"zsh"* ]]; then
        RC_FILE="$HOME/.zshrc"
    else
        RC_FILE="$HOME/.bashrc"
    fi
    echo -e "${WHITE}    Adicionando sugerido ao $RC_FILE (se nao existir) ...${RESET}"
    if ! grep -q "ANDROID_HOME" "$RC_FILE" 2>/dev/null; then
        {
            echo ''
            echo '# Android SDK'
            echo 'export ANDROID_HOME=$HOME/Android/Sdk'
            echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools'
            echo 'export PATH=$PATH:$ANDROID_HOME/emulator'
            echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin'
        } >> "$RC_FILE"
        echo -e "${GREEN}  ✓ Entradas adicionadas em: $RC_FILE${RESET}"
    else
        echo -e "${YELLOW}  ⚠ $RC_FILE já contém ANDROID_HOME. Nenhuma alteração feita.${RESET}"
    fi
    export ANDROID_HOME=$HOME/Android/Sdk
    echo -e "${GREEN}  ✓ ANDROID_HOME definido (temporario): $ANDROID_HOME${RESET}"
    echo -e "${WHITE}    Para tornar permanente: source $RC_FILE${RESET}"
else
    echo -e "${GREEN}  ✓ ANDROID_HOME = $ANDROID_HOME${RESET}"
fi
echo

# ─── PATH ────────────────────────────────────────────────────────────────────
echo -e "${YELLOW}[5/7] Verificando PATH do Android SDK...${RESET}"
for TOOL in platform-tools emulator "cmdline-tools/latest/bin"; do
    TOOL_PATH="$ANDROID_HOME/$TOOL"
    if [ -d "$TOOL_PATH" ]; then
        echo -e "${GREEN}  ✓ $TOOL encontrado${RESET}"
    else
        echo -e "${YELLOW}  ⚠ $TOOL nao encontrado em $TOOL_PATH${RESET}"
    fi
done
echo

# ─── Gradle Wrapper ──────────────────────────────────────────────────────────
echo -e "${YELLOW}[6/7] Verificando Gradle Wrapper...${RESET}"
if [ -f "./gradlew" ]; then
    chmod +x ./gradlew
    GRADLE_VERSION=$(./gradlew --version 2>/dev/null | grep "Gradle" | head -n 1)
    echo -e "${GREEN}  ✓ gradlew encontrado e permissao concedida${RESET}"
    echo -e "${GREEN}  ✓ $GRADLE_VERSION${RESET}"
else
    echo -e "${RED}  ✗ gradlew nao encontrado nesta pasta.${RESET}"
    echo -e "${WHITE}    Execute este script dentro da pasta do projeto.${RESET}"
fi
echo

# ─── Dispositivos ────────────────────────────────────────────────────────────
echo -e "${YELLOW}[7/7] Dispositivos conectados:${RESET}"
adb devices 2>/dev/null
echo

# ─── Dependencias Compose ────────────────────────────────────────────────────
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║         Dependencias Jetpack Compose                 ║${RESET}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
echo
echo -e "${MAGENTA}  app/build.gradle.kts:${RESET}"
echo
echo -e "${WHITE}  android {${RESET}"
echo -e "${WHITE}      buildFeatures { compose = true }${RESET}"
echo -e "${WHITE}      composeOptions {${RESET}"
echo -e "${WHITE}          kotlinCompilerExtensionVersion = \"1.5.11\"${RESET}"
echo -e "${WHITE}      }${RESET}"
echo -e "${WHITE}  }${RESET}"
echo
echo -e "${WHITE}  dependencies {${RESET}"
echo -e "${GREEN}      // BOM - gerencia versoes automaticamente${RESET}"
echo -e "${WHITE}      implementation(platform(\"androidx.compose:compose-bom:2024.05.00\"))${RESET}"
echo -e "${GREEN}      // UI Core${RESET}"
echo -e "${WHITE}      implementation(\"androidx.compose.ui:ui\")${RESET}"
echo -e "${WHITE}      implementation(\"androidx.compose.ui:ui-tooling-preview\")${RESET}"
echo -e "${GREEN}      // Material 3${RESET}"
echo -e "${WHITE}      implementation(\"androidx.compose.material3:material3\")${RESET}"
echo -e "${GREEN}      // Activity Compose${RESET}"
echo -e "${WHITE}      implementation(\"androidx.activity:activity-compose:1.9.0\")${RESET}"
echo -e "${GREEN}      // ViewModel${RESET}"
echo -e "${WHITE}      implementation(\"androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0\")${RESET}"
echo -e "${GREEN}      // Navigation${RESET}"
echo -e "${WHITE}      implementation(\"androidx.navigation:navigation-compose:2.7.7\")${RESET}"
echo -e "${GREEN}      // Hilt (injecao de dependencia)${RESET}"
echo -e "${WHITE}      implementation(\"com.google.dagger:hilt-android:2.51\")${RESET}"
echo -e "${GREEN}      // Coil (carregamento de imagens)${RESET}"
echo -e "${WHITE}      implementation(\"io.coil-kt:coil-compose:2.6.0\")${RESET}"
echo -e "${GREEN}      // Coroutines${RESET}"
echo -e "${WHITE}      implementation(\"org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.0\")${RESET}"
echo -e "${GREEN}      // Room (banco de dados local)${RESET}"
echo -e "${WHITE}      implementation(\"androidx.room:room-runtime:2.6.1\")${RESET}"
echo -e "${WHITE}      implementation(\"androidx.room:room-ktx:2.6.1\")${RESET}"
echo -e "${GREEN}      // Retrofit (requisicoes HTTP)${RESET}"
echo -e "${WHITE}      implementation(\"com.squareup.retrofit2:retrofit:2.11.0\")${RESET}"
echo -e "${WHITE}      implementation(\"com.squareup.retrofit2:converter-gson:2.11.0\")${RESET}"
echo -e "${GREEN}      // Debug${RESET}"
echo -e "${WHITE}      debugImplementation(\"androidx.compose.ui:ui-tooling\")${RESET}"
echo -e "${WHITE}      debugImplementation(\"androidx.compose.ui:ui-test-manifest\")${RESET}"
echo -e "${WHITE}  }${RESET}"
echo

# ─── Extensoes VS Code ───────────────────────────────────────────────────────
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║           Extensoes VS Code                          ║${RESET}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
echo
echo -e "${MAGENTA}  Kotlin:${RESET}"
echo -e "${WHITE}    https://marketplace.visualstudio.com/items?itemName=mathiasfrohlich.Kotlin${RESET}"
echo -e "${MAGENTA}  Java Dependency:${RESET}"
echo -e "${WHITE}    https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-dependency${RESET}"
echo -e "${MAGENTA}  Java Test:${RESET}"
echo -e "${WHITE}    https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-test${RESET}"
echo -e "${MAGENTA}  Gradle for Java:${RESET}"
echo -e "${WHITE}    https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-gradle${RESET}"
echo -e "${MAGENTA}  Android Emulator:${RESET}"
echo -e "${WHITE}    https://marketplace.visualstudio.com/items?itemName=DiemasMichiels.emulate${RESET}"
echo

echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║              Setup concluido!                        ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${RESET}"
echo
read -p "Pressione Enter para sair..."
