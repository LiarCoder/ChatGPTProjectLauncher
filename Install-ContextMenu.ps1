[CmdletBinding()]
param(
    [string]$LauncherPath,
    [switch]$Uninstall
)

# $PSScriptRoot is still empty while parameter defaults are evaluated, so resolve
# the default launcher path here instead of in the param() block.
if (-not $LauncherPath) {
    $LauncherPath = Join-Path $PSScriptRoot 'OpenProjectInChatGPTLauncher.exe'
}

$launcherExeName = 'OpenProjectInChatGPTLauncher.exe'
$menuRoot = 'HKCU:\Software\Classes\Directory\shell'
$menuKey = Join-Path $menuRoot 'OpenProjectInChatGPTLauncher'

if ($Uninstall) {
    # Installs made by hand, or by an older revision of this script, may sit under a
    # different key name, so match on the command line rather than one fixed name.
    $removed = 0
    foreach ($key in Get-ChildItem -LiteralPath $menuRoot -ErrorAction SilentlyContinue) {
        $command = (Get-ItemProperty -LiteralPath "$($key.PSPath)\command" -Name '(default)' -ErrorAction SilentlyContinue).'(default)'
        if ($command -notlike "*$launcherExeName*") { continue }

        Remove-Item -LiteralPath $key.PSPath -Recurse -Force
        Write-Host "Removed the Open project in ChatGPT context-menu entry at $menuRoot\$($key.PSChildName)"
        $removed++
    }

    # Fall back to the canonical name in case the command line no longer matches it.
    if ($removed -eq 0 -and (Test-Path -LiteralPath $menuKey)) {
        Remove-Item -LiteralPath $menuKey -Recurse -Force
        Write-Host "Removed the Open project in ChatGPT context-menu entry at $menuKey"
        $removed++
    }

    if ($removed -eq 0) {
        Write-Host "No $launcherExeName context-menu entry was found; nothing to remove"
    }
    exit 0
}

$resolvedLauncherPath = (Resolve-Path -LiteralPath $LauncherPath -ErrorAction Stop).Path
if ([IO.Path]::GetExtension($resolvedLauncherPath) -ne '.exe') {
    throw 'LauncherPath must point to OpenProjectInChatGPTLauncher.exe'
}

$command = '"{0}" "%1"' -f $resolvedLauncherPath
New-Item -Path $menuKey -Force | Out-Null
New-ItemProperty -Path $menuKey -Name 'MUIVerb' -Value 'Open project in ChatGPT' -PropertyType String -Force | Out-Null
New-ItemProperty -Path $menuKey -Name 'Icon' -Value "$resolvedLauncherPath,0" -PropertyType String -Force | Out-Null
New-Item -Path "$menuKey\command" -Force | Out-Null
Set-ItemProperty -Path "$menuKey\command" -Name '(Default)' -Value $command

Write-Host 'Installed the Open project in ChatGPT context-menu entry'
