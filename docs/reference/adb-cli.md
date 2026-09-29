# ADB e ferramentas de linha de comando

## Instalação

O `adb` vem no **SDK Platform-Tools** (`$ANDROID_HOME/platform-tools`). Em Debian/Ubuntu há também o pacote da distro, geralmente mais antigo:

```bash
sudo apt install adb
```

Prefira o do SDK para evitar conflito de versão entre cliente e servidor (`adb server version (X) doesn't match this client (Y)`).

## Preparar o dispositivo

1. *Configurações → Sobre o telefone →* toque 7× em **Número da versão** ([guia oficial](https://developer.android.com/studio/debug/dev-options)).
2. *Opções do desenvolvedor →* ative **Depuração USB**.
3. Conecte o cabo e aceite a chave RSA no aparelho.

Linux: se o device aparecer como `no permissions`, instale as regras udev:

```bash
sudo apt install android-sdk-platform-tools-common   # regras udev
sudo usermod -aG plugdev "$USER"                      # requer novo login
```

## Dispositivos

```bash
adb devices -l                 # lista com modelo/transporte
adb -s <serial> <comando>      # alvo específico quando há mais de um
export ANDROID_SERIAL=<serial> # alvo padrão da sessão
adb kill-server && adb start-server
```

### Depuração sem fio (Android 11+)

```bash
adb pair <ip>:<porta-pareamento>   # código exibido em "Depuração sem fio"
adb connect <ip>:<porta>
```

## Instalação e execução

```bash
adb install -r -t app/build/outputs/apk/debug/app-debug.apk   # -r reinstala, -t permite APK de teste
adb uninstall com.example.app
adb shell am start -n com.example.app/.MainActivity
adb shell am force-stop com.example.app
adb shell pm clear com.example.app                             # limpa dados
adb shell pm list packages | grep example
```

## Logs e diagnóstico

```bash
adb logcat --pid="$(adb shell pidof -s com.example.app)"   # só o app
adb logcat '*:E'                                           # só erros
adb logcat -c                                              # limpa buffer
adb bugreport bugreport.zip
adb shell dumpsys activity top | head -n 40
```

## Arquivos e tela

```bash
adb push local.txt /sdcard/Download/
adb pull /sdcard/Download/arquivo.txt .
adb exec-out screencap -p > screen.png
adb shell screenrecord /sdcard/rec.mp4   # Ctrl+C para parar; depois adb pull
```

## Emulador

```bash
emulator -list-avds
emulator -avd <nome> -no-snapshot-load
avdmanager list device
sdkmanager --list_installed
```

## scrcpy (espelhamento de tela)

Espelha e controla o dispositivo via ADB. Projeto: <https://github.com/Genymobile/scrcpy>.

```bash
sudo apt install scrcpy   # versão da distro
```

Ou binário estático (ajuste a versão conforme a [página de releases](https://github.com/Genymobile/scrcpy/releases)):

```bash
VERSION=v4.1
cd /tmp
wget "https://github.com/Genymobile/scrcpy/releases/download/$VERSION/scrcpy-linux-x86_64-$VERSION.tar.gz"
tar -xzf "scrcpy-linux-x86_64-$VERSION.tar.gz"
"./scrcpy-linux-x86_64-$VERSION/scrcpy"
```

Flags úteis:

```bash
scrcpy --stay-awake          # mantém a tela ligada enquanto conectado
scrcpy --turn-screen-off     # espelha com a tela física desligada
scrcpy --max-size 1024       # reduz resolução/latência
scrcpy --record file.mp4
```

## Kotlin fora do Android (kotlinc)

Para testar um arquivo `.kt` isolado na JVM (não se aplica a código Android):

```bash
kotlinc main.kt -include-runtime -d main.jar
java -jar main.jar
```
