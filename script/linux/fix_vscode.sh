#!/bin/bash
set -e 

# Unresolved reference: android

echo "Configurando para vscode"

PROJECT_DIR="/home/name/name_project"
cd "$PROJECT_DIR"

echo " [1/7] Criando configurações do VSCode..."
mkdir -p .vscode

# 2. Configurar settings.json
cat > .vscode/settings.json << 'EOF'
{
  "kotlin.languageServer.enabled": true,
  "kotlin.compiler.jvm.target": "11",
  "kotlin.debounceTime": 250,
  "java.configuration.updateBuildConfiguration": "automatic",
  "java.import.gradle.java.home": "/home/beamchita/.sdkman/candidates/java/current",
  "files.exclude": {
    "**/.gradle": true,
    "**/.kotlin": true,
    "**/build": true
  }
}
EOF
echo " settings.json criado"

# 3. Criar arquivo de configuração do Kotlin Language Server
cat > .kotlinlsp << 'EOF'
kotlin.compiler.jvm.target=11
android.enabled=true
EOF
echo "   .kotlinlsp criado"

# 4. Desinstalar extensão antiga
echo ""
echo " [2/7] Removendo extensão Kotlin antiga..."
code --uninstall-extension fwcd.kotlin 2>/dev/null
echo "   Extensão antiga removida"

echo "[3/7] Instalando extensão Kotlin correta..."
code --install-extension mathiasfrohlich.kotlin --force
echo "   mathiasfrohlich.kotlin instalado"

echo "[4/7] Limpando cache..."
rm -rf ~/.vscode/extensions/fwcd.kotlin-*/server 2>/dev/null
rm -rf ~/.config/Code/User/globalStorage/fwcd.kotlin 2>/dev/null
rm -rf ~/.config/Code/User/workspaceStorage/*/fwcd.kotlin 2>/dev/null
echo "   Cache limpo"

echo " [5/7] Sincronizando projeto Gradle..."
./gradlew clean 2>&1 | tail -3
./gradlew :app:compileDebugKotlin 2>&1 | tail -3
echo "   Gradle sincronizado"

echo " [6/7] Gerando classpath..."
./gradlew :app:dependencies --configuration debugCompileClasspath > /tmp/kotlin_classpath.txt 2>&1
echo "  Classpath gerado"

echo " [7/7] Reiniciando VSCode..."
pkill -f "Visual Studio Code" 2>/dev/null
pkill -f "code" 2>/dev/null
sleep 3
code "$PROJECT_DIR" 2>/dev/null &
sleep 2
