#!/usr/bin/env bash
# Configura o VS Code (Flatpak ou nativo) como ambiente secundario para Kotlin / Jetpack Compose.
#
# Uso:  ./scripts/setup-vscode-kotlin.sh [diretorio-do-projeto-android]
#
# O que faz (idempotente):
#   1. Instala a extensao JetBrains Kotlin (LSP) + XML, TOML e EditorConfig; remove extensoes Kotlin conflitantes.
#   2. Gera e instala a extensao local "compose-colors" (quadradinhos de cor + gramatica de realce para Compose).
#   3. Mescla configuracoes de usuario (realce, formatter, cores de tokens, JDK, TMPDIR do servidor).
#   4. No Flatpak: define TMPDIR compartilhado (servidor LSP <-> Gradle do host).
#   5. Se informado um projeto: cria local.properties (sdk.dir) e .vscode/settings.json (terminal no host, no Flatpak).
# Depois de rodar: FECHE o VS Code por completo e abra de novo.
set -euo pipefail

PROJECT="${1:-}"
KOTLIN_TMP="$HOME/.cache/vscode-kotlin-tmp"
BUILD="$HOME/.cache/compose-colors-build"

# --- detecta VS Code ---------------------------------------------------------
if command -v flatpak >/dev/null 2>&1 && flatpak info com.visualstudio.code >/dev/null 2>&1; then
  MODE=flatpak
  CODE=(flatpak run com.visualstudio.code)
  USER_DIR="$HOME/.var/app/com.visualstudio.code/config/Code/User"
elif command -v code >/dev/null 2>&1; then
  MODE=native
  CODE=(code)
  USER_DIR="$HOME/.config/Code/User"
else
  echo "VS Code nao encontrado (nem Flatpak nem 'code' no PATH)." >&2; exit 1
fi
echo ">> VS Code: $MODE"

# --- JDK para resolucao de simbolos ------------------------------------------
JDK="$(ls -d "$HOME"/.gradle/jdks/*21* 2>/dev/null | grep -v -E '\.(lock|tar\.gz)$|reserved' | head -1 || true)"
[ -z "$JDK" ] && JDK="${JAVA_HOME:-}"
echo ">> JDK: ${JDK:-<nao encontrado; ignorando>}"

# --- 1. extensoes ------------------------------------------------------------
for ext in jetbrains.kotlin-server redhat.vscode-xml tamasfe.even-better-toml editorconfig.editorconfig; do
  "${CODE[@]}" --install-extension "$ext" 2>&1 | grep -E "successfully|already|Failed" || true
done
for ext in mathiasfrohlich.kotlin fwcd.kotlin; do
  "${CODE[@]}" --uninstall-extension "$ext" >/dev/null 2>&1 || true
done

# --- 2. extensao local compose-colors ---------------------------------------
rm -rf "$BUILD"; mkdir -p "$BUILD/extension/syntaxes"
cat > "$BUILD/extension/package.json" <<'EOF_PKG'
{
  "name": "compose-colors",
  "displayName": "Compose Colors",
  "description": "Color swatches and picker for Jetpack Compose Color(0xAARRGGBB) and Color.Red-style literals in Kotlin files.",
  "version": "0.0.2",
  "publisher": "local",
  "engines": {
    "vscode": "^1.80.0"
  },
  "categories": [
    "Other"
  ],
  "activationEvents": [
    "onLanguage:kotlin"
  ],
  "main": "./extension.js",
  "contributes": {
    "grammars": [
      {
        "scopeName": "source.kotlin.compose-injection",
        "path": "./syntaxes/compose.injection.json",
        "injectTo": [
          "source.kotlin"
        ]
      }
    ]
  }
}
EOF_PKG
cat > "$BUILD/extension/extension.js" <<'EOF_JS'
const vscode = require('vscode');

const NAMED = {
  Black: '000000', DarkGray: '444444', Gray: '888888', LightGray: 'CCCCCC', White: 'FFFFFF',
  Red: 'FF0000', Green: '00FF00', Blue: '0000FF', Yellow: 'FFFF00', Cyan: '00FFFF', Magenta: 'FF00FF',
};
const HEX_RE = /\bColor\(\s*(0[xX]([0-9A-Fa-f_]{6,10}))\s*\)/g;
const NAMED_RE = new RegExp('\\bColor\\.(' + Object.keys(NAMED).join('|') + ')\\b', 'g');

function toColor(argbHex) {
  const h = argbHex.replace(/_/g, '').padStart(8, '0');
  const a = parseInt(h.slice(0, 2), 16) / 255;
  return new vscode.Color(parseInt(h.slice(2, 4), 16) / 255, parseInt(h.slice(4, 6), 16) / 255, parseInt(h.slice(6, 8), 16) / 255, a);
}

