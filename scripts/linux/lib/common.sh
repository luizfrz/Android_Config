#!/usr/bin/env bash
# Funções compartilhadas pelos scripts em scripts/linux/.
# Uso: source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

# Cores apenas quando stdout é um terminal (saída limpa em pipes/CI).
if [[ -t 1 ]]; then
    RED=$'\033[91m'; GREEN=$'\033[92m'; YELLOW=$'\033[93m'
    MAGENTA=$'\033[95m'; CYAN=$'\033[96m'; WHITE=$'\033[97m'; RESET=$'\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; MAGENTA=''; CYAN=''; WHITE=''; RESET=''
fi
export RED GREEN YELLOW MAGENTA CYAN WHITE RESET

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TEMPLATES_DIR="$REPO_ROOT/templates"
export REPO_ROOT TEMPLATES_DIR

header() { printf '\n%s== %s ==%s\n\n' "$CYAN" "$1" "$RESET"; }
step()   { printf '%s[%s] %s%s\n' "$YELLOW" "$1" "$2" "$RESET"; }
ok()     { printf '%s  ✓ %s%s\n' "$GREEN" "$*" "$RESET"; }
warn()   { printf '%s  ⚠ %s%s\n' "$YELLOW" "$*" "$RESET"; }
fail()   { printf '%s  ✗ %s%s\n' "$RED" "$*" "$RESET" >&2; }
info()   { printf '%s    %s%s\n' "$WHITE" "$*" "$RESET"; }
die()    { fail "$*"; exit 1; }

has() { command -v "$1" >/dev/null 2>&1; }

# Copia um arquivo; se o destino existir e for diferente, cria backup .bak.<timestamp>.
install_file() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [[ -f "$dst" ]] && ! cmp -s "$src" "$dst"; then
        local bak
        bak="$dst.bak.$(date +%Y%m%d%H%M%S)"
        cp "$dst" "$bak"
        warn "$dst já existia — backup em $bak"
    fi
    cp "$src" "$dst"
}
