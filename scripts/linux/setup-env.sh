#!/usr/bin/env bash
# Verifica e configura o ambiente de desenvolvimento Android (JDK, SDK, ADB, Gradle)
# e instala as extensões do VS Code para Kotlin + Jetpack Compose.
#
# Uso: scripts/linux/setup-env.sh [--no-rc] [--no-extensions] [PROJECT_DIR]
#   --no-rc          não altera ~/.bashrc / ~/.zshrc
#   --no-extensions  não instala extensões do VS Code
#   PROJECT_DIR      projeto Android a validar (padrão: diretório atual)
set -uo pipefail
# shellcheck source=lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

WRITE_RC=1
INSTALL_EXT=1
PROJECT_DIR="$PWD"
for arg in "$@"; do
    case "$arg" in
        --no-rc) WRITE_RC=0 ;;
        --no-extensions) INSTALL_EXT=0 ;;
        -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -*) die "Opção desconhecida: $arg" ;;
        *) PROJECT_DIR="$arg" ;;
    esac
done

REQUIRED_JDK=17
ERRORS=0

header "Setup Android — Kotlin + Jetpack Compose"

# --- 1. JDK ----------------------------------------------------------------
step 1/7 "JDK"
if ! has java; then
    fail "java não encontrado. Instale o JDK $REQUIRED_JDK (https://adoptium.net)"
    ERRORS=$((ERRORS + 1))
else
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    JAVA_MAJOR=${JAVA_VERSION%%.*}
    [[ "$JAVA_MAJOR" == "1" ]] && JAVA_MAJOR=$(cut -d. -f2 <<<"$JAVA_VERSION")
    if [[ "$JAVA_MAJOR" -ge "$REQUIRED_JDK" ]] 2>/dev/null; then
        ok "Java $JAVA_VERSION"
    else
        warn "Java $JAVA_VERSION — AGP 8.x requer JDK $REQUIRED_JDK+"
    fi
    if has javac; then
        ok "JDK: $(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")"
    else
        warn "javac ausente (apenas JRE). Instale um JDK completo."
    fi
    if [[ -n "${JAVA_HOME:-}" ]]; then
        ok "JAVA_HOME = $JAVA_HOME"
    else
        info "JAVA_HOME não definido (opcional se java estiver no PATH)"
    fi
fi

# --- 2. Kotlin (opcional) --------------------------------------------------
step 2/7 "Kotlin CLI (opcional)"
if has kotlinc; then
    ok "$(kotlinc -version 2>&1 | head -n 1)"
else
    info "kotlinc não instalado — normal: em projetos Android o Kotlin é gerenciado pelo Gradle."
fi

# --- 3. ANDROID_HOME ---------------------------------------------------------
step 3/7 "ANDROID_HOME"
DEFAULT_SDK="$HOME/Android/Sdk"
if [[ -z "${ANDROID_HOME:-}" ]]; then
    export ANDROID_HOME="${ANDROID_SDK_ROOT:-$DEFAULT_SDK}"
    warn "ANDROID_HOME não definido — usando $ANDROID_HOME nesta sessão"
    if [[ $WRITE_RC -eq 1 ]]; then
        case "${SHELL:-}" in
            *zsh) RC_FILE="$HOME/.zshrc" ;;
            *)    RC_FILE="$HOME/.bashrc" ;;
        esac
        if grep -q 'ANDROID_HOME' "$RC_FILE" 2>/dev/null; then
            info "$RC_FILE já referencia ANDROID_HOME — nenhuma alteração"
        else
            cat >> "$RC_FILE" <<'RC'

# Android SDK (adicionado por Android_Config/scripts/linux/setup-env.sh)
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin"
RC
            ok "Variáveis adicionadas em $RC_FILE (execute: source $RC_FILE)"
        fi
    fi
else
    ok "ANDROID_HOME = $ANDROID_HOME"
fi
[[ -d "$ANDROID_HOME" ]] || { fail "Diretório do SDK não existe: $ANDROID_HOME (instale via Android Studio > SDK Manager)"; ERRORS=$((ERRORS + 1)); }

# --- 4. Componentes do SDK ---------------------------------------------------
step 4/7 "Componentes do Android SDK"
for TOOL in platform-tools emulator cmdline-tools/latest/bin build-tools platforms; do
    if [[ -d "$ANDROID_HOME/$TOOL" ]]; then
        ok "$TOOL"
        case ":$PATH:" in *":$ANDROID_HOME/$TOOL:"*) ;; *)
            [[ "$TOOL" =~ ^(platform-tools|emulator|cmdline-tools/latest/bin)$ ]] && PATH="$PATH:$ANDROID_HOME/$TOOL" ;;
        esac
    else
        warn "$TOOL ausente em $ANDROID_HOME/$TOOL"
    fi
done
[[ -d "$ANDROID_HOME/platforms" ]] && info "Plataformas: $(find "$ANDROID_HOME/platforms" -mindepth 1 -maxdepth 1 -printf '%f ' 2>/dev/null)"

# --- 5. ADB ----------------------------------------------------------------
step 5/7 "ADB"
if has adb; then
    ok "$(adb --version | head -n 1)"
else
    fail "adb não encontrado (instale SDK Platform-Tools)"
    ERRORS=$((ERRORS + 1))
fi

# --- 6. Gradle Wrapper -------------------------------------------------------
step 6/7 "Gradle Wrapper em $PROJECT_DIR"
if [[ -f "$PROJECT_DIR/gradlew" ]]; then
    chmod +x "$PROJECT_DIR/gradlew"
    GRADLE_VERSION=$( (cd "$PROJECT_DIR" && ./gradlew --version 2>/dev/null) | grep -m1 '^Gradle' || true)
    ok "${GRADLE_VERSION:-gradlew encontrado (versão não detectada)}"
    if [[ -f "$PROJECT_DIR/gradle/libs.versions.toml" ]]; then
        ok "Version catalog: gradle/libs.versions.toml"
    else
        info "Sem version catalog — modelo em templates/gradle/libs.versions.toml"
    fi
else
    info "gradlew não encontrado (execute dentro de um projeto Android ou passe PROJECT_DIR)"
fi

# --- 7. Dispositivos ---------------------------------------------------------
step 7/7 "Dispositivos conectados"
if has adb; then adb devices -l; else info "(adb indisponível)"; fi

# --- Extensões VS Code -------------------------------------------------------
if [[ $INSTALL_EXT -eq 1 ]]; then
    header "Extensões VS Code"
    if has code; then
        code --uninstall-extension fwcd.kotlin >/dev/null 2>&1 || true
        for EXT in $(grep -oE '"[A-Za-z0-9-]+\.[A-Za-z0-9.-]+"' "$TEMPLATES_DIR/vscode/extensions.json" | tr -d '"' | grep -v '^fwcd\.'); do
            if code --install-extension "$EXT" --force >/dev/null 2>&1; then ok "$EXT"; else warn "Falha ao instalar $EXT"; fi
        done
    else
        warn "CLI 'code' não está no PATH — instale as extensões de templates/vscode/extensions.json manualmente"
    fi
fi

header "Dependências"
info "Version catalog: $TEMPLATES_DIR/gradle/libs.versions.toml"
info "Exemplo app/build.gradle.kts: $TEMPLATES_DIR/gradle/app.build.gradle.kts"
info "Documentação: $REPO_ROOT/docs/reference/gradle-compose.md"
echo

if [[ $ERRORS -gt 0 ]]; then
    fail "Setup concluído com $ERRORS erro(s)."
    exit 1
fi
ok "Setup concluído."
