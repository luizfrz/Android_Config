@echo off
echo === Configurar Ambiente Android + Kotlin no VS Code ===

echo.
echo Verificando Java...
java -version
if %errorlevel% neq 0 (
    echo Java nao encontrado. Instale o JDK 17.
)

echo.
echo Verificando ADB...
adb --version
if %errorlevel% neq 0 (
    echo ADB nao encontrado. Verifique o Android SDK.
)

echo.
echo Verificando ANDROID_HOME...
if "%ANDROID_HOME%"=="" (
    echo ANDROID_HOME nao definido.
    echo Defina manualmente nas variaveis de ambiente do sistema:
    echo   ANDROID_HOME = C:\Users\%USERNAME%\AppData\Local\Android\Sdk
) else (
    echo ANDROID_HOME = %ANDROID_HOME%
)

echo.
echo Verificando dispositivos...
adb devices

echo.
echo Extensoes recomendadas para VS Code:
echo   - Kotlin:           https://marketplace.visualstudio.com/items?itemName=mathiasfrohlich.Kotlin
echo   - Java Dependency:  https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-dependency
echo   - Java Test:        https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-test

echo.
echo Compilar arquivo Kotlin standalone:
echo   kotlinc nome.kt -include-runtime -d nome.jar
echo   java -jar nome.jar

pause
