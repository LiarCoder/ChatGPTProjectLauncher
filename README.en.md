# Open Project in ChatGPT Launcher

[简体中文](README.md)

A Windows Explorer context-menu launcher for a Microsoft Store ChatGPT/Codex issue where Explorer tries to launch the protected `WindowsApps\\...\\ChatGPT.exe` directly and receives an access-denied error.

The launcher opens ChatGPT through the Windows application-activation API and passes the selected folder through `--open-project`. On a cold start, it waits for the main window and sends the project path a second time.

## Features

- Open any existing local folder from Explorer with **Open project in ChatGPT**
- Runs as a WinExe, so normal menu use does not flash PowerShell, cmd, or Terminal windows
- Re-sends the project path after a cold launch of ChatGPT
- Installs only a per-user registry entry and does not require administrator rights
- Does not use the network, collect data, or change ChatGPT installation files

## Requirements

- Windows 10 or Windows 11
- Microsoft Store ChatGPT/Codex with support for `--open-project`
- .NET 8 SDK, or Visual Studio 2022 with the .NET desktop development workload

The code currently uses `OpenAI.Codex_2p2nqsd0c76g0!App` as the application AUMID. If a future ChatGPT/Codex update changes its package identity or launch arguments, update the constants in [OpenProjectInChatGPTLauncher.cs](OpenProjectInChatGPTLauncher.cs) and rebuild.

To inspect the installed ChatGPT/Codex app IDs, run:

```powershell
Get-StartApps | Where-Object { $_.Name -match 'ChatGPT|Codex' }
```

## Build

Run this from the repository root:

```powershell
dotnet publish .\OpenProjectInChatGPTLauncher.csproj -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true
```

The launcher will be written to:

```text
bin\Release\net8.0-windows\win-x64\publish\OpenProjectInChatGPTLauncher.exe
```

`OpenProjectInChatGPTLauncher.ico` is embedded during the build and is not required beside the executable at runtime.

## Install the context-menu entry

1. Copy the built EXE to a permanent location, such as `%LOCALAPPDATA%\OpenAI\OpenProjectInChatGPTLauncher.exe`
2. From the repository root, run the following command and replace the path with the actual location of the EXE

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Install-ContextMenu.ps1 -LauncherPath "$env:LOCALAPPDATA\OpenAI\OpenProjectInChatGPTLauncher.exe"
   ```

3. Right-click an existing folder in Explorer and select **Open project in ChatGPT**

The installer runs only when installing or removing the entry. The context menu invokes the WinExe directly, so normal use has no terminal flash.

If a broken vendor-provided menu entry with the same title is still present and points directly to a protected `WindowsApps` executable, repair, update, or reinstall the app first. This project intentionally does not remove unknown vendor registry entries.

## Uninstall

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\Install-ContextMenu.ps1 -Uninstall
```

This removes only the per-user entry created at `HKCU\Software\Classes\Directory\shell\OpenProjectInChatGPTLauncher`. It does not remove ChatGPT/Codex or any project folders.

## Troubleshooting

- **No valid project folder path was provided**: ensure the selected target is an existing local folder
- **Unable to open the project in ChatGPT**: ensure ChatGPT/Codex is installed and that its AUMID and `--open-project` remain supported
- **ChatGPT opens but the project does not**: fully exit ChatGPT and try again; if it persists, update the app and open an issue with the app version, Windows version, and error text

## Disclaimer and trademarks

This is an independent community project. It is not affiliated with, sponsored by, or endorsed by OpenAI. ChatGPT, OpenAI, and their related marks belong to their respective owners. The icon identifies the launch target only; use your own icon for redistributed or rebranded versions and do not imply an official relationship.

This project is available under the [MIT License](LICENSE).

