<div align="center">
<img width="300" height="200" alt="image" src="https://github.com/user-attachments/assets/48535ec5-ae9c-4b7c-84ba-f9f8a22ec846" />
</div>

------
Repositório de configuração e automação para desenvolvimento **Android com Kotlin + Jetpack Compose** utilizando o **Visual Studio Code** como editor principal.

## Proposta

O objetivo deste repositório é ajudar desenvolvedores a configurar um ambiente Android completo sem depender exclusivamente do Android Studio como editor. Através de scripts automatizados e tutoriais detalhados, é possível desenvolver aplicativos Android com Kotlin e Jetpack Compose diretamente no VS Code, utilizando o Android Studio apenas para gerenciar o SDK, emuladores e ferramentas Android.

---

## Por que usar o VS Code?

* Editor leve e altamente customizável
* Suporte a Kotlin via extensões
* Integração com Gradle via terminal
* Funciona em Linux, macOS e Windows
* Ideal para quem já usa o VS Code em outros projetos

> O Android Studio continua sendo necessário para instalar e gerenciar o Android SDK, Build Tools, emuladores e AVDs.

---

## Estrutura do Repositório

```text
Android_Config/
├── readme.md
└── script/
    ├── linux/
    │   ├── build_app.sh        → Build e instalação do APK
    │   ├── setup_compose.sh    → Configuração do ambiente Jetpack Compose
    │   └── tutorial.md         → Tutorial completo para Linux
    └── windows/
        ├── build_app.bat       → Build e instalação do APK
        ├── setup_compose.bat   → Configuração do ambiente Jetpack Compose
        └── tutorial.md         → Tutorial completo para Windows
```

---

## Scripts

### `setup_compose` (Linux / Windows)

Configura automaticamente o ambiente de desenvolvimento Android + Jetpack Compose.

O que faz:
- Verifica se o Java JDK 17 está instalado
- Verifica se o ADB está disponível
- Define e exporta o `ANDROID_HOME` automaticamente se não estiver configurado
- Adiciona `platform-tools`, `emulator` e `cmdline-tools` ao PATH
- Verifica o Gradle Wrapper do projeto
- Lista dispositivos conectados
- Exibe todas as dependências Jetpack Compose prontas para o `build.gradle.kts`
- Lista as extensões recomendadas para o VS Code

Linux:
```bash
chmod +x script/linux/setup_compose.sh
./script/linux/setup_compose.sh
```

Windows:
```bat
script\windows\setup_compose.bat
```

---

### `build_app` (Linux / Windows)

Automatiza o processo de build e instalação do APK no dispositivo ou emulador.

O que faz:
- Limpa o build anterior com `gradlew clean`
- Compila o APK Debug com `gradlew assembleDebug`
- Verifica se o APK foi gerado com sucesso
- Lista dispositivos conectados via ADB
- Pergunta se deseja instalar o APK no dispositivo

Linux:
```bash
chmod +x script/linux/build_app.sh
./script/linux/build_app.sh
```

Windows:
```bat
script\windows\build_app.bat
```

> Antes de executar, ajuste o `PROJECT_DIR` dentro do script para o caminho do seu projeto.

---

## Tutoriais

Cada sistema operacional possui um tutorial detalhado com todos os passos necessários:

| Tutorial | Caminho |
| -------- | ------- |
| Linux    | `script/linux/tutorial.md` |
| Windows  | `script/windows/tutorial.md` |

Os tutoriais cobrem:

1. Instalação do JDK 17
2. Instalação do Android Studio e Android SDK
3. Configuração das variáveis de ambiente
4. Instalação do VS Code e extensões recomendadas
5. Verificação do ambiente
6. Criação de projeto Kotlin + Jetpack Compose
7. Dependências do Jetpack Compose no `build.gradle.kts`
8. Compilação e geração do APK
9. Instalação no dispositivo ou emulador

---

## Requisitos

| Ferramenta             | Necessário                   |
| ---------------------- | ---------------------------- |
| JDK 17                 | Sim                          |
| Android Studio         | Sim                          |
| Android SDK            | Sim                          |
| Android Build Tools    | Sim                          |
| Android Platform Tools | Sim                          |
| Jetpack Compose BOM    | Sim                          |
| VS Code                | Sim                          |
| Gradle Wrapper         | Geralmente já vem no projeto |
| Emulador Android       | Opcional                     |
| Dispositivo Android    | Opcional                     |

---

## Extensões VS Code Recomendadas

| Extensão            | Link |
| ------------------- | ---- |
| Kotlin              | https://marketplace.visualstudio.com/items?itemName=mathiasfrohlich.Kotlin |
| Java Dependency     | https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-dependency |
| Java Test           | https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-test |
| Gradle for Java     | https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-gradle |
| Android Emulator    | https://marketplace.visualstudio.com/items?itemName=DiemasMichiels.emulate |
