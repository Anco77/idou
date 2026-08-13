param(
  [ValidateSet('fast', 'full')]
  [string]$Mode = 'full',
  [ValidateSet('none', 'android', 'windows', 'both')]
  [string]$BuildPlatform = 'none',
  [switch]$Help
)

$ErrorActionPreference = 'Stop'

if ($Help) {
  Write-Output 'Usage: project_gate.ps1 [-Mode fast|full] [-BuildPlatform none|android|windows|both]'
  Write-Output 'fast: format check + analyze; full: fast + all tests; optional builds run last.'
  exit 0
}

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))

function Invoke-GateCommand {
  param([string]$Label, [scriptblock]$Command)
  Write-Output "== $Label =="
  & $Command
  if ($LASTEXITCODE -ne 0) {
    throw "$Label failed with exit code $LASTEXITCODE"
  }
}

foreach ($tool in @('dart', 'flutter')) {
  if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
    throw "Required tool is unavailable: $tool"
  }
}

Push-Location $repoRoot
try {
  Invoke-GateCommand 'Format check' { dart format --output=none --set-exit-if-changed lib test }
  Invoke-GateCommand 'Static analysis (error/warning fatal, info reported)' {
    flutter analyze --no-fatal-infos
  }

  if ($Mode -eq 'full') {
    Invoke-GateCommand 'Flutter tests' { flutter test }
  }

  if ($BuildPlatform -in @('android', 'both')) {
    Invoke-GateCommand 'Android release build' { flutter build apk --release }
  }
  if ($BuildPlatform -in @('windows', 'both')) {
    Invoke-GateCommand 'Windows release build' { flutter build windows --release }
  }

  Write-Output 'All requested gates passed.'
}
finally {
  Pop-Location
}
