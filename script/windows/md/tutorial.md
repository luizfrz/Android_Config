# Configuração Kotlin + Android no VS Code (Windows)

## Requisitos

Para desenvolver e executar projetos Android com Kotlin utilizando o Visual Studio Code, é necessário instalar algumas ferramentas.

### 1. Java JDK

O Android utiliza o Java para executar o Gradle e realizar o processo de compilação.

Recomenda-se utilizar o **JDK 17** para projetos Android modernos.

Download: https://adoptium.net

Verifique a instalação:

```bat
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

```bat
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

Download: https://developer.android.com/studio

O código pode ser desenvolvido no VS Code normalmente.

---

### 4. Gradle

Projetos Android utilizam o **Gradle** para gerenciamento de dependências e compilação.

Na maioria dos projetos, não é necessário instalar o Gradle globalmente, pois o projeto possui o **Gradle Wrapper**.

```bat
.\gradlew.bat build
```

Se o projeto possuir `gradlew.bat` e a pasta `gradle/wrapper`, prefira utilizar o Gradle Wrapper.

---

## 5. Variáveis de Ambiente

É necessário configurar o caminho do Android SDK.

1. Abra **Configurações do Sistema** → **Variáveis de Ambiente**
2. Em **Variáveis do Sistema**, adicione:

| Variável     | Valor                                         |
| ------------ | --------------------------------------------- |
| ANDROID_HOME | C:\Users\%USERNAME%\AppData\Local\Android\Sdk |
| JAVA_HOME    | C:\Program Files\Eclipse Adoptium\jdk-17.x.x  |

3. Em **Path**, adicione:

```
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\emulator
%ANDROID_HOME%\cmdline-tools\latest\bin
```

Verifique:

```bat
echo %ANDROID_HOME%
echo %JAVA_HOME%
adb --version
```

> Ou execute o script `setup_compose.bat` que configura tudo automaticamente.

---

## 6. Visual Studio Code

Instale o Visual Studio Code e as extensões necessárias.

Extensões recomendadas:

* Kotlin: https://marketplace.visualstudio.com/items?itemName=mathiasfrohlich.Kotlin
* Java Dependency: https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-dependency
* Java Test: https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-test
* Gradle for Java: https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-gradle
* Android Emulator: https://marketplace.visualstudio.com/items?itemName=DiemasMichiels.emulate

---

## 7. Verificar o ambiente

Verifique o Java:

```bat
java -version
```

Verifique o ADB:

```bat
adb --version
```

Verifique o SDK:

```bat
echo %ANDROID_HOME%
```

Verifique os dispositivos disponíveis:

```bat
adb devices
```

O resultado deve mostrar algo semelhante a:

```text
List of devices attached
emulator-5554    device
```

---

## 8. Criar Projeto Kotlin + Jetpack Compose

No Android Studio:

1. **File** → **New Project**
2. Selecione **Empty Activity**
3. Configure:
   - Language: **Kotlin**
   - Minimum SDK: **API 21** ou superior
   - Build configuration language: **Kotlin DSL**
4. Clique em **Finish**

---


---

## 10. Executar o projeto

Entre na pasta do projeto:

```bat
cd meu-projeto
```

Compile o projeto:

```bat
.\gradlew.bat build
```

Para gerar o APK:

```bat
.\gradlew.bat assembleDebug
```

Caminho do *APK*:

```text
app\build\outputs\apk\debug\app-debug.apk
```

---

## 11. Executar no dispositivo ou emulador

Inicie um emulador pelo Android Studio ou conecte um dispositivo Android com a depuração USB ativada.

Verifique:

```bat
adb devices
```

Instale o APK:

```bat
adb install app\build\outputs\apk\debug\app-debug.apk
```

---