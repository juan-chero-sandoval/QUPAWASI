param()

$ErrorActionPreference = 'Stop'
$repoPath = Split-Path -Parent $PSScriptRoot
$mobilePath = Join-Path $repoPath 'apps/mobile'
if (-not (Test-Path -LiteralPath (Join-Path $mobilePath 'pubspec.yaml'))) {
    throw 'La app todavia no existe. Ejecutar primero el PRP F01; esta preparacion no contiene un APK.'
}
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'Flutter no esta en PATH. Revisar docs/ENTORNO_Y_APK.md.'
}
if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
    throw 'Dart no esta en PATH. Verificar la instalacion Flutter.'
}

function Assert-Exit([string]$stepName) {
    if ($LASTEXITCODE -ne 0) {
        throw "Fallo en $stepName (codigo $LASTEXITCODE). Corregir antes del relevo."
    }
}

Push-Location -LiteralPath $mobilePath
try {
    & flutter pub get
    Assert-Exit 'flutter pub get'
    # F02 debe generar Drift antes de este script si ha cambiado el esquema.
    $formatPaths = @('lib', 'test')
    if (Test-Path -LiteralPath 'integration_test') {
        $formatPaths += 'integration_test'
    }
    & dart format --output=none --set-exit-if-changed @formatPaths
    Assert-Exit 'dart format (comprobacion)'
    & flutter analyze
    Assert-Exit 'flutter analyze'
    & flutter test
    Assert-Exit 'flutter test'
    & flutter build apk --debug
    Assert-Exit 'flutter build apk --debug'
    Write-Output 'OK: formato, analisis, tests y APK debug. Aun falta verificar instalacion/recorrido en Android.'
}
finally {
    Pop-Location
}
