
# full qualified display name to WinForms assembly   
$assembly = "System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"  
  
function IsWinFormsLoaded() {   
    $loaded = [appdomain]::currentdomain.getassemblies()   
    $winforms = $loaded | ? { $_.fullname -like "system.windows*" }   
    return ($winforms -ne $null)       
}   
  
if (-not (IsWinFormsLoaded)) {   
    "Creating child AppDomain..."  
    $child = [appdomain]::Createdomain("child",$null,$null)   
  
    # create a remote instance of a WinForms Form in a child AppDomain   
    "Creating remote WinForms Form in child AppDomain... "  
    $handle = $child.CreateInstance($assembly, "System.Windows.Forms.Form")   
  
    # examine returned ObjectHandle   
    "Returned object is a {0}" -f $handle.GetType()   
    $handle | gm # dump methods   
  
    # Did WinForms get pulled into our AppDomain?   
    "Is Windows Forms loaded in this AppDomain? {0}" -f (IsWinFormsLoaded)   
  
    # attempt to manipulate remote object, so unwrap   
    "Unwrapping, examining methods..."  
    $form = $handle.Unwrap()   
    $form | gm | select -first 10   
  
    # is Windows Forms loaded now?   
    "Is Windows Forms loaded in this AppDomain? {0}" -f (IsWinFormsLoaded)   
  
} else {   
    write-warning "System.Windows.Forms is already loaded. Please disable PowerTab or other SnapIns that may load System.Windows.Forms and restart PowerShell."  
}  

exit