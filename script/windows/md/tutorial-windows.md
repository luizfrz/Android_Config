# Configuração Kotlin + Android no VS Code (Windows)

## Requisitos

Para desenvolver e executar projetos Android com Kotlin utilizando o Visual Studio Code, instale as ferramentas necessárias.

### 1. Java JDK

Recomenda-se o **JDK 17**. Download: https://adoptium.net

Verifique:

```bat
java -version
```

### 2. Android SDK

Instale via Android Studio e inclua:

- Android SDK
- Android SDK Platform
- Android SDK Build-Tools
- Android SDK Platform-Tools
- Android Emulator

Verifique o ADB:

```bat
adb --version
```

### 3. Android Studio

Download: https://developer.android.com/studio

### 4. Gradle

Use o Gradle Wrapper:

```bat
.\gradlew.bat build
```

### 5. Variáveis de Ambiente (Windows)

Adicione as variáveis de sistema:

| Variável     | Valor                                         |
| ------------ | --------------------------------------------- |
| ANDROID_HOME | C:\Users\%USERNAME%\AppData\Local\Android\Sdk |
| JAVA_HOME    | C:\Program Files\Eclipse Adoptium\jdk-17.x.x  |

Adicione ao `Path`:

```
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\emulator
%ANDROID_HOME%\cmdline-tools\latest\bin
```

### 6. Visual Studio Code

Instale as extensões recomendadas (Kotlin, Java Dependency, Java Test, Gradle for Java, Android Emulator).

### 7. Verificar o ambiente

```bat
java -version
adb --version
echo %ANDROID_HOME%
adb devices
```

### 8. Criar projeto (Android Studio)

1. File → New Project
2. Selecione Empty Activity
3. Language: Kotlin
4. Minimum SDK: API 21+ 
5. Build configuration language: Kotlin DSL

### 9. Executar e gerar APK

```bat
cd meu-projeto
.\gradlew.bat build
.\gradlew.bat assembleDebug
```

APK típico:

```
app\build\outputs\apk\debug\app-debug.apk
```

### 10. Instalar no dispositivo

```bat
adb devices
adb install app\build\outputs\apk\debug\app-debug.apk
```
