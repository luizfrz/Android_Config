### Debug arquivo 
``` bash
kotlinc name.kt -include-runtime -d name.jar java -jar name.jar
```

## Ative modo debug do celular 

- Como ativa o modo desenvolvedor
https://www.android.com/intl/pt_br/articles/como-ativar-o-modo-desenvolvedor/

### Screen 
``` bash
cd /tmp wget https://github.com/Genymobile/scrcpy/releases/download/v4.1/scrcpy-linux-x86_64-v4.1.tar.gz 
```
``` bash

tar -xzf scrcpy-linux-x86_64-v4.1.tar.gz
```
``` bash

cd scrcpy-linux-x86_64-v4.1
``` 
``` bash

./scrcpy

``` 

### Tela sempre ligada
```  bash
./scrcpy --stay-awake

``` 

### Instalar ADB
``` bash 
sudo apt install adb
```
### Verificar detalhe
``` bash
adb -l
```