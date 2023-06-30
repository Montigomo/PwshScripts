

function Get-GPU{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ParameterName
    )

    $gpus = @{
        "1.0" = "GeForce 8800 Ultra, GeForce 8800 GTX, GeForce 8800 GTS";
        "2.1" = "GeForce GTX 560 Ti, GeForce GTX 550 Ti, GeForce GTX 460, GeForce GTS 450, GeForce GTS 450*, `
        GeForce GT 640 (GDDR3), GeForce GT 630, GeForce GT 620, GeForce GT 610, GeForce GT 520, GeForce GT 440, `
        GeForce GT 440*, GeForce GT 430, GeForce GT 430*, GeForce GT 420*, GeForce GTX 675M, GeForce GTX 670M, `
        GeForce GT 635M, GeForce GT 630M, GeForce GT 625M, GeForce GT 720M, GeForce GT 620M, GeForce 710M, `
        GeForce 610M, GeForce 820M, GeForce GTX 580M, GeForce GTX 570M, GeForce GTX 560M, GeForce GT 555M, `
        GeForce GT 550M, GeForce GT 540M, GeForce GT 525M, GeForce GT 520MX, GeForce GT 520M, GeForce GTX 485M, `
        GeForce GTX 470M, GeForce GTX 460M, GeForce GT 445M, GeForce GT 435M, GeForce GT 420M, GeForce GT 415M, GeForce 710M, GeForce 410M";
        "3.0" = "GeForce GTX 770, GeForce GTX 760, GeForce GT 740, GeForce GTX 690, GeForce GTX 680, GeForce GTX 670, `
        GeForce GTX 660 Ti, GeForce GTX 660, GeForce GTX 650 Ti BOOST, GeForce GTX 650 Ti, GeForce GTX 650, GeForce GTX 880M, `
        GeForce GTX 870M, GeForce GTX 780M, GeForce GTX 770M, GeForce GTX 765M, GeForce GTX 760M, GeForce GTX 680MX, `
        GeForce GTX 680M, GeForce GTX 675MX, GeForce GTX 670MX, GeForce GTX 660M, GeForce GT 750M, GeForce GT 650M, `
        GeForce GT 745M, GeForce GT 645M, GeForce GT 740M, GeForce GT 730M, GeForce GT 640M, GeForce GT 640M LE, GeForce GT 735M, GeForce GT 730M";
        "3.5" = "GeForce GTX Titan Z, GeForce GTX Titan Black, GeForce GTX Titan, GeForce GTX 780 Ti, GeForce GTX 780,`
        GeForce GT 640 (GDDR5), GeForce GT 630 v2, GeForce GT 730, GeForce GT 720, GeForce GT 710, GeForce GT 740M (64-bit, DDR3), GeForce GT 920M"
        "5.0" = "GeForce GTX 750 Ti, GeForce GTX 750, GeForce GTX 960M, GeForce GTX 950M, GeForce 940M, GeForce 930M, GeForce GTX 860M, GeForce GTX 850M, GeForce 845M, GeForce 840M, GeForce 830M, GeForce 920MX";
        "5.2" = "GeForce GTX Titan X, GeForce GTX 980 Ti, GeForce GTX 980, GeForce GTX 970, GeForce GTX 960, GeForce GTX 950, GeForce GTX 750 SE, GeForce GTX 980M, GeForce GTX 970M, GeForce GTX 965M";
        "6.1" = "Nvidia TITAN Xp, Titan X, GeForce GTX 1080 Ti, GeForce GTX 1080, GeForce GTX 1070 Ti, GeForce GTX 1070, GeForce GTX 1060, GeForce GTX 1050 Ti, `
        GeForce GTX 1050, GeForce GT 1030, GeForce GT 1010, MX350, MX330, MX250, MX230, MX150, MX130, MX110";
        "7.5" = "NVIDIA TITAN RTX, GeForce RTX 2080 Ti, RTX 2080 Super, RTX 2080, RTX 2070 Super, RTX 2070, `
        RTX 2060 Super, RTX 2060, GeForce GTX 1660 Ti, GTX 1660 Super, GTX 1660, GTX 1650 Super, GTX 1650"
        "8.6" = "GeForce RTX 3090, RTX 3080, RTX 3070, RTX 3060 Ti, RTX 3060, RTX 3050 Ti"
    }

    $sdks=@{
    "1.0" = "1.0, 1.1";
    "1.1" = "1.0, 1.1";
    "2.0" = "1.0, 1.1";
    "2.1-2.3.1" = "1.0-1.3";
    "3.0-3.1" = "1.0-2.0";
    "3.2" = "1.0-2.1";
    "4.0-4.2" = "1.0-2.1";
    "5.0-5.5" = "1.0-3.5";
    "6.0" = "1.0-3.5";
    "6.5" = "1.1-5.9";
    "7.0-7.5" = "2.0-5.9";
    "8.0" = "2.0-6.9";
    "9.0-9.2" = "3.0-7.0";
    "10.0-10.2" = "3.0-7.5";
    "11.0" = "3.5-8.0";
    "11.1-11.4" = "3.5-8.6";
    "11.5-11.7.1" = "3.5-8.7";
    "11.8" = "3.5-9.0";
    "12.0" = "5.0-9.0"
    }

    $computeVersion = [System.Version]::Parse("1.0");
    $sdk_version = [System.Version]::Parse("1.0");

    $gpu = Get-CimInstance Win32_VideoController | Where-Object {$_.VideoProcessor -match "(NVIDIA )?GeForce"}
    $gpu = $gpu.VideoProcessor
    #$gpu = "GeForce GTS 450"
    $gpu = $gpu -replace "NVIDIA ", ""

    foreach($item in $gpus.Keys)
    {
        if($gpus[$item].Contains($gpu))
        {
            $computeVersion = [System.Version]::Parse($item)
            break;
        }
    }

    $t = $sdks.GetEnumerator() | Sort-Object {
        if($_.Key -match '(?<vp>\d\d?\.\d\d?)(-(?<vs>\d\d?\.\d.?\d?))?'){
            [System.Version]::Parse($Matches["vp"])
        } 
    } -Descending

    foreach($item in $t)
    {
        if($item.Key -match '(?<vmin>\d\d?\.\d\d?)(-(?<vmax>\d\d?\.\d.?\d?))?'){
            if($Matches.ContainsKey("vmax")){
                $sdk_version = [System.Version]::Parse($Matches["vmax"])
            }else{
                $sdk_version = [System.Version]::Parse($Matches["vmin"])
            }
        } 
        if($item.Value -match '(?<cmin>\d\.\d)-(?<cmax>\d.\d)')
        {
            $cmin = [System.Version]::Parse($Matches["cmin"])
            $cmax = [System.Version]::Parse($Matches["cmax"])
            if($computeVersion -ge $cmin -and $computeVersion -le $cmax)
            {
                break
            }

        }else{
            $cca = $item.Value.Split(",")
            if($cca.Where({ $_ -eq $computeVersion }, 'First').Count -gt 0)
            {
                break           
            }
        }
    }
    return $sdk_version
}


