

# WinAPI call SendMessage(HWND_BROADCAST, WM_SYSCOMMAND, SC_MONITORPOWER, 2) 
# where HWND_BROADCAST = 0xFFFF, WM_SYSCOMMAND = 0x0112 and SC_MONITORPOWER = 0xF170. 
# The 2 means the display is being shut off.
#
#
#

(Add-Type '[DllImport("user32.dll")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::SendMessage(-1,0x0112,0xF170,2)