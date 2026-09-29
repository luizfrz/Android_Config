# Setup — Linux

Ambiente Android (Kotlin + Jetpack Compose) com VS Code como editor, em distribuições baseadas em Debian/Ubuntu. Para outras distros, troque `apt` pelo gerenciador equivalente.

> Atalho: após os passos 1–3, `scripts/linux/setup-env.sh` valida e completa o restante automaticamente.

## 1. JDK 17

O Android Gradle Plugin (AGP) 8.x exige **JDK 17** para executar o Gradle.

```bash
sudo apt update
sudo apt install openjdk-17-jdk
java -version     # openjdk version "17.x"
javac -version    # deve existir: JRE sozinho não compila
```

Com vários JDKs instalados:

```bash
sudo update-alternatives --config java
export JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")"
```

## 2. Android Studio + SDK

O Android Studio é usado **só** para instalar/gerenciar SDK, emuladores e AVDs. Download: <https://developer.android.com/studio>.

Em *Settings → Languages & Frameworks → Android SDK*:

| Aba          | Componente                              | Motivo                                  |
| ------------ | --------------------------------------- | --------------------------------------- |
| SDK Platforms| Android API igual ao `compileSdk`       | `android.jar` usado na compilação       |
| SDK Tools    | Android SDK Build-Tools                 | `aapt2`, `d8`, `apksigner`, `zipalign`  |
| SDK Tools    | Android SDK Platform-Tools              | `adb`, `fastboot`                       |
| SDK Tools    | Android SDK Command-line Tools (latest) | `sdkmanager`, `avdmanager`              |
| SDK Tools    | Android Emulator                        | Emulador (opcional com device físico)   |

Caminho padrão do SDK: `~/Android/Sdk`.

Alternativa sem GUI (apenas Command-line Tools):

```bash
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" "emulator"
sdkmanager --licenses
```

### Aceleração do emulador (KVM)

```bash
sudo apt install qemu-kvm
sudo usermod -aG kvm "$USER"   # requer novo login
ls -l /dev/kvm                 # grupo kvm com rw
```

## 3. Variáveis de ambiente

Em `~/.bashrc` (ou `~/.zshrc`):

```bash
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin"
```

```bash
source ~/.bashrc
```

> `ANDROID_SDK_ROOT` é legado; o AGP atual usa `ANDROID_HOME`. Alternativamente, o projeto pode apontar o SDK via `local.properties` (`sdk.dir=/home/<user>/Android/Sdk`) — esse arquivo **não** deve ser versionado.

## 4. VS Code

```bash
sudo snap install code --classic   # ou pacote .deb de https://code.visualstudio.com
./scripts/linux/configure-vscode.sh /caminho/do/projeto
```

Detalhes de extensões e settings: [reference/vscode.md](../reference/vscode.md).

## 5. Validar o ambiente

```bash
./scripts/linux/setup-env.sh /caminho/do/projeto
```

Ou manualmente:

```bash
java -version && javac -version
echo "$ANDROID_HOME"
adb --version
adb devices -l
```

## 6. Criar o projeto

No Android Studio: *New Project → Empty Activity*, Language **Kotlin**, Build configuration language **Kotlin DSL**, Minimum SDK **API 24+**. Depois feche o Studio e abra a pasta no VS Code.

Para dependências e version catalog, veja [reference/gradle-compose.md](../reference/gradle-compose.md).

## 7. Build e instalação

```bash
cd /caminho/do/projeto
../Android_Config/scripts/linux/build-apk.sh            # debug + pergunta se instala
../Android_Config/scripts/linux/build-apk.sh -i          # debug + instala direto
../Android_Config/scripts/linux/build-apk.sh -r -n       # release, sem instalar
```

Equivalente manual:

```bash
./gradlew assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk
# ou, em um passo:
./gradlew installDebug
```

Problemas comuns: [troubleshooting.md](../troubleshooting.md).
