$win10_Y1_ESU = "f520e45e-7413-4a34-a497-d2765967d094"
$win10_Y1_Key = "94N2X-TFDRD-FRV4Q-QP7DW-82VPJ"


function Test-ESUKey {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$Key
    )
    # Check if the ESU key is valid for Windows 10 ESU                                  
    $PartialKey = $Key.Substring($Key.Length - 5)
    $Licensed = Get-WmiObject -Query ('SELECT ID, Name, OfflineInstallationId, ProductKeyID FROM SoftwareLicensingProduct where PartialProductKey = "{0}"' -f $PartialKey)
    # Check if the key is Activated
    $ActivationStatus = Get-WmiObject -Query ('SELECT LicenseStatus FROM SoftwareLicensingProduct where PartialProductKey = "{0}"' -f $PartialKey)
    if ($Licensed -and $ActivationStatus.LicenseStatus -eq 1) {
        Write-Verbose "ESU key is valid and activated."
        return $true
    }
    else {
        if (!$Licensed) {
            Write-Verbose "No valid ESU key found"
        }
        else {
            Write-Verbose "Valid ESU key found"
        }
        If ($ActivationStatus.LicenseStatus -ne 1) {
            Write-Verbose "ESU key is not activated."
        }
        return $false
    }
}
try {
    # Retrieve license details
    $slmgrOutput = Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "ID LIKE '$win10_Y1_ESU' AND LicenseStatus = 1" -ErrorAction SilentlyContinue
 
    if ($slmgrOutput) {
        Write-Host "ESU key is installed and LICENSED."
        exit 0
    }
    else {
        Write-Host "ESU license not found activating please wait"
        # Year 1 ESU Key
        cscript.exe //Nologo slmgr.vbs /ipk $win10_Y1_Key | Out-Null 
        Start-sleep -Seconds 30
        cscript.exe //Nologo slmgr.vbs /ato $win10_Y1_ESU | Out-Null 
        Start-Sleep -Seconds 120
        $ESUY1Status = Test-ESUKey -Key $win10_Y1_Key
        If ($ESUY1Status -eq $true) {
            Write-Output "Year 1 ESU Key is valid and activated."
            exit 0
        }
        else {
            Write-Output "Year 1 ESU Key is not valid or not activated."
            exit 1
        }
    
    }
}
catch {
    Write-Host "Error during detection: $($_.Exception.Message)"
    exit 1 # Exit with 1 if an error occurs during detection
}




