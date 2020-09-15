
$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$PP = Get-PackageParameters
$InstallParams = ""
if($PP['server']){$InstallParams += "--server $($PP['server']) "}
if($PP['port']){$InstallParams += "--port $($PP['port']) "}
if($PP['prefix']){$InstallParams += "--prefix $($PP['prefix']) "}
if($PP['agentkey']){$InstallParams += "--agentkey $($PP['agentkey']) "}

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'exe'
  url           = 'https://cdn.lansweeper.com/download/7.2.110/18/LsAgent-windows.exe'
  softwareName  = 'LsAgent'
  checksum      = 'a98112af10762e67d03fcec05d345f367aa06cf93a3cb0a92ea2f3aaa7aad6f7'
  checksumType  = 'sha256'
  silentArgs   = '--mode unattended',$InstallParams
  validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs 
