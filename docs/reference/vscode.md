# VS Code para Android/Kotlin

## Modelo de uso

O VS Code é o **editor**; Gradle (CLI) faz build/instalação; o Android Studio fica restrito a SDK Manager, AVD Manager e, quando necessário, Layout Inspector/Profiler.

| Tarefa                   | Ferramenta |
| ------------------------ | ---------- |
| Edição, busca, Git       | VS Code |
| Build, testes, lint      | `./gradlew` (terminal ou extensão Gradle) |
| Instalar/rodar no device | `./gradlew installDebug`, `adb`, `scripts/*/build-apk` |
| SDK e emuladores         | Android Studio / `sdkmanager` / `avdmanager` |
| Preview de Compose, Profiler | Android Studio (sem equivalente no VS Code) |

## Extensões

Definidas em [`templates/vscode/extensions.json`](../../templates/vscode/extensions.json) — é a fonte única usada pelos scripts `setup-env` e `configure-vscode`.

| ID | Função |
| -- | ------ |
| `mathiasfrohlich.Kotlin` | Syntax highlighting para `.kt`/`.kts` |
| `vscjava.vscode-java-pack` | Language Support for Java (Red Hat), debugger, test runner, dependency viewer |
| `vscjava.vscode-gradle` | Painel de tarefas Gradle |
| `DiemasMichiels.emulate` | Iniciar AVDs pelo VS Code |

`fwcd.kotlin` é marcado como *unwanted* e removido pelos scripts: o language server dele está descontinuado e costuma travar em projetos Android grandes. Para autocompletar/navegação semântica em Kotlin, avalie o **Kotlin LSP oficial da JetBrains** (<https://github.com/Kotlin/kotlin-lsp>), ainda em pré-lançamento.

## `.vscode/settings.json`

Modelo: [`templates/vscode/settings.json`](../../templates/vscode/settings.json).

| Chave | Motivo |
| ----- | ------ |
| `java.configuration.updateBuildConfiguration: automatic` | Reimporta o projeto quando arquivos Gradle mudam |
| `java.import.gradle.wrapper.enabled` | Usa a versão de Gradle do wrapper do projeto |
| `gradle.nestedProjects` | Detecta projetos Gradle em subpastas |
| `files.associations` | Garante linguagem Kotlin para `.kt`/`.kts` |
| `files.exclude` / `search.exclude` | Oculta `build/` e `.gradle/` (evita resultados duplicados e indexação lenta) |

## `.editorconfig`

Modelo: [`templates/editorconfig`](../../templates/editorconfig). Indentação de 4 espaços em Kotlin (padrão do [Kotlin coding conventions](https://kotlinlang.org/docs/coding-conventions.html)), 2 em XML/JSON/YAML/TOML, LF em tudo exceto `.bat`.

## Aplicar em um projeto

```bash
./scripts/linux/configure-vscode.sh /caminho/do/projeto
```

```bat
scripts\windows\configure-vscode.bat C:\caminho\do\projeto
```

Arquivos existentes e diferentes são preservados como `*.bak.<timestamp>`.
