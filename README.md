# Open Project in ChatGPT Launcher

[English](README.en.md)

一个 Windows 右键菜单启动器，用于解决部分 Microsoft Store 版 ChatGPT/Codex 在资源管理器中直接启动受保护的 `WindowsApps\\...\\ChatGPT.exe` 时出现“拒绝访问”的问题。

它通过 Windows 的应用激活接口打开 ChatGPT，并把被右键点击的目录作为 `--open-project` 参数传入。若 ChatGPT 尚未启动，启动器会等待主窗口就绪后再次投递项目路径，从而兼顾冷启动场景。

## 功能

- 右键任意存在的本地文件夹，选择 **Open project in ChatGPT**
- 直接调用无控制台窗口的 WinExe，不会在每次使用菜单时闪现 PowerShell、cmd 或 Terminal
- 冷启动 ChatGPT 后再次投递项目路径
- 使用当前用户的注册表项，不需要管理员权限
- 不联网、不收集数据、不修改 ChatGPT 的安装文件

## 前提条件

- Windows 10 或 Windows 11
- 已安装 Microsoft Store 版 ChatGPT/Codex，并且该版本支持 `--open-project`
- .NET 8 SDK，或带有 .NET 桌面开发工作负载的 Visual Studio 2022

当前源代码默认使用的应用 AUMID 是 `OpenAI.Codex_2p2nqsd0c76g0!App`。若未来 ChatGPT/Codex 的包标识或启动参数发生变化，需要调整 [OpenProjectInChatGPTLauncher.cs](OpenProjectInChatGPTLauncher.cs) 中的常量后重新构建。

可用以下命令检查本机可见的 ChatGPT/Codex 应用标识：

```powershell
Get-StartApps | Where-Object { $_.Name -match 'ChatGPT|Codex' }
```

## 构建

在仓库根目录执行：

```powershell
dotnet publish .\OpenProjectInChatGPTLauncher.csproj -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true
```

生成的启动器位于：

```text
bin\Release\net8.0-windows\win-x64\publish\OpenProjectInChatGPTLauncher.exe
```

`OpenProjectInChatGPTLauncher.ico` 会在构建时嵌入 EXE，运行时不需要与 EXE 放在一起。

## 安装右键菜单

1. 将生成的 EXE 复制到一个不会再移动的位置，例如 `%LOCALAPPDATA%\OpenAI\OpenProjectInChatGPTLauncher.exe`
2. 在仓库根目录执行下面命令，并将路径替换成实际 EXE 路径

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Install-ContextMenu.ps1 -LauncherPath "$env:LOCALAPPDATA\OpenAI\OpenProjectInChatGPTLauncher.exe"
   ```

3. 在资源管理器中右键一个存在的文件夹，选择 **Open project in ChatGPT**

安装脚本只在安装或卸载时运行一次。实际右键菜单会直接启动 EXE，因此不会产生终端闪窗。

若系统中已有同名的官方菜单项且仍指向受保护的 `WindowsApps` 可执行文件，请先在应用修复、更新或重装后再测试。这个项目不会修改或删除未知的官方注册表项，以避免误伤其他应用版本。

## 卸载

执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\Install-ContextMenu.ps1 -Uninstall
```

这只会删除本项目在 `HKCU\Software\Classes\Directory\shell\OpenProjectInChatGPTLauncher` 创建的当前用户菜单项，不会删除 ChatGPT/Codex 或其项目文件夹。

## 故障排查

- **No valid project folder path was provided**：请确认右键目标是一个仍然存在的本地目录
- **Unable to open the project in ChatGPT**：确认 ChatGPT/Codex 已安装，并检查 AUMID 与 `--open-project` 是否仍被当前应用版本支持
- **只启动应用但没有打开项目**：完全退出 ChatGPT 后重试；若仍然存在，升级应用并在 GitHub Issue 中附上应用版本、Windows 版本和错误信息

## 免责声明与商标

这是一个独立的社区项目，与 OpenAI 没有从属、赞助或背书关系。ChatGPT、OpenAI 及相关标志属于各自权利人。图标仅用于识别其启动目标；分发再品牌版本时，请使用自己的图标并避免暗示官方关系。

本项目采用 [MIT License](LICENSE)。

