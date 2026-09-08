# Configuração Kotlin + Android no VS Code (Linux)

## Requisitos

Para desenvolver e executar projetos Android com Kotlin utilizando o Visual Studio Code, é necessário instalar algumas ferramentas.

### 1. Java JDK

Recomenda-se utilizar o **JDK 17** para projetos Android modernos.

Verifique a instalação:

```bash
java -version
```

### 2. Android SDK

Instale o Android SDK via Android Studio e certifique-se de incluir:

- Android SDK
- Android SDK Platform
- Android SDK Build-Tools
- Android SDK Platform-Tools
- Android Emulator

Verifique o ADB:

```bash
adb --version
```

### 3. Android Studio

Mesmo usando VS Code como editor, o Android Studio facilita a instalação e gerenciamento do SDK, emuladores e AVDs.

### 4. Gradle

Use o Gradle Wrapper do projeto quando disponível:

```bash
./gradlew build
```

### 5. Variáveis de ambiente (Linux)

```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
```

Adicione ao `~/.bashrc` e execute `source ~/.bashrc`.

### 6. Visual Studio Code

Instale o VS Code e extensões recomendadas: Kotlin, Extension Pack for Java, Gradle for Java.

### 7. Verificar o ambiente

```bash
java -version
adb --version
echo $ANDROID_HOME
adb devices
```

### 8. Executar o projeto

```bash
cd meu-projeto
chmod +x gradlew
./gradlew build
./gradlew assembleDebug
```

APK típico:

```
app/build/outputs/apk/debug/app-debug.apk
```

### 9. Instalar no dispositivo / emulador

```bash
adb devices
adb install app/build/outputs/apk/debug/app-debug.apk
```
