# Setup — Windows

Ambiente Android (Kotlin + Jetpack Compose) com VS Code como editor, em Windows 10 (1511+) / 11.

> Atalho: após os passos 1–2, `scripts\windows\setup-env.bat` valida o ambiente, define `ANDROID_HOME` e adiciona as ferramentas do SDK ao `PATH` do usuário.

## 1. JDK 17

O AGP 8.x exige **JDK 17**. Recomendado: Eclipse Temurin (<https://adoptium.net>), marcando no instalador **Set JAVA_HOME** e **Add to PATH**.

Via winget:

```powershell
winget install EclipseAdoptium.Temurin.17.JDK
```

```bat
java -version
javac -version
echo %JAVA_HOME%
```

## 2. Android Studio + SDK

Download: <https://developer.android.com/studio> (ou `winget install Google.AndroidStudio`).

Em *Settings → Languages & Frameworks → Android SDK*, instale:

| Aba           | Componente                              |
| ------------- | --------------------------------------- |
| SDK Platforms | API igual ao `compileSdk` do projeto    |
| SDK Tools     | Android SDK Build-Tools                 |
| SDK Tools     | Android SDK Platform-Tools              |
| SDK Tools     | Android SDK Command-line Tools (latest) |
| SDK Tools     | Android Emulator                        |
| SDK Tools     | Google USB Driver (dispositivos físicos Pixel/Nexus) |

Caminho padrão: `%LOCALAPPDATA%\Android\Sdk`.

Aceleração do emulador: habilite **Windows Hypervisor Platform** em *Recursos do Windows* (ou instale o *Android Emulator hypervisor driver* pelo SDK Manager).

## 3. Variáveis de ambiente

Automático (recomendado — não trunca o PATH):

```bat
scripts\windows\setup-env.bat
```

Manual, via PowerShell (variáveis de **usuário**):

```powershell
$sdk = "$env:LOCALAPPDATA\Android\Sdk"
[Environment]::SetEnvironmentVariable('ANDROID_HOME', $sdk, 'User')
$p = [Environment]::GetEnvironmentVariable('Path', 'User')
[Environment]::SetEnvironmentVariable('Path', "$p;$sdk\platform-tools;$sdk\emulator;$sdk\cmdline-tools\latest\bin", 'User')
```

| Variável       | Valor típico                                  |
| -------------- | --------------------------------------------- |
| `ANDROID_HOME` | `%LOCALAPPDATA%\Android\Sdk`                  |
| `JAVA_HOME`    | `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot` |

> **Não** use `setx PATH "%PATH%;..."`: o `setx` trunca em 1024 caracteres e copia o PATH de sistema para o de usuário.

Abra um **novo** terminal após alterar variáveis.

## 4. VS Code

```bat
winget install Microsoft.VisualStudioCode
scripts\windows\configure-vscode.bat C:\caminho\do\projeto
```

Detalhes: [reference/vscode.md](../reference/vscode.md).

## 5. Validar o ambiente

```bat
java -version
echo %ANDROID_HOME%
adb --version
adb devices -l
```

## 6. Criar o projeto

Android Studio → *New Project → Empty Activity* → Language **Kotlin**, Build configuration language **Kotlin DSL**, Minimum SDK **API 24+**.

Dependências: [reference/gradle-compose.md](../reference/gradle-compose.md).

## 7. Build e instalação

```bat
cd C:\caminho\do\projeto
C:\...\Android_Config\scripts\windows\build-apk.bat              :: debug, pergunta se instala
C:\...\Android_Config\scripts\windows\build-apk.bat /install     :: debug, instala direto
C:\...\Android_Config\scripts\windows\build-apk.bat /release /noinstall
```

Manual:

```bat
gradlew.bat assembleDebug
adb install -r app\build\outputs\apk\debug\app-debug.apk
gradlew.bat installDebug
```

Problemas comuns: [troubleshooting.md](../troubleshooting.md).
