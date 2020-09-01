
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
  url           = 'https://cdn.lansweeper.com/download/7.2.110/16/LsAgent-windows.exe'
  softwareName  = 'LsAgent'
  checksum      = '65df40633e6afbd68932cd6c6567dba7fa3cd18ea2350c1d431431480f091ba7'
  checksumType  = 'sha256'
  silentArgs   = '--mode unattended',$InstallParams
  validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs 