const hex2 = (v) => Math.round(v * 255).toString(16).toUpperCase().padStart(2, '0');

function activate(context) {
  const provider = {
    provideDocumentColors(doc) {
      const text = doc.getText();
      const out = [];
      let m;
      HEX_RE.lastIndex = 0;
      while ((m = HEX_RE.exec(text))) {
        const start = m.index + m[0].indexOf(m[1]);
        out.push(new vscode.ColorInformation(new vscode.Range(doc.positionAt(start), doc.positionAt(start + m[1].length)), toColor(m[2])));
      }
      NAMED_RE.lastIndex = 0;
      while ((m = NAMED_RE.exec(text))) {
        out.push(new vscode.ColorInformation(new vscode.Range(doc.positionAt(m.index), doc.positionAt(m.index + m[0].length)), toColor('FF' + NAMED[m[1]])));
      }
      return out;
    },
    provideColorPresentations(color, ctx) {
      const orig = ctx.document.getText(ctx.range);
      if (/^Color\./.test(orig)) return []; // named colors are not rewritten
      const label = `0x${hex2(color.alpha)}${hex2(color.red)}${hex2(color.green)}${hex2(color.blue)}`;
      return [new vscode.ColorPresentation(label)];
    },
  };
  context.subscriptions.push(vscode.languages.registerColorProvider({ language: 'kotlin' }, provider));
}

module.exports = { activate };
EOF_JS
cat > "$BUILD/extension/syntaxes/compose.injection.json" <<'EOF_INJ'
{
  "scopeName": "source.kotlin.compose-injection",
  "injectionSelector": "L:source.kotlin -comment -string",
  "patterns": [
    { "name": "entity.name.function.annotation.kotlin", "match": "(?<=@)[A-Za-z_]\\w*(?::[A-Za-z_]\\w*)?" },
    { "match": "\\b(fun)\\s+(?:[A-Za-z_][\\w.<>]*\\.)?([A-Z]\\w*)\\b", "captures": { "1": { "name": "storage.type.kotlin" }, "2": { "name": "entity.name.function.composable.kotlin" } } },
    { "match": "\\b(fun)\\s+(?:[A-Za-z_][\\w.<>]*\\.)?([a-z_]\\w*)\\b", "captures": { "1": { "name": "storage.type.kotlin" }, "2": { "name": "entity.name.function.declaration.kotlin" } } },
    { "name": "entity.name.function.composable.kotlin", "match": "\\b[A-Z][A-Za-z0-9_]*(?=\\s*(?:<[^>]*>)?\\s*[({])" },
    { "name": "variable.parameter.named-argument.kotlin", "match": "\\b[a-z_]\\w*(?=\\s*=(?!=))" },
    { "name": "entity.name.function.call.kotlin", "match": "\\b[a-z_]\\w*(?=\\s*(?:<[^>]*>)?\\s*[({])" },
    { "name": "variable.other.property.kotlin", "match": "(?<=\\.)[a-z_]\\w*\\b" },
    { "name": "entity.name.type.kotlin", "match": "\\b[A-Z][A-Za-z0-9_]*\\b" },
    { "name": "constant.other.kotlin", "match": "\\b[A-Z][A-Z0-9_]{2,}\\b" }
  ]
}
EOF_INJ
cat > "$BUILD/[Content_Types].xml" <<'EOF_CT'
<?xml version="1.0" encoding="utf-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension=".json" ContentType="application/json"/><Default Extension=".js" ContentType="application/javascript"/><Default Extension=".vsixmanifest" ContentType="text/xml"/></Types>
EOF_CT
cat > "$BUILD/extension.vsixmanifest" <<'EOF_MF'
<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011">
  <Metadata>
    <Identity Language="en-US" Id="compose-colors" Version="0.0.2" Publisher="local"/>
    <DisplayName>Compose Colors</DisplayName>
    <Description xml:space="preserve">Color swatches and syntax highlighting for Jetpack Compose in Kotlin.</Description>
  </Metadata>
  <Installation><InstallationTarget Id="Microsoft.VisualStudio.Code"/></Installation>
  <Assets><Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true"/></Assets>
