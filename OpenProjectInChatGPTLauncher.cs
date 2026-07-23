using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

[Flags]
internal enum ActivateOptions
{
    None = 0
}

[ComImport]
[Guid("2e941141-7f97-4756-ba1d-9decde894a3d")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
internal interface IApplicationActivationManager
{
    [PreserveSig]
    int ActivateApplication(
        [MarshalAs(UnmanagedType.LPWStr)] string appUserModelId,
        [MarshalAs(UnmanagedType.LPWStr)] string arguments,
        ActivateOptions options,
        out uint processId
    );
}

[ComImport]
[Guid("45BA127D-10A8-46EA-8AB7-56EA9078943C")]
internal class ApplicationActivationManager
{
}

internal static class Program
{
    private const string AppUserModelId = "OpenAI.Codex_2p2nqsd0c76g0!App";
    private const string ProcessName = "ChatGPT";

    [STAThread]
    private static int Main(string[] arguments)
    {
        try
        {
            var suppliedPath = string.Join(" ", arguments).Trim().Trim('"');
            if (string.IsNullOrWhiteSpace(suppliedPath) || !Directory.Exists(suppliedPath))
            {
                MessageBox.Show(
                    "No valid project folder path was provided",
                    "Open project in ChatGPT",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
                return 2;
            }

            var projectPath = Path.GetFullPath(suppliedPath);
            var wasRunning = IsChatGptRunning();
            var processId = ActivateProject(projectPath);

            if (!wasRunning)
            {
                WaitForChatGptReady(processId, TimeSpan.FromSeconds(30));
                Thread.Sleep(1000);
                ActivateProject(projectPath);
            }

            return 0;
        }
        catch (Exception exception)
        {
            MessageBox.Show(
                "Unable to open the project in ChatGPT:\r\n" + exception.Message,
                "Open project in ChatGPT",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error
            );
            return 1;
        }
    }

    private static uint ActivateProject(string projectPath)
    {
        var activationManager = (IApplicationActivationManager)new ApplicationActivationManager();
        uint processId;
        var result = activationManager.ActivateApplication(
            AppUserModelId,
            "--open-project \"" + projectPath + "\"",
            ActivateOptions.None,
            out processId
        );

        if (result < 0)
        {
            Marshal.ThrowExceptionForHR(result);
        }

        return processId;
    }

    private static bool IsChatGptRunning()
    {
        var processes = Process.GetProcessesByName(ProcessName);
        foreach (var process in processes)
        {
            process.Dispose();
        }

        return processes.Length != 0;
    }

    private static bool IsChatGptReady()
    {
        foreach (var process in Process.GetProcessesByName(ProcessName))
        {
            using (process)
            {
                if (process.MainWindowHandle != IntPtr.Zero)
                {
                    return true;
                }
            }
        }

        return false;
    }

    private static void WaitForChatGptReady(uint processId, TimeSpan timeout)
    {
        var deadline = DateTime.UtcNow.Add(timeout);
        while (DateTime.UtcNow < deadline)
        {
            if (HasMainWindow(processId) || IsChatGptReady())
            {
                return;
            }

            Thread.Sleep(200);
        }
    }

    private static bool HasMainWindow(uint processId)
    {
        try
        {
            using (var process = Process.GetProcessById((int)processId))
            {
                process.Refresh();
                return process.MainWindowHandle != IntPtr.Zero;
            }
        }
        catch (ArgumentException)
        {
            return false;
        }
    }
}
