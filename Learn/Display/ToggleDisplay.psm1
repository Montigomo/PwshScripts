Add-Type -Namespace Win32API -Name Message -MemberDefinition @'
[DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessage(
        int hWnd,
        UInt32 Msg,
        int wParam,
        int lParam
    );
'@

$msg = @{
    HWND_Broadcast = 0xFFFF
    WM_SysCommand = 0x0112
    SC_MonitorPower = 0xF170
    PowerOn = -1
    PowerOff = 2
}

Function Start-Display {
    <#
    .SYNOPSIS
    Turns on the display of the computer.

    .DESCRIPTION
    Start-Display turns on the display of the computer. This does not turn on the physical monitor, but it will bring the display up from a low-power state.
    
    .INPUTS
    None.  You cannot pipe objects to Start-Display.

    .OUTPUTS
    None.  Start-Display does not generate any output.

    .EXAMPLE
    PS C:\> Start-Display

    This command will turn on the display of the computer.

    .LINK
    Add-Type
    #>

    [CmdletBinding(HelpURI='https://gallery.technet.microsoft.com/Turn-the-Display-On-and-Off-3414d706')]
    
    Param()

    [Win32API.Message]::SendMessage($msg.HWND_Broadcast, $msg.WM_SysCommand, $msg.SC_MonitorPower, $msg.PowerOn) 
}

Function Stop-Display {
    <#
    .SYNOPSIS
    Turns off the display of the computer.

    .DESCRIPTION
    Stop-Display turns off the display of the computer. This does not turn off the physical monitor, but it will send the display to a low-power state.
    
    .INPUTS
    None.  You cannot pipe objects to Stop-Display.

    .OUTPUTS
    None.  Stop-Display does not generate any output.

    .EXAMPLE
    PS C:\> Stop-Display

    This command will turn on the display of the computer.

    .LINK
    Add-Type
    #>

    [CmdletBinding(HelpURI='https://gallery.technet.microsoft.com/Turn-the-Display-On-and-Off-3414d706')]

    Param()

    [Win32API.Message]::SendMessage($msg.HWND_Broadcast, $msg.WM_SysCommand, $msg.SC_MonitorPower, $msg.PowerOff)
}

New-Alias -Name sadp -Value Start-Display
New-Alias -Name spdp -Value Stop-Display