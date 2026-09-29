@echo off
:: Aplica a configuracao de VS Code deste repositorio a um projeto Android:
::   - instala extensoes (templates\vscode\extensions.json)
::   - copia .vscode\settings.json, .vscode\extensions.json e .editorconfig
:: Arquivos existentes e diferentes recebem backup .bak.<timestamp>.
::
:: Uso: scripts\windows\configure-vscode.bat [PROJECT_DIR]
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
call "%~dp0lib\colors.bat"

set "TEMPLATES_DIR=%~dp0..\..\templates"
set "PROJECT_DIR=%~f1"
if "%~1"=="" set "PROJECT_DIR=%CD%"
if not exist "%PROJECT_DIR%\" (
    echo %RED%  [X] Diretorio nao existe: %PROJECT_DIR%%RESET%
    exit /b 1
)
if not exist "%PROJECT_DIR%\gradlew.bat" echo %YELLOW%  [!] %PROJECT_DIR% nao parece um projeto Gradle%RESET%

echo.
echo %CYAN%== Configurar VS Code - Kotlin Android ==%RESET%

echo %YELLOW%[1/3] VS Code CLI%RESET%
where code >nul 2>&1
if errorlevel 1 (
    echo %RED%  [X] CLI 'code' nao encontrada. Reinstale o VS Code marcando "Add to PATH".%RESET%
    call :pause_if_interactive
    exit /b 1
)
for /f "tokens=1" %%v in ('call code --version 2^>nul') do (
    echo %GREEN%  [OK] VS Code %%v%RESET%
    goto :vscode_ok
)
:vscode_ok

echo %YELLOW%[2/3] Extensoes%RESET%
call code --uninstall-extension fwcd.kotlin >nul 2>&1
for /f "usebackq tokens=*" %%e in (`powershell -NoProfile -Command "(Get-Content -Raw '%TEMPLATES_DIR%\vscode\extensions.json' | ConvertFrom-Json).recommendations"`) do (
    call code --install-extension %%e --force >nul 2>&1
    if errorlevel 1 (echo %YELLOW%  [!] Falha ao instalar %%e%RESET%) else (echo %GREEN%  [OK] %%e%RESET%)
)

echo %YELLOW%[3/3] Arquivos de configuracao em %PROJECT_DIR%%RESET%
if not exist "%PROJECT_DIR%\.vscode" mkdir "%PROJECT_DIR%\.vscode"
call :install_file "%TEMPLATES_DIR%\vscode\settings.json"   "%PROJECT_DIR%\.vscode\settings.json"
call :install_file "%TEMPLATES_DIR%\vscode\extensions.json" "%PROJECT_DIR%\.vscode\extensions.json"
call :install_file "%TEMPLATES_DIR%\editorconfig"           "%PROJECT_DIR%\.editorconfig"

echo.
echo %GREEN%  [OK] Concluido. Recarregue a janela: Ctrl+Shift+P ^> Developer: Reload Window%RESET%
call :pause_if_interactive
exit /b 0

:install_file
:: %1 = origem, %2 = destino. Faz backup se o destino existir e for diferente.
if exist "%~2" (
    fc /b "%~1" "%~2" >nul 2>&1
    if errorlevel 1 (
        for /f %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMddHHmmss"') do set "TS=%%t"
        copy /y "%~2" "%~2.bak.!TS!" >nul
        echo %YELLOW%  [!] %~nx2 ja existia - backup em %~nx2.bak.!TS!%RESET%
    )
)
copy /y "%~1" "%~2" >nul && echo %GREEN%  [OK] %~nx2%RESET%
exit /b 0

:pause_if_interactive
echo %CMDCMDLINE% | findstr /i /c:"/c" >nul && pause
exit /b 0
