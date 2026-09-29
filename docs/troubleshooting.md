# Troubleshooting

| Sintoma | Causa provável | Correção |
| ------- | -------------- | -------- |
| `SDK location not found. Define ANDROID_HOME or sdk.dir` | SDK não configurado para o Gradle | Defina `ANDROID_HOME` (reabra o terminal) ou crie `local.properties` com `sdk.dir=...` |
| `Android Gradle plugin requires Java 17 to run` | Gradle rodando com JDK antigo | Aponte `JAVA_HOME` para o JDK 17 e rode `./gradlew --stop` |
| `Unsupported class file major version 6x` | Gradle rodando com JDK **mais novo** que o suportado pelo wrapper | Use JDK 17 ou atualize o Gradle wrapper (`./gradlew wrapper --gradle-version <v>`) |
| `Permission denied: ./gradlew` | Bit de execução perdido (clone via Windows/zip) | `chmod +x gradlew` e `git update-index --chmod=+x gradlew` |
| `/usr/bin/env: 'sh\r'` ao rodar `gradlew`/scripts | Finais de linha CRLF | `sed -i 's/\r$//' gradlew`; o `.gitattributes` deste repo força LF em `.sh` |
| `This version of the Compose Compiler requires Kotlin version X` | `kotlinCompilerExtensionVersion` incompatível (Kotlin 1.9) | Migre para Kotlin 2.x + plugin `org.jetbrains.kotlin.plugin.compose` ([gradle-compose.md](reference/gradle-compose.md)) |
| `ksp-X is too old for kotlin-Y` | KSP e Kotlin desalinhados | Use KSP com prefixo igual à versão do Kotlin |
| `adb devices` mostra `unauthorized` | Chave RSA não aceita | Desbloqueie o aparelho e aceite o prompt; se preciso, *Revogar autorizações de depuração USB* |
| `adb devices` mostra `no permissions` (Linux) | Regras udev ausentes | Veja [adb-cli.md](reference/adb-cli.md#preparar-o-dispositivo) |
| `adb server version doesn't match this client` | Dois `adb` no PATH (distro + SDK) | Remova um deles ou coloque `$ANDROID_HOME/platform-tools` antes no PATH |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | APK instalado com outra assinatura | `adb uninstall <applicationId>` e reinstale |
| `INSTALL_FAILED_TEST_ONLY` | APK marcado como teste | `adb install -t` (os scripts já usam) |
| `INSTALL_PARSE_FAILED_NO_CERTIFICATES` | APK release não assinado | Configure `signingConfigs` ou use a variante debug |
| Emulador lento / `KVM is required` | Sem aceleração de hardware | Linux: grupo `kvm`; Windows: *Windows Hypervisor Platform* |
| VS Code sem destaque em `.kt` | Extensão Kotlin ausente/conflitante | `configure-vscode` + *Developer: Reload Window* |
| Java Language Server consumindo muita CPU | Indexando `build/` | Settings do template já excluem `build/` e `.gradle/`; *Java: Clean Java Language Server Workspace* |
| Cores aparecem como `[92m` no Windows | Terminal antigo sem ANSI | Use Windows Terminal ou Windows 10 1511+ |
