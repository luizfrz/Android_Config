<div align="center">
<img width="300" height="200" alt="Android + Kotlin + VS Code" src="https://github.com/user-attachments/assets/48535ec5-ae9c-4b7c-84ba-f9f8a22ec846" />

# Android_Config

Scripts, templates e documentação para desenvolvimento **Android com Kotlin + Jetpack Compose** usando **VS Code** como editor e **Gradle CLI** como sistema de build.

![lint](https://github.com/luizfrz/Android_Config/actions/workflows/lint.yml/badge.svg)
</div>

---

## Arquitetura do ambiente

```text
┌──────────────┐   edita    ┌─────────────────┐  ./gradlew   ┌───────────────┐   adb    ┌─────────────┐
│   VS Code    │ ─────────▶ │ Projeto Android │ ───────────▶ │ AGP + Kotlin  │ ───────▶ │ Device/AVD  │
│ (extensões)  │            │ (Kotlin DSL)    │              │ (JDK 17)      │  install │             │
└──────────────┘            └─────────────────┘              └───────┬───────┘          └─────────────┘
                                                                     │ ANDROID_HOME
                                                             ┌───────▼───────┐
                                                             │  Android SDK  │ ◀── Android Studio / sdkmanager
                                                             └───────────────┘
```

O Android Studio é usado apenas para gerenciar SDK, emuladores e AVDs; edição, build e deploy acontecem fora dele.

## Requisitos

| Componente | Versão | Obrigatório |
| ---------- | ------ | ----------- |
| JDK | 17 (requisito do AGP 8.x) | Sim |
| Android SDK Platform | = `compileSdk` do projeto | Sim |
| Android SDK Build-Tools / Platform-Tools | latest | Sim |
| Android SDK Command-line Tools | latest | Recomendado |
| Android Studio | qualquer recente | Recomendado (gerência do SDK) |
| VS Code + CLI `code` no PATH | qualquer recente | Sim |
| Gradle | via wrapper do projeto (`gradlew`) | Sim |
| Android Emulator ou device físico | — | Para executar |

Sistemas suportados: Linux (bash 4+) e Windows 10 1511+ / 11.

## Quick start

```bash
git clone https://github.com/luizfrz/Android_Config.git
cd meu-projeto-android

# Linux
../Android_Config/scripts/linux/setup-env.sh         # valida JDK/SDK/ADB, ajusta ANDROID_HOME, instala extensões
../Android_Config/scripts/linux/configure-vscode.sh  # .vscode/ + .editorconfig no projeto
../Android_Config/scripts/linux/build-apk.sh -i      # assembleDebug + adb install
```

```bat
:: Windows
..\Android_Config\scripts\windows\setup-env.bat
..\Android_Config\scripts\windows\configure-vscode.bat
..\Android_Config\scripts\windows\build-apk.bat /install
```

Todos os scripts aceitam o diretório do projeto como argumento (padrão: diretório atual) e `--help` / `/?`.

## Estrutura

```text
Android_Config/
├── README.md
├── .editorconfig                  # estilo deste repositório
├── .gitattributes                 # LF para .sh, CRLF para .bat
├── .github/workflows/lint.yml     # shellcheck, finais de linha, validação dos templates
├── docs/
│   ├── README.md                  # índice
│   ├── setup/
│   │   ├── linux.md
│   │   └── windows.md
│   ├── reference/
│   │   ├── gradle-compose.md      # toolchain, Compose compiler, version catalog
│   │   ├── vscode.md              # extensões e settings
│   │   ├── adb-cli.md             # adb, logcat, emulador, scrcpy
│   │   └── links.md
│   └── troubleshooting.md
├── scripts/
│   ├── linux/
│   │   ├── lib/common.sh          # cores, logging, install_file com backup
│   │   ├── setup-env.sh
│   │   ├── build-apk.sh
│   │   └── configure-vscode.sh
│   └── windows/
│       ├── lib/colors.bat
│       ├── setup-env.bat
│       ├── build-apk.bat
│       └── configure-vscode.bat
└── templates/                     # fonte única usada pelos scripts e pela documentação
    ├── editorconfig
    ├── gradle/
    │   ├── libs.versions.toml     # version catalog (Compose BOM, Hilt, Room, Retrofit, Coil…)
    │   └── app.build.gradle.kts   # módulo app com Kotlin 2.0 + plugin compose + KSP
    └── vscode/
        ├── extensions.json
        └── settings.json
```

## Scripts

### `setup-env` — validação e configuração do ambiente

| Etapa | Verificação / ação |
| ----- | ------------------ |
| 1 | `java` ≥ 17 e presença de `javac` (JDK completo), `JAVA_HOME` |
| 2 | `kotlinc` (opcional — o Kotlin do projeto vem do Gradle) |
| 3 | `ANDROID_HOME`; se ausente, define e persiste (`~/.bashrc`/`~/.zshrc` ou variável de usuário no Windows) |
| 4 | `platform-tools`, `emulator`, `cmdline-tools/latest/bin`, `build-tools`, `platforms` |
| 5 | `adb` |
| 6 | `gradlew` e `gradle/libs.versions.toml` no projeto |
| 7 | `adb devices -l` |
| — | Instala extensões de `templates/vscode/extensions.json` e remove `fwcd.kotlin` |

Sai com código `1` se houver erro bloqueante (sem JDK, sem SDK, sem ADB). Linux: `--no-rc` não altera arquivos de shell, `--no-extensions` pula o VS Code.

No Windows, o `PATH` é atualizado via PowerShell apenas no escopo de **usuário** e sem duplicar entradas — evita o truncamento em 1024 caracteres do `setx`.

### `build-apk` — build e deploy

| Linux | Windows | Efeito |
| ----- | ------- | ------ |
| `-r`, `--release` | `/release` | `assembleRelease` em vez de `assembleDebug` |
| `-i`, `--install` | `/install` | Instala sem perguntar |
| `-n`, `--no-install` | `/noinstall` | Não instala (uso em CI) |
| `--no-clean` | `/noclean` | Pula `gradlew clean` (builds incrementais) |
| `-s SERIAL` | — | Device alvo (`ANDROID_SERIAL`) |

Localiza o APK mais recente em `*/build/outputs/apk/**/<variant>/`, cobrindo módulos com nome customizado e product flavors. Instala com `adb install -r -t`. APKs release `*-unsigned.apk` não são instalados.

### `configure-vscode` — configuração do projeto

Instala as extensões e copia `templates/vscode/{settings,extensions}.json` → `.vscode/` e `templates/editorconfig` → `.editorconfig`. Arquivos existentes com conteúdo diferente são salvos como `*.bak.<timestamp>` antes de serem substituídos.

## Documentação

- [Setup Linux](docs/setup/linux.md) · [Setup Windows](docs/setup/windows.md)
- [Gradle + Jetpack Compose](docs/reference/gradle-compose.md)
- [VS Code](docs/reference/vscode.md)
- [ADB e CLI](docs/reference/adb-cli.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Links oficiais](docs/reference/links.md)

## Contribuindo

- Scripts Linux: `bash`, `set -euo pipefail`, funções de `lib/common.sh`; devem passar em `shellcheck -x -S style`.
- Scripts Windows: CRLF (garantido pelo `.gitattributes`), sem `::` dentro de blocos `( )`, `call` ao invocar `.cmd`/`.bat` (ex.: `call code ...`).
- Extensões e settings do VS Code são alterados **somente** em `templates/`; os scripts leem de lá.
