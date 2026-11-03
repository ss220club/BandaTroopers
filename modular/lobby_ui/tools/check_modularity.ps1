[CmdletBinding()]
param(
	[switch]$StaticOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\.."))
$moduleDme = Join-Path $repoRoot "modular\modular.dme"
$buildScript = Join-Path $repoRoot "tools\build\build.bat"
$includeLine = '#include "lobby_ui/_lobby_ui.dme"'
$disabledLine = '// #include "lobby_ui/_lobby_ui.dme" // temporary: lobby_ui modularity check'

function Invoke-LobbyUiStaticAudit {
	Write-Host "[Lobby UI] Checking the single module include and forbidden implementation references..."

	$moduleDmeText = [IO.File]::ReadAllText($moduleDme)
	$includeCount = ([regex]::Matches($moduleDmeText, [regex]::Escape($includeLine))).Count
	if($includeCount -ne 1) {
		throw "Expected exactly one Lobby UI include in modular/modular.dme; found $includeCount."
	}

	$rg = Get-Command rg -ErrorAction Stop
	$rgArguments = @(
		"-n",
		"-g", "!modular/lobby_ui/**",
		"-g", "!modular/__agents/**",
		"-g", "!modular/**/__docs/**",
		"-g", "!*.md",
		"-e", "\bbanda_[A-Za-z0-9_]*",
		"-e", "\b(uses|get|show|select|play|load|save|refresh|equip)_banda[A-Za-z0-9_]*",
		"-e", "/datum/modpack/lobby_ui(/|\s|$)",
		"code", "modular", "interface", "tgui"
	)

	Push-Location $repoRoot
	try {
		& $rg.Source @rgArguments
		$rgExitCode = $LASTEXITCODE
	}
	finally {
		Pop-Location
	}

	if($rgExitCode -eq 0) {
		throw "Lobby UI implementation symbols were found outside modular/lobby_ui."
	}
	if($rgExitCode -ne 1) {
		throw "rg failed during the Lobby UI modularity audit with exit code $rgExitCode."
	}

	Write-Host "[Lobby UI] Static audit passed."
}

function Invoke-DmBuild([string]$Phase) {
	Write-Host "[Lobby UI] $Phase"
	Push-Location $repoRoot
	try {
		& $buildScript dm --force
		$buildExitCode = $LASTEXITCODE
	}
	finally {
		Pop-Location
	}

	if($buildExitCode -ne 0) {
		throw "$Phase failed with exit code $buildExitCode."
	}
}

if(!(Test-Path -LiteralPath $moduleDme -PathType Leaf)) {
	throw "Missing modular/modular.dme at $moduleDme."
}
if(!(Test-Path -LiteralPath $buildScript -PathType Leaf)) {
	throw "Missing build entrypoint at $buildScript."
}

Invoke-LobbyUiStaticAudit
if($StaticOnly) {
	Write-Host "[Lobby UI] Static-only check completed."
	return
}

Invoke-DmBuild "Building with Lobby UI enabled..."

$originalBytes = [IO.File]::ReadAllBytes($moduleDme)
$originalHash = (Get-FileHash -LiteralPath $moduleDme -Algorithm SHA256).Hash
$originalText = [Text.Encoding]::UTF8.GetString($originalBytes)
$includeCount = ([regex]::Matches($originalText, [regex]::Escape($includeLine))).Count
if($includeCount -ne 1) {
	throw "Refusing to edit modular/modular.dme because the Lobby UI include is not unique."
}

$disabledText = $originalText.Replace($includeLine, $disabledLine)
$disabledBuildError = $null
try {
	$utf8NoBom = New-Object Text.UTF8Encoding($false)
	[IO.File]::WriteAllText($moduleDme, $disabledText, $utf8NoBom)
	Invoke-DmBuild "Building with Lobby UI disabled..."
}
catch {
	$disabledBuildError = $_
}
finally {
	[IO.File]::WriteAllBytes($moduleDme, $originalBytes)
	$restoredHash = (Get-FileHash -LiteralPath $moduleDme -Algorithm SHA256).Hash
	if($restoredHash -ne $originalHash) {
		throw "CRITICAL: modular/modular.dme was not restored byte-for-byte. Expected $originalHash, got $restoredHash."
	}
	Write-Host "[Lobby UI] modular/modular.dme restored byte-for-byte ($restoredHash)."
}

if($disabledBuildError) {
	throw $disabledBuildError
}

Invoke-LobbyUiStaticAudit
Write-Host "[Lobby UI] Enabled and disabled builds passed; no other module include was changed."

