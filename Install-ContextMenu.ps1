[CmdletBinding()]
param(
    [string]$LauncherPath = (Join-Path $PSScriptRoot 'OpenProjectInChatGPTLauncher.exe'),
    [switch]$Uninstall
)

$menuKey = 'HKCU:\Software\Classes\Directory\shell\OpenProjectInChatGPTLauncher'

if ($Uninstall) {
    Remove-Item -LiteralPath $menuKey -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host 'Removed the Open project in ChatGPT context-menu entry'
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
