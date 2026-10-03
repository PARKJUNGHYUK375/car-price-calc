@echo off
setlocal
set "DEALERMATE_SETUP_FILE=%~f0"
powershell.exe -NoProfile -Command "$ErrorActionPreference='Stop'; try { $text=[IO.File]::ReadAllText($env:DEALERMATE_SETUP_FILE); $body=($text -split '(?m)^# POWERSHELL\r?$',2)[1]; if (-not $body) { throw 'Setup script missing.' }; & ([scriptblock]::Create($body)) } catch { Write-Host ('[FAIL] ' + $_.Exception.Message); exit 1 }"
if errorlevel 1 (
 echo [FAIL] Registration failed.
 pause
 exit /b 1
)
echo.
echo Return to Dealer Mate and click Carmodoo.
pause
exit /b 0
# POWERSHELL
$paths = @(
    (Join-Path $env:LOCALAPPDATA 'Programs\carmodoo\GGKucar.exe'),
    (Join-Path $env:ProgramFiles 'carmodoo\GGKucar.exe')
)
if (${env:ProgramFiles(x86)}) { $paths += Join-Path ${env:ProgramFiles(x86)} 'carmodoo\GGKucar.exe' }
$exe = $paths | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
if (-not $exe) {
    Add-Type -AssemblyName System.Windows.Forms
    $picker = New-Object System.Windows.Forms.OpenFileDialog
    $picker.Title = 'Select Carmodoo GGKucar.exe'
    $picker.Filter = 'GGKucar.exe|GGKucar.exe'
    if ($picker.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { throw 'Setup cancelled.' }
    $exe = $picker.FileName
    $picker.Dispose()
}
if (-not (Test-Path -LiteralPath $exe -PathType Leaf) -or [IO.Path]::GetFileName($exe) -ine 'GGKucar.exe') { throw 'GGKucar.exe was not found.' }
$key = 'HKCU:\Software\Classes\dealermate-carmodoo'
New-Item -Path "$key\shell\open\command" -Force | Out-Null
Set-Item -Path $key -Value 'URL:DealerMate Carmodoo'
New-ItemProperty -Path $key -Name 'URL Protocol' -Value '' -PropertyType String -Force | Out-Null
Set-Item -Path "$key\shell\open\command" -Value ('"' + $exe + '"')
Write-Host '[OK] Carmodoo PC link registered.'
Write-Host $exe