</PackageManifest>
EOF_MF
( cd "$BUILD" && python3 -c "
import zipfile,os
z=zipfile.ZipFile('compose-colors.vsix','w',zipfile.ZIP_DEFLATED)
for r,_,fs in os.walk('.'):
    for f in fs:
        p=os.path.join(r,f)[2:]
        if p!='compose-colors.vsix': z.write(p,p)
z.close()" )
# o /tmp do Flatpak e privado: o .vsix precisa estar sob $HOME (ja esta em ~/.cache)
"${CODE[@]}" --install-extension "$BUILD/compose-colors.vsix" --force 2>&1 | grep -E "successfully|Failed" || true

# --- 3. configuracoes de usuario --------------------------------------------
mkdir -p "$USER_DIR" "$KOTLIN_TMP"
[ -f "$USER_DIR/settings.json" ] && cp "$USER_DIR/settings.json" "$USER_DIR/settings.json.bak.$(date +%s)"
python3 - "$USER_DIR/settings.json" "$JDK" "$KOTLIN_TMP" <<'EOF_PY'
import json,sys,os
path,jdk,tmp=sys.argv[1:4]
try: s=json.load(open(path))
except Exception: s={}
for k in ("kotlin.languageServer.enabled","kotlin.debugAdapter.enabled","editor.semanticTokenColorCustomizations"):
    s.pop(k,None)
s.update({
 "editor.colorDecorators": True,
 "editor.bracketPairColorization.enabled": True,
 "editor.guides.bracketPairs": "active",
 "editor.inlayHints.enabled": "on",
 "editor.semanticHighlighting.enabled": "configuredByTheme",
 "files.associations": {**s.get("files.associations",{}), "*.kts": "kotlin"},
 "[kotlin]": {"editor.defaultFormatter":"jetbrains.kotlin-server","editor.formatOnSave":True,
              "editor.tabSize":4,"editor.insertSpaces":True,"editor.semanticHighlighting.enabled":False},
 "intellij.buildTool": "gradle",
 "intellij.additionalJvmArgs": [f"-Djava.io.tmpdir={tmp}"],
 "jetbrains.kotlin.hints.enabled": True,
 "editor.tokenColorCustomizations": {"textMateRules":[
  {"scope":["entity.name.function.annotation.kotlin","meta.annotation.kotlin","punctuation.definition.annotation.kotlin"],"settings":{"foreground":"#E5C07B","fontStyle":"italic"}},
  {"scope":"entity.name.function.composable.kotlin","settings":{"foreground":"#61AFEF","fontStyle":"bold"}},
  {"scope":"entity.name.function.declaration.kotlin","settings":{"foreground":"#61AFEF"}},
  {"scope":"entity.name.function.call.kotlin","settings":{"foreground":"#56B6C2"}},
  {"scope":"variable.parameter.named-argument.kotlin","settings":{"foreground":"#D19A66"}},
  {"scope":"variable.other.property.kotlin","settings":{"foreground":"#E06C75"}},
  {"scope":"entity.name.type.kotlin","settings":{"foreground":"#E5C07B"}},
  {"scope":"constant.other.kotlin","settings":{"foreground":"#D19A66"}},
  {"scope":"storage.type.kotlin","settings":{"foreground":"#C678DD"}},
  {"scope":"constant.numeric.hex.kotlin","settings":{"foreground":"#D19A66"}},
  {"scope":"string.quoted.double.kotlin","settings":{"foreground":"#98C379"}},
  {"scope":"comment.line.double-slash.kotlin","settings":{"foreground":"#7F848E","fontStyle":"italic"}}]},
})
if jdk: s["intellij.jdkForSymbolResolution"]=jdk
json.dump(s,open(path,"w"),indent=2,ensure_ascii=False)
print(">> settings de usuario atualizadas:",path)
EOF_PY

# --- 4. Flatpak: TMPDIR compartilhado ---------------------------------------
if [ "$MODE" = flatpak ]; then
  flatpak override --user --env=TMPDIR="$KOTLIN_TMP" com.visualstudio.code
  echo ">> flatpak override TMPDIR=$KOTLIN_TMP (desfazer: flatpak override --user --unset-env=TMPDIR com.visualstudio.code)"
fi

# --- 5. projeto (opcional) ---------------------------------------------------
if [ -n "$PROJECT" ]; then
  cd "$PROJECT"
  SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
  if [ -d "$SDK" ] && ! grep -qs '^sdk.dir=' local.properties 2>/dev/null; then
    echo "sdk.dir=$SDK" >> local.properties; echo ">> local.properties: sdk.dir=$SDK"
  fi
  mkdir -p .vscode
  if [ "$MODE" = flatpak ] && [ ! -f .vscode/settings.json ]; then
    cat > .vscode/settings.json <<'EOF_WS'
{
  "java.import.gradle.enabled": false,
  "java.configuration.updateBuildConfiguration": "disabled",
  "terminal.integrated.profiles.linux": {
    "host-bash": { "path": "/usr/bin/flatpak-spawn", "args": ["--host", "--directory=${workspaceFolder}", "bash", "-l"], "icon": "terminal-bash" }
  },
  "terminal.integrated.defaultProfile.linux": "host-bash",
  "files.exclude": { "**/.gradle": true, "**/.kotlin": true, "**/build": true }
}
EOF_WS
    echo ">> .vscode/settings.json criado (terminal no host)"
  fi
fi

echo
echo "Pronto. FECHE o VS Code por completo e abra de novo; depois abra um .kt e aguarde o import do Gradle."
