#!/usr/bin/env bash
# Aplica a configuração de VS Code deste repositório a um projeto Android:
#   - instala extensões (templates/vscode/extensions.json)
#   - copia .vscode/settings.json, .vscode/extensions.json e .editorconfig
# Arquivos existentes e diferentes recebem backup .bak.<timestamp>.
#
# Uso: scripts/linux/configure-vscode.sh [PROJECT_DIR]
set -euo pipefail
# shellcheck source=lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

case "${1:-}" in -h|--help) sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac
PROJECT_DIR="${1:-$PWD}"
[[ -d "$PROJECT_DIR" ]] || die "Diretório não existe: $PROJECT_DIR"
[[ -f "$PROJECT_DIR/gradlew" ]] || warn "$PROJECT_DIR não parece um projeto Gradle (gradlew ausente)"

header "Configurar VS Code — Kotlin Android"

step 1/3 "VS Code CLI"
has code || die "CLI 'code' não encontrada. No VS Code: Ctrl+Shift+P > 'Shell Command: Install code command in PATH'"
ok "VS Code $(code --version | head -n 1)"

step 2/3 "Extensões"
code --uninstall-extension fwcd.kotlin >/dev/null 2>&1 || true
for EXT in $(grep -oE '"[A-Za-z0-9-]+\.[A-Za-z0-9.-]+"' "$TEMPLATES_DIR/vscode/extensions.json" | tr -d '"' | grep -v '^fwcd\.'); do
    if code --install-extension "$EXT" --force >/dev/null 2>&1; then ok "$EXT"; else warn "Falha ao instalar $EXT"; fi
done

step 3/3 "Arquivos de configuração em $PROJECT_DIR"
install_file "$TEMPLATES_DIR/vscode/settings.json"   "$PROJECT_DIR/.vscode/settings.json";   ok ".vscode/settings.json"
install_file "$TEMPLATES_DIR/vscode/extensions.json" "$PROJECT_DIR/.vscode/extensions.json"; ok ".vscode/extensions.json"
install_file "$TEMPLATES_DIR/editorconfig"           "$PROJECT_DIR/.editorconfig";           ok ".editorconfig"

echo
ok "Concluído. Recarregue a janela: Ctrl+Shift+P > Developer: Reload Window"
