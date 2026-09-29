#!/usr/bin/env bash
# Compila o APK (debug ou release) via Gradle Wrapper e, opcionalmente, instala via ADB.
#
# Uso: scripts/linux/build-apk.sh [opções] [PROJECT_DIR]
#   -r, --release    assembleRelease em vez de assembleDebug
#   -i, --install    instala sem perguntar
#   -n, --no-install não instala nem pergunta
#   --no-clean       pula ./gradlew clean
#   -s SERIAL        dispositivo alvo (equivale a ANDROID_SERIAL)
set -euo pipefail
# shellcheck source=lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

VARIANT=debug
INSTALL=ask
CLEAN=1
PROJECT_DIR="$PWD"
while [[ $# -gt 0 ]]; do
    case "$1" in
        -r|--release)    VARIANT=release ;;
        -i|--install)    INSTALL=yes ;;
        -n|--no-install) INSTALL=no ;;
        --no-clean)      CLEAN=0 ;;
        -s)              shift; export ANDROID_SERIAL="${1:?-s requer SERIAL}" ;;
        -h|--help)       sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -*)              die "Opção desconhecida: $1" ;;
        *)               PROJECT_DIR="$1" ;;
    esac
    shift
done

[[ -f "$PROJECT_DIR/gradlew" ]] || die "gradlew não encontrado em $PROJECT_DIR"
cd "$PROJECT_DIR"
chmod +x ./gradlew
TASK="assemble${VARIANT^}"

header "Build Android — $VARIANT"
ok "Projeto: $PWD"

if [[ $CLEAN -eq 1 ]]; then
    step 1/3 "./gradlew clean"
    ./gradlew clean
fi

step 2/3 "./gradlew $TASK"
if ! ./gradlew "$TASK"; then
    fail "BUILD FAILED"
    info "Diagnóstico: ./gradlew $TASK --stacktrace --info"
    exit 1
fi

step 3/3 "Localizando APK"
# Cobre módulos com nomes customizados e product flavors (apk/<flavor>/<variant>/).
APK=$(find . -type f -path "*/build/outputs/apk/*" -path "*/$VARIANT/*" -name '*.apk' -printf '%T@ %p\n' 2>/dev/null \
      | sort -rn | head -n 1 | cut -d' ' -f2-)
[[ -n "$APK" ]] || die "APK não encontrado em */build/outputs/apk/**/$VARIANT/"
ok "APK: $APK ($(du -h "$APK" | cut -f1))"

if [[ "$VARIANT" == release && "$APK" == *unsigned* ]]; then
    warn "APK release não assinado — configure signingConfigs para instalar."
    INSTALL=no
fi

if [[ "$INSTALL" == ask && -t 0 ]]; then
    has adb && adb devices -l
    read -rp "${YELLOW}Instalar o APK no dispositivo? [s/N] ${RESET}" REPLY
    [[ "$REPLY" =~ ^[sSyY]$ ]] && INSTALL=yes || INSTALL=no
fi

if [[ "$INSTALL" == yes ]]; then
    has adb || die "adb não encontrado no PATH"
    # -r: reinstala mantendo dados; -t: permite APKs de teste (debug)
    if adb install -r -t "$APK"; then ok "APK instalado"; else die "Falha em adb install"; fi
fi

echo
info "Outros comandos: ./gradlew installDebug | test | lint | assembleRelease | bundleRelease"
