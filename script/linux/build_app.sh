#!/bin/bash
set -e

RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
CYAN='\033[96m'
WHITE='\033[97m'
RESET='\033[0m'

clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║            Building Android App                      ║${RESET}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
echo

# ─── Detectar pasta do projeto ───────────────────────────────────────────────
PROJECT_DIR="$(pwd)"
if [ ! -f "$PROJECT_DIR/gradlew" ]; then
    echo -e "${RED}  ✗ gradlew nao encontrado em: $PROJECT_DIR${RESET}"
    echo -e "${WHITE}    Execute este script dentro da pasta do projeto.${RESET}"
    exit 1
fi
echo -e "${GREEN}  ✓ Projeto encontrado: $PROJECT_DIR${RESET}"
echo

# ─── Limpar build anterior ───────────────────────────────────────────────────
echo -e "${YELLOW}[1/3] Limpando builds anteriores...${RESET}"
chmod +x ./gradlew
./gradlew clean
echo -e "${GREEN}  ✓ Limpeza concluida${RESET}"
echo

# ─── Build Debug APK ─────────────────────────────────────────────────────────
echo -e "${YELLOW}[2/3] Compilando APK Debug...${RESET}"
if ./gradlew assembleDebug; then
    echo
    echo -e "${YELLOW}[3/3] Verificando APK...${RESET}"
    APK=$(find app/build/outputs/apk/debug -name "*.apk" 2>/dev/null | head -n 1)
    if [ -n "$APK" ]; then
        echo -e "${GREEN}  ✓ BUILD SUCCESSFUL!${RESET}"
        echo -e "${GREEN}  ✓ APK gerado em: $APK${RESET}"
    else
        echo -e "${RED}  ✗ APK nao encontrado.${RESET}"
        exit 1
    fi
else
    echo -e "${RED}  ✗ BUILD FAILED!${RESET}"
    echo -e "${WHITE}    Execute para ver detalhes:${RESET}"
    echo -e "${WHITE}      ./gradlew assembleDebug --stacktrace${RESET}"
    exit 1
fi
echo

# ─── Instalar no dispositivo ─────────────────────────────────────────────────
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║           Instalar no Dispositivo                    ║${RESET}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
echo
adb devices 2>/dev/null
echo
read -p "$(echo -e "${YELLOW}Deseja instalar o APK no dispositivo? (s/n): ${RESET}")" INSTALAR
if [[ "$INSTALAR" =~ ^[sS]$ ]]; then
    if adb install "$APK"; then
        echo -e "${GREEN}  ✓ APK instalado com sucesso!${RESET}"
    else
        echo -e "${RED}  ✗ Erro ao instalar o APK.${RESET}"
    fi
fi
echo

# ─── Outros comandos uteis ───────────────────────────────────────────────────
echo -e "${WHITE}  Outros comandos uteis:${RESET}"
echo -e "${WHITE}    ./gradlew assembleRelease    # Build versao Release${RESET}"
echo -e "${WHITE}    ./gradlew installDebug       # Instala no dispositivo conectado${RESET}"
echo -e "${WHITE}    ./gradlew build              # Build completo com testes${RESET}"
echo -e "${WHITE}    ./gradlew test               # Executa testes unitarios${RESET}"
echo -e "${WHITE}    ./gradlew lint               # Analisa qualidade do codigo${RESET}"
echo
read -p "Pressione Enter para sair..."
