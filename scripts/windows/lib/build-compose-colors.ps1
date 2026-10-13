# Empacota templates\vscode\compose-colors em um .vsix.
# Uso: build-compose-colors.ps1 -Source <dir> -Out <arquivo.vsix>
param([Parameter(Mandatory)][string]$Source, [Parameter(Mandatory)][string]$Out)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$contentTypes = '<?xml version="1.0" encoding="utf-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension=".json" ContentType="application/json"/><Default Extension=".js" ContentType="application/javascript"/><Default Extension=".vsixmanifest" ContentType="text/xml"/></Types>'
$manifest = @'
<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011">
  <Metadata>
    <Identity Language="en-US" Id="compose-colors" Version="0.0.2" Publisher="local"/>
    <DisplayName>Compose Colors</DisplayName>
    <Description xml:space="preserve">Color swatches and syntax highlighting for Jetpack Compose in Kotlin.</Description>
  </Metadata>
  <Installation><InstallationTarget Id="Microsoft.VisualStudio.Code"/></Installation>
  <Assets><Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true"/></Assets>
</PackageManifest>
'@

if (Test-Path $Out) { Remove-Item $Out -Force }
$utf8 = New-Object System.Text.UTF8Encoding($false)
$zip = [System.IO.Compression.ZipFile]::Open($Out, 'Create')
try {
    function Add-Text($name, $text) {
        $e = $zip.CreateEntry($name)
        $w = New-Object System.IO.StreamWriter($e.Open(), $utf8)
        $w.Write($text); $w.Dispose()
    }
    Add-Text '[Content_Types].xml' $contentTypes
    Add-Text 'extension.vsixmanifest' $manifest
    $root = (Resolve-Path $Source).Path.TrimEnd('\')
    Get-ChildItem $root -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($root.Length + 1).Replace('\', '/')
        [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, "extension/$rel")
    }
} finally { $zip.Dispose() }
