# bootstrap/python_.ps1
#
# Python bootstrapping script for Windows.
#
# Automatically downloads a portable edition of a pinned Python version to
# a cache directory, installs Pip, installs `requirements.txt`, and then invokes
# Python.
#
# The underscore in the name is so that typing `bootstrap/python` into
# PowerShell finds the `.bat` file first, which ensures this script executes
# regardless of ExecutionPolicy.
$host.ui.RawUI.WindowTitle = "starting :: python $args"
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.IO.Compression.FileSystem

function ExtractVersion {
	param([string] $Path, [string] $Key)
	foreach ($Line in Get-Content $Path) {
		if ($Line.StartsWith("export $Key=")) {
			return $Line.Substring("export $Key=".Length)
		}
	}
	throw "Couldn't find value for $Key in $Path"
}

function GetFileHashString {
	param([string] $Path)
	$Sha256 = [System.Security.Cryptography.SHA256]::Create()
	try {
		return [System.BitConverter]::ToString($Sha256.ComputeHash([System.IO.File]::ReadAllBytes($Path)))
	}
	finally {
		$Sha256.Dispose()
	}
}

# Convenience variables
$Bootstrap = Split-Path $script:MyInvocation.MyCommand.Path
$Tools = Split-Path $Bootstrap
$Cache = "$Bootstrap/.cache"
if ($Env:TG_BOOTSTRAP_CACHE) {
	$Cache = $Env:TG_BOOTSTRAP_CACHE
}
$PythonVersion = ExtractVersion -Path "$Bootstrap/../../dependencies.sh" -Key "PYTHON_VERSION"
$PythonDir = "$Cache/python-$PythonVersion"
$PythonExe = "$PythonDir/python.exe"
$Log = "$Cache/last-command.log"
$PythonVersionArray = $PythonVersion.Split(".")
$PythonVersionString = "python$($PythonVersionArray[0])$($PythonVersionArray[1])"

# Download and unzip a portable version of Python
if (!(Test-Path $PythonExe -PathType Leaf)) {
	$host.ui.RawUI.WindowTitle = "Downloading Python $PythonVersion..."
	New-Item $Cache -ItemType Directory -ErrorAction silentlyContinue | Out-Null

	$Archive = "$Cache/python-$PythonVersion-embed.zip"
	Invoke-WebRequest `
		"https://www.python.org/ftp/python/$PythonVersion/python-$PythonVersion-embed-amd64.zip" `
		-OutFile $Archive `
		-ErrorAction Stop

	[System.IO.Compression.ZipFile]::ExtractToDirectory($Archive, $PythonDir)

	Remove-Item $Archive
}

# Keep the embedded Python import path valid for both a fresh and an existing cache.
# Four parents is the repo root (`tools.*` imports); three parents is `tools`
# (the historical `dmi.*` and `mapmerge2.*` module entrypoints).
Write-Output "Configuring Python path descriptor."
Set-Content "$PythonDir/$PythonVersionString._pth" "$PythonVersionString.zip`n.`n..\..\..\..`n..\..\..`nimport site`n"

# Install pip
if (!(Test-Path "$PythonDir/Scripts/pip.exe")) {
	$host.ui.RawUI.WindowTitle = "Downloading Pip..."

	Invoke-WebRequest "https://bootstrap.pypa.io/get-pip.py" `
		-OutFile "$Cache/get-pip.py" `
		-ErrorAction Stop

	& $PythonExe "$Cache/get-pip.py" --no-warn-script-location
	if ($LASTEXITCODE -ne 0) {
		exit $LASTEXITCODE
	}

	Remove-Item "$Cache/get-pip.py" `
		-ErrorAction Stop
}

# Use pip to install our requirements
if (!(Test-Path "$PythonDir/requirements.txt") -or ((GetFileHashString "$Tools/requirements.txt") -ne (GetFileHashString "$PythonDir/requirements.txt"))) {
	$host.ui.RawUI.WindowTitle = "Updating dependencies..."

	& $PythonExe -m pip install -U pip -r "$Tools/requirements.txt"
	if ($LASTEXITCODE -ne 0) {
		exit $LASTEXITCODE
	}

	Copy-Item "$Tools/requirements.txt" "$PythonDir/requirements.txt"
	Write-Output "`n---`n"
}

# Invoke python with all command-line arguments
Write-Output $PythonExe | Out-File -Encoding utf8 $Log
[System.String]::Join([System.Environment]::NewLine, $args) | Out-File -Encoding utf8 -Append $Log
Write-Output "---" | Out-File -Encoding utf8 -Append $Log
$host.ui.RawUI.WindowTitle = "python $args"
$ErrorActionPreference = "Continue"
$Env:PYTHONUTF8 = "1"
& $PythonExe -u $args 2>&1 | ForEach-Object {
	$str = "$_"
	if ($_.GetType() -eq [System.Management.Automation.ErrorRecord]) {
		$str = $str.TrimEnd("`r`n")
	}
	$str | Out-File -Encoding utf8 -Append $Log
	$str | Out-Host
}
exit $LastExitCode
