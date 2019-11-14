$Assem = ( 
    “Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c” , 
    “Microsoft.SharePoint.Publishing, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c”
    )
$Source = @” 
using System.Collections;
using System.Linq;
using System.Net;
using System.Reflection;

namespace Agitech.Network
{
	public static class Extensions
  {

		public static CookieCollection GetAllCookiesCollection(this CookieContainer container)
		{
			var allCookies = new CookieCollection();
			var domainTableField = container.GetType().GetRuntimeFields().FirstOrDefault(x => x.Name == "m_domainTable");
			var domains = (IDictionary)domainTableField.GetValue(container);

			foreach (var val in domains.Values)
			{
				var type = val.GetType().GetRuntimeFields().First(x => x.Name == "m_list");
				var values = (IDictionary)type.GetValue(val);
				foreach (CookieCollection cookies in values.Values)
				{
					allCookies.Add(cookies);
				}
			}
			return allCookies;
		}

	}
}
“@

#Add-Type -ReferencedAssemblies $Assem -TypeDefinition $Source -Language CSharp 
Add-Type -TypeDefinition $Source -Language CSharp 

<#
.SYNOPSIS
    Sets a known folder's path using SHSetKnownFolderPath.
.PARAMETER Folder
    The known folder whose path to get.
.NOTES
    Name: Get-KnownFolderPath
    Author: Agitech
.EXAMPLE
    Get-KnownFolderPath -KnownFolder Desktop
#>
function Get-Cookies {
	Param (
		[Parameter(Mandatory = $true)]
        [System.Net.CookieContainer]$CookieContainer
    )
    return [Agitech.Network.Extensions]::GetAllCookiesCollection($CookieContainer);

}