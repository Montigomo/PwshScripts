

function Install-Fonts
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [Alias('From')]
        [string]$FromPath
    )

    Begin{}
    Process
    {
        $FONTS = 0x14
        $objShell = New-Object -ComObject Shell.Application
        $objFolder = $objShell.Namespace($FONTS)
        # Set path to the fonts dir
        if([string]::IsNullOrWhiteSpace($FromPath) -or !(Test-Path -Path $FromPath)) {exit}
        #$FromPath="D:\_software\cliparts bruches icons etc\Fonts\100 Best Fonts Ever Made"

        $objShell = New-Object -ComObject Shell.Application
        $objFolder = $objShell.Namespace($FONTS)
        
        $CopyOptions = 4 + 16
        $CopyFlag = [String]::Format("{0:x}", $CopyOptions)
        
        #loop through each directory in the specified path looking for files with extensions starting with .tt or .o
        foreach($File in $(Get-ChildItem -Path $FromPath -Include *.ttf,*.otf,*.fon,*.fnt -Recurse)) {
            If (!(test-path "c:\windows\fonts\$($File.name)")) 
            {
                #$fontName = $File.Name.Replace(".ttf", " Regular")
                #$objFolderItem = $objFolder.ParseName($fontName);
                #if (!$objFolderItem)
                {
                    #$objFolder.CopyHere($File.fullname,0x14)
                    $copyFlag = [String]::Format("{0:x}", $CopyOptions)
                    #      "copying $($file.fullname)"           # Useful for debugging
                    #installs fonts found in above loop to the Fonts directory
                    $objFolder.CopyHere($File.fullname, $CopyOptions)
                }
            }
            #else{"$File already exists - not copying"}  #Useful for testing
        }
        #$objFolder.CopyHere("C:\test\Myfont.ttf")
    }
}

Install-Fonts -FromPath "D:\_software\cliparts bruches icons etc\Fonts\100 Best Fonts Ever Made"