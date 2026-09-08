### Debug arquivo
```bash
kotlinc name.kt -include-runtime -d name.jar
java -jar name.jar
```

## Ativar modo desenvolvedor

- Como ativar o modo desenvolvedor: https://www.android.com/intl/pt_br/articles/como-ativar-o-modo-desenvolvedor/

### scrcpy (screen mirror)
```bash
cd /tmp
wget https://github.com/Genymobile/scrcpy/releases/download/v4.1/scrcpy-linux-x86_64-v4.1.tar.gz
tar -xzf scrcpy-linux-x86_64-v4.1.tar.gz
cd scrcpy-linux-x86_64-v4.1
./scrcpy
```

### Tela sempre ligada
```bash
./scrcpy --stay-awake
```

### Instalar ADB
```bash
sudo apt install adb
```

### Verificar dispositivos e detalhes
```bash
adb -l
adb devices
```
