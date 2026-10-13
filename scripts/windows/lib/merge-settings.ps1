# Mescla as configuracoes Kotlin/Compose no settings.json de usuario do VS Code.
# Uso: merge-settings.ps1 -Path <settings.json> -KotlinTmp <dir> [-Jdk <dir>]
param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$KotlinTmp, [string]$Jdk = '')
$ErrorActionPreference = 'Stop'

$s = [ordered]@{}
if (Test-Path $Path) {
    try { (Get-Content -Raw -Encoding UTF8 $Path | ConvertFrom-Json).PSObject.Properties | ForEach-Object { $s[$_.Name] = $_.Value } }
    catch { $s = [ordered]@{} }
}
foreach ($k in 'kotlin.languageServer.enabled', 'kotlin.debugAdapter.enabled', 'editor.semanticTokenColorCustomizations') { $s.Remove($k) }

function Rule($scope, $fg, $style) {
    $set = [ordered]@{ foreground = $fg }
    if ($style) { $set.fontStyle = $style }
    [ordered]@{ scope = $scope; settings = $set }
}

$assoc = [ordered]@{}
if ($s['files.associations']) { $s['files.associations'].PSObject.Properties | ForEach-Object { $assoc[$_.Name] = $_.Value } }
$assoc['*.kts'] = 'kotlin'

$s['editor.colorDecorators'] = $true
$s['editor.bracketPairColorization.enabled'] = $true
$s['editor.guides.bracketPairs'] = 'active'
$s['editor.inlayHints.enabled'] = 'on'
$s['editor.semanticHighlighting.enabled'] = 'configuredByTheme'
$s['files.associations'] = $assoc
$s['[kotlin]'] = [ordered]@{
    'editor.defaultFormatter' = 'jetbrains.kotlin-server'; 'editor.formatOnSave' = $true
    'editor.tabSize' = 4; 'editor.insertSpaces' = $true; 'editor.semanticHighlighting.enabled' = $false
}
$s['intellij.buildTool'] = 'gradle'
$s['intellij.additionalJvmArgs'] = @("-Djava.io.tmpdir=$($KotlinTmp.Replace('\', '/'))")
$s['jetbrains.kotlin.hints.enabled'] = $true
$s['editor.tokenColorCustomizations'] = [ordered]@{ textMateRules = @(
    (Rule @('entity.name.function.annotation.kotlin', 'meta.annotation.kotlin', 'punctuation.definition.annotation.kotlin') '#E5C07B' 'italic'),
    (Rule 'entity.name.function.composable.kotlin' '#61AFEF' 'bold'),
    (Rule 'entity.name.function.declaration.kotlin' '#61AFEF' $null),
    (Rule 'entity.name.function.call.kotlin' '#56B6C2' $null),
    (Rule 'variable.parameter.named-argument.kotlin' '#D19A66' $null),
    (Rule 'variable.other.property.kotlin' '#E06C75' $null),
    (Rule 'entity.name.type.kotlin' '#E5C07B' $null),
    (Rule 'constant.other.kotlin' '#D19A66' $null),
    (Rule 'storage.type.kotlin' '#C678DD' $null),
    (Rule 'constant.numeric.hex.kotlin' '#D19A66' $null),
    (Rule 'string.quoted.double.kotlin' '#98C379' $null),
    (Rule 'comment.line.double-slash.kotlin' '#7F848E' 'italic')
) }
if ($Jdk) { $s['intellij.jdkForSymbolResolution'] = $Jdk }

New-Item -ItemType Directory -Force -Path (Split-Path $Path) | Out-Null
[System.IO.File]::WriteAllText($Path, ($s | ConvertTo-Json -Depth 10), (New-Object System.Text.UTF8Encoding($false)))
Write-Host ">> settings de usuario atualizadas: $Path"
