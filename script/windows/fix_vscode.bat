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
echo %CYAN%║        Fix VS Code - Kotlin Android                  ║%RESET%
echo %CYAN%╚══════════════════════════════════════════════════════╝%RESET%
echo.

:: ─── VS Code instalado ───────────────────────────────────────────────────────
echo %YELLOW%[1/4] Verificando VS Code...%RESET%
code --version >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%  ✗ VS Code nao encontrado.%RESET%
    echo %WHITE%    Instale em: https://code.visualstudio.com%RESET%
    pause
    exit /b 1
)
for /f "tokens=1" %%v in ('code --version 2^>nul') do (
    echo %GREEN%  ✓ VS Code encontrado: %%v%RESET%
    goto :vscode_ok
)
:vscode_ok
echo.

:: ─── Instalar extensoes ──────────────────────────────────────────────────────
echo %YELLOW%[2/4] Instalando extensoes...%RESET%

set EXTENSIONS=mathiasfrohlich.Kotlin vscjava.vscode-java-dependency vscjava.vscode-java-test vscjava.vscode-gradle DiemasMichiels.emulate redhat.java vscjava.vscode-java-pack

for %%e in (%EXTENSIONS%) do (
    echo %WHITE%    Instalando %%e...%RESET%
    code --install-extension %%e --force >nul 2>&1
    echo %GREEN%  ✓ %%e instalado%RESET%
)
echo.

:: ─── Criar .vscode/settings.json ────────────────────────────────────────────
echo %YELLOW%[3/4] Configurando .vscode\settings.json...%RESET%
if not exist ".vscode" mkdir .vscode
(
    echo {
    echo     "java.configuration.updateBuildConfiguration": "automatic",
    echo     "java.compile.nullAnalysis.mode": "automatic",
    echo     "gradle.nestedProjects": true,
    echo     "editor.formatOnSave": true,
    echo     "editor.tabSize": 4,
    echo     "files.trimTrailingWhitespace": true,
    echo     "files.insertFinalNewline": true,
    echo     "kotlin.languageServer.enabled": true,
    echo     "kotlin.debugAdapter.enabled": true
    echo }
) > .vscode\settings.json
echo %GREEN%  ✓ .vscode\settings.json criado%RESET%
echo.

:: ─── Criar .editorconfig ─────────────────────────────────────────────────────
echo %YELLOW%[4/4] Criando .editorconfig...%RESET%
(
    echo root = true
    echo.
    echo [*]
    echo charset = utf-8
    echo end_of_line = lf
    echo indent_style = space
    echo indent_size = 4
    echo trim_trailing_whitespace = true
    echo insert_final_newline = true
    echo.
    echo [*.{kt,kts}]
    echo indent_size = 4
    echo.
    echo [*.{xml,json,yml,yaml}]
    echo indent_size = 2
) > .editorconfig
echo %GREEN%  ✓ .editorconfig criado%RESET%
echo.

echo %GREEN%╔══════════════════════════════════════════════════════╗%RESET%
echo %GREEN%║              Fix concluido!                          ║%RESET%
echo %GREEN%╚══════════════════════════════════════════════════════╝%RESET%
echo.
pause
