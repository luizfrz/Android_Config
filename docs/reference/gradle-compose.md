# Gradle + Jetpack Compose

Referência de configuração Gradle (Kotlin DSL) para projetos Compose. Arquivos prontos em [`templates/gradle/`](../../templates/gradle/).

## Toolchain

| Componente | Versão de referência | Observação |
| ---------- | -------------------- | ---------- |
| JDK        | 17                   | Requisito do AGP 8.x |
| AGP        | 8.7.x                | `com.android.application` |
| Kotlin     | 2.0.21               | Compose compiler embutido no Kotlin |
| KSP        | `2.0.21-1.0.28`      | Prefixo deve casar com a versão do Kotlin |
| Compose BOM| 2024.12.01           | Resolve versões de todas as libs `androidx.compose.*` |
| compileSdk / targetSdk | 35       | |
| minSdk     | 24                   | |

> As versões são um **baseline consistente**, não necessariamente as mais recentes. Ao atualizar, mova Kotlin e KSP juntos e confira a [tabela BOM → versões](https://developer.android.com/develop/ui/compose/bom/bom-mapping).

## Compose compiler: Kotlin 2.0+ vs 1.9

A partir do **Kotlin 2.0**, o compilador do Compose é distribuído com o Kotlin e aplicado por plugin:

```kotlin
plugins {
    alias(libs.plugins.kotlin.compose) // org.jetbrains.kotlin.plugin.compose
}
android {
    buildFeatures { compose = true }
    // sem composeOptions.kotlinCompilerExtensionVersion
}
```

Em projetos legados com **Kotlin 1.9.x**, usa-se `composeOptions { kotlinCompilerExtensionVersion = "1.5.x" }`, e a versão precisa casar exatamente com o Kotlin ([tabela de compatibilidade](https://developer.android.com/jetpack/androidx/releases/compose-kotlin)). Migrar para Kotlin 2.x elimina esse acoplamento.

## Version catalog

1. Copie [`templates/gradle/libs.versions.toml`](../../templates/gradle/libs.versions.toml) para `<projeto>/gradle/libs.versions.toml`.
2. No `build.gradle.kts` **raiz**, declare os plugins sem aplicar:

```kotlin
plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.android) apply false
    alias(libs.plugins.kotlin.compose) apply false
    alias(libs.plugins.ksp) apply false
    alias(libs.plugins.hilt) apply false
}
```

3. Use [`templates/gradle/app.build.gradle.kts`](../../templates/gradle/app.build.gradle.kts) como base do `app/build.gradle.kts`.

## Dependências incluídas

| Grupo | Artefatos | Notas |
| ----- | --------- | ----- |
| Compose UI | `ui`, `ui-tooling-preview`, `material3` | Versões via BOM (`platform(...)`) |
| Tooling (debug) | `ui-tooling`, `ui-test-manifest` | `debugImplementation` — fora do APK release |
| Activity | `activity-compose` | `setContent { }` |
| Lifecycle | `lifecycle-viewmodel-compose`, `lifecycle-runtime-compose` | `viewModel()`, `collectAsStateWithLifecycle()` |
| Navigation | `navigation-compose` | `NavHost` |
| DI | `hilt-android` + `hilt-compiler` (KSP), `hilt-navigation-compose` | Requer plugin `com.google.dagger.hilt.android`, `@HiltAndroidApp` e `@AndroidEntryPoint` |
| Persistência | `room-runtime`, `room-ktx` + `room-compiler` (KSP) | Sem o compiler o Room falha em runtime |
| Rede | `retrofit`, `converter-gson` | Declare `<uses-permission android:name="android.permission.INTERNET"/>` |
| Imagens | `coil-compose` | `AsyncImage` |
| Concorrência | `kotlinx-coroutines-android` | |

Remova o que não usar — cada processador KSP (Hilt, Room) aumenta o tempo de build.

## Tarefas Gradle úteis

| Comando | Efeito |
| ------- | ------ |
| `./gradlew assembleDebug` | APK debug em `app/build/outputs/apk/debug/` |
| `./gradlew installDebug` | Build + `adb install` no device conectado |
| `./gradlew assembleRelease` | APK release (requer `signingConfig` para instalar) |
| `./gradlew bundleRelease` | AAB para a Play Store |
| `./gradlew test` | Testes unitários (JVM) |
| `./gradlew connectedAndroidTest` | Testes instrumentados no device |
| `./gradlew lint` | Android Lint (relatório em `app/build/reports/`) |
| `./gradlew :app:dependencies --configuration releaseRuntimeClasspath` | Árvore de dependências |
| `./gradlew --stop` | Encerra daemons (útil após trocar JDK) |

## Performance de build (`gradle.properties`)

```properties
org.gradle.jvmargs=-Xmx4g -Dfile.encoding=UTF-8
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configuration-cache=true
android.useAndroidX=true
kotlin.code.style=official
```
