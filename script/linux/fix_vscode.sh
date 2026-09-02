#!/bin/bash

RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
MAGENTA='\033[95m'
CYAN='\033[96m'
WHITE='\033[97m'
RESET='\033[0m'

clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║        Fix VS Code - Kotlin Android                  ║${RESET}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
echo

# ─── VS Code instalado ───────────────────────────────────────────────────────
echo -e "${YELLOW}[1/4] Verificando VS Code...${RESET}"
if ! command -v code &>/dev/null; then
    echo -e "${RED}  ✗ VS Code nao encontrado.${RESET}"
    echo -e "${WHITE}    Instale em: https://code.visualstudio.com${RESET}"
    exit 1
else
    CODE_VERSION=$(code --version | head -n 1)
    echo -e "${GREEN}  ✓ VS Code encontrado: $CODE_VERSION${RESET}"
fi
echo

# ─── Instalar extensoes ──────────────────────────────────────────────────────
echo -e "${YELLOW}[2/4] Instalando extensoes...${RESET}"

EXTENSIONS=(
    "mathiasfrohlich.Kotlin"
    "vscjava.vscode-java-dependency"
    "vscjava.vscode-java-test"
    "vscjava.vscode-gradle"
    "DiemasMichiels.emulate"
    "redhat.java"
    "vscjava.vscode-java-pack"
)

for EXT in "${EXTENSIONS[@]}"; do
    echo -e "${WHITE}    Instalando $EXT...${RESET}"
    code --install-extension "$EXT" --force &>/dev/null
    echo -e "${GREEN}  ✓ $EXT instalado${RESET}"
done
echo

# ─── Criar settings.json do projeto ─────────────────────────────────────────
echo -e "${YELLOW}[3/4] Configurando .vscode/settings.json...${RESET}"
mkdir -p .vscode
cat > .vscode/settings.json << EOF
{
    "java.configuration.updateBuildConfiguration": "automatic",
    "java.compile.nullAnalysis.mode": "automatic",
    "gradle.nestedProjects": true,
    "editor.formatOnSave": true,
    "editor.tabSize": 4,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "kotlin.languageServer.enabled": true,
    "kotlin.debugAdapter.enabled": true
}
EOF
echo -e "${GREEN}  ✓ .vscode/settings.json criado${RESET}"
echo

# ─── Criar .editorconfig ─────────────────────────────────────────────────────
echo -e "${YELLOW}[4/4] Criando .editorconfig...${RESET}"
cat > .editorconfig << EOF
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 4
trim_trailing_whitespace = true
insert_final_newline = true

[*.{kt,kts}]
indent_size = 4

[*.{xml,json,yml,yaml}]
indent_size = 2
EOF
echo -e "${GREEN}  ✓ .editorconfig criado${RESET}"
echo

echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║              Fix concluido!                          ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${RESET}"
echo
read -p "Pressione Enter para sair..."
