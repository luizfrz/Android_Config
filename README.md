# Config-Kotlin

Repositório de configuração e automação para desenvolvimento Android com Kotlin + Jetpack Compose, usando Visual Studio Code como editor principal.

## Proposta

Este repositório auxilia desenvolvedores a preparar um ambiente Android completo sem depender exclusivamente do Android Studio como editor. Contém scripts e tutoriais para desenvolver apps Kotlin + Jetpack Compose no VS Code, usando o Android Studio apenas para instalar e gerenciar o SDK, emuladores e ferramentas quando necessário.

---

## Estrutura recomendada

```
Config-Kotlin/
├── README.md
├── docs/                 # Tutoriais e guias consolidados
├── script/               # Scripts de automação por SO
│   ├── linux/
│   └── windows/
```

## Scripts

Os scripts em `script/` facilitam configuração e build (Linux/Windows).

Principais scripts:

- `setup_compose.sh` / `setup_compose.bat` — configura o ambiente para Jetpack Compose
- `build_app.sh` / `build_app.bat` — automatiza build e instalação do APK
- `fix_vscode.sh` / `fix_vscode.bat` — ajustes para VS Code

Antes de executar, verifique e ajuste variáveis como `PROJECT_DIR` dentro dos scripts.

## Tutoriais consolidados

Os tutoriais completos foram movidos para a pasta `docs/`:

- [Guia Android Studio](docs/guia_android.md)
- [Tutorial Linux — Configuração Kotlin + Android no VS Code](docs/tutorial-linux.md)
- [Tutorial Windows — Configuração Kotlin + Android no VS Code](docs/tutorial-windows.md)
- [Comandos úteis / Debug / scrcpy](docs/commands.md)

## Requisitos

- JDK 17
- Android Studio (para SDK, emuladores e AVDs)
- Android SDK / Build Tools / Platform Tools
- VS Code

## Extensões VS Code recomendadas

- Kotlin: https://marketplace.visualstudio.com/items?itemName=mathiasfrohlich.Kotlin
- Java Dependency: https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-dependency
- Java Test: https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-test
- Gradle for Java: https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-gradle
- Android Emulator: https://marketplace.visualstudio.com/items?itemName=DiemasMichiels.emulate

---

Para detalhes de configuração passo a passo, veja os tutoriais em `docs/`.
