﻿
$ErrorActionPreference = 'Stop'; # stop on all errors
$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  softwareName  = 'Lansweeper*'  
  fileType      = 'exe' 
  silentArgs   = '/verysilent'        
}

$uninstalled = $false
[array]$key = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']

if ($key.Count -eq 1) {
  $key | % { 
    $packageArgs['file'] = "$($_.UninstallString)" #NOTE: You may need to split this if it contains spaces, see below
    
    if ($packageArgs['fileType'] -eq 'MSI') {
      $packageArgs['silentArgs'] = "$($_.PSChildName) $($packageArgs['silentArgs'])"
      $packageArgs['file'] = ''
    } else {
     }

    Uninstall-ChocolateyPackage @packageArgs
  }
} elseif ($key.Count -eq 0) {
  Write-Warning "$packageName has already been uninstalled by other means."
} elseif ($key.Count -gt 1) {
  Write-Warning "$($key.Count) matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert package maintainer the following keys were matched:"
  $key | % {Write-Warning "- $($_.DisplayName)"}
}