#$cuda_sdk = [System.Version]::Parse("1.0");

$gpu = Get-CimInstance Win32_VideoController | Where-Object {$_.VideoProcessor -match "(NVIDIA )?GeForce"}

Write-Output $gpu

$cuda_sdk = Get-GPU

Write-Output $cuda_sdk

if($cuda_sdk.Major -gt 11){
    $cuda_sdk = [System.Version]::new(11, $cuda_sdk.Minor);
}
if($cuda_sdk.Major -eq 11 -and $cuda_sdk.Minor -gt 4){
    $cuda_sdk = [System.Version]::new($cuda_sdk.Major, 4);
}

Write-Output $cuda_sdk

# xmrig-cuda-6.17.0-cuda10_0-win64.zip
# xmrig-cuda-6.17.0-cuda10_1-win64.zip
# xmrig-cuda-6.17.0-cuda10_2-win64.zip
# xmrig-cuda-6.17.0-cuda11_0-win64.zip
# xmrig-cuda-6.17.0-cuda11_1-win64.zip
# xmrig-cuda-6.17.0-cuda11_2-win64.zip
# xmrig-cuda-6.17.0-cuda11_3-win64.zip
# xmrig-cuda-6.17.0-cuda11_4-win64.zip


[array]$arr = @(
    "xmrig-cuda.dll",
    $(if($cuda_sdk.Major -eq 11 -and ($cuda_sdk.Minor -ge 2 -or $cuda_sdk.Minor -le 4)) {"nvrtc64_112_0.dll"}
      elseif($cuda_sdk.Major -le 9 ) {"nvrtc64_$($cuda_sdk.Major)$($cuda_sdk.Minor).dll"}
      else{"nvrtc64_$($cuda_sdk.Major)$($cuda_sdk.Minor)_0.dll"}
      ),
    "nvrtc-builtins64_$($cuda_sdk.Major)$($cuda_sdk.Minor).dll")

Write-Output $arr


$gpu = Get-CimInstance Win32_VideoController
$gpu= $gpu | Where-Object { $_.VideoProcessor -match "(NVIDIA )?GeForce" }
$gpu = $gpu.VideoProcessor
#$gpu = $gpu -replace "NVIDIA ", ""

$driver = Get-CimInstance -ClassName Win32_PnPSignedDriver | Where-Object { $_.DeviceName -eq $gpu}

exit