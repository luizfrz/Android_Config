# Configuração Kotlin + Android no VS Code

## Requisitos

Para desenvolver e executar projetos Android com Kotlin utilizando o Visual Studio Code, é necessário instalar algumas ferramentas.

### 1. Java JDK

O Android utiliza o Java para executar o Gradle e realizar o processo de compilação.

Recomenda-se utilizar o **JDK 17** para projetos Android modernos.

Verifique a instalação:

```bash
java -version
```

Exemplo:

```text
openjdk version "17.x.x"
```

---

### 2. Android SDK

É necessário instalar o Android SDK para compilar e executar o aplicativo.

O SDK pode ser instalado através do **Android Studio**.

Durante a instalação, certifique-se de instalar:

* Android SDK
* Android SDK Platform
* Android SDK Build-Tools
* Android SDK Platform-Tools
* Android Emulator

Depois, verifique se o ADB está funcionando:

```bash
adb --version
```

---

### 3. Android Studio

Mesmo utilizando o VS Code como editor, é recomendado instalar o Android Studio porque ele facilita a instalação e gerenciamento do:

* Android SDK
* SDK Platform
* Build Tools
* Emulator
* AVD (Android Virtual Device)

O código pode ser desenvolvido no VS Code normalmente.

---

### 4. Gradle

Projetos Android utilizam o **Gradle** para gerenciamento de dependências e compilação.

Na maioria dos projetos, não é necessário instalar o Gradle globalmente, pois o projeto possui o **Gradle Wrapper**.

Linux/macOS:

```bash
./gradlew build
```

Windows:

```powershell
.\gradlew.bat build
```

Se o projeto possuir `gradlew`, `gradlew.bat` e a pasta `gradle/wrapper`, prefira utilizar o Gradle Wrapper.

---

## 5. Variáveis de ambiente

É necessário configurar o caminho do Android SDK.

### Linux

Normalmente:

```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
```

Para deixar permanente, adicione essas linhas ao:

```text
~/.bashrc
```

Depois execute:

```bash
source ~/.bashrc
```

Verifique:

```bash
echo $ANDROID_HOME
```

---

## 6. Visual Studio Code

Instale o Visual Studio Code e as extensões necessárias.

Extensões recomendadas:

* Kotlin
* Extension Pack for Java
* Gradle for Java
* Android Emulator

Dependendo do projeto, algumas extensões podem não ser necessárias.

---

## 7. Verificar o ambiente

Verifique o Java:

```bash
java -version
```

Verifique o ADB:

```bash
adb --version
```

Verifique o SDK:

```bash
echo $ANDROID_HOME
```

Verifique os dispositivos disponíveis:

```bash
adb devices
```

O resultado deve mostrar algo semelhante a:

```text
List of devices attached
emulator-5554    device
```

---

## 8. Executar o projeto

Entre na pasta do projeto:

```bash
cd meu-projeto
```

Dê permissão ao Gradle Wrapper no Linux:

```bash
chmod +x gradlew
```

Compile o projeto:

```bash
./gradlew build
```

Para gerar o APK:

```bash
./gradlew assembleDebug
```

Normalmente o APK será encontrado em:

```text
app/build/outputs/apk/debug/app-debug.apk
```

---

## 9. Executar no dispositivo ou emulador

Inicie um emulador pelo Android Studio ou conecte um dispositivo Android com a depuração USB ativada.

Verifique:

```bash
adb devices
```
Depois instale o APK:

```bash
adb install app/build/outputs/apk/debug/app-debug.apk
```

---

## Estrutura básica

Um projeto Android Kotlin normalmente possui uma estrutura semelhante a:

```text
meu-projeto/
├── app/
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       ├── res/
│   │       └── AndroidManifest.xml
│   └── build.gradle.kts
├── gradle/
│   └── wrapper/
├── build.gradle.kts
├── settings.gradle.kts
├── gradlew
└── gradlew.bat
```
## Resumo

Para desenvolver Kotlin Android no VS Code, tenha instalado:

| Ferramenta              | Necessário                   |
| ----------------------- | ---------------------------- |
| JDK 17                  | Sim                          |
| Android SDK             | Sim                          |
| Android SDK Platform    | Sim                          |
| Android Build Tools     | Sim                          |
| Android Platform Tools  | Sim                          |
| Android Studio          | Recomendado                  |
| VS Code                 | Sim                          |
| Kotlin Extension        | Recomendado                  |
| Extension Pack for Java | Recomendado                  |
| Gradle Wrapper          | Geralmente já vem no projeto |
| Emulador Android        | Opcional                     |
| Dispositivo Android     | Opcional                     |

> **Observação:** o VS Code funciona como editor, mas o Android Studio continua sendo muito útil para instalar e gerenciar o Android SDK, emuladores e ferramentas Android.

