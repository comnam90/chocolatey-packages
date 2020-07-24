
$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Helper Function

function Test-InstallerParameters {
  [cmdletbinding(DefaultParameterSetName="Default")]
  param(
    [parameter(ParameterSetName = "Upgrade", Mandatory)]
    [switch]$Upgrade,
    [parameter(ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [ValidateScript(
      {
        if($_ -imatch '^(scan|db|web),*(scan|db|web)*,*(scan|db|web)*'){
          $true
        }else{
          throw "/parts must contain at least one valid option (SCAN,DB,WEB)"
        }
      }
    )]
    [string]$Parts,
    [parameter(ParameterSetName = "Default")]
    [ValidateSet("SqlLocalDb","SqlServer")]
    [string]$DbServer,
    [parameter(ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [string]$DbInstance,
    [parameter(ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [string]$DbUser,
    [parameter(ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [string]$DbPassword,
    [parameter(ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [string]$DbUserConfig,
    [parameter(ParameterSetName = "Default")]
    [switch]$AllowDbOverwrite,
    [parameter(ParameterSetName = "Default")]
    [ValidateSet("IISExpress","IIS")]
    [string]$WebServer,
    [parameter(ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [uint32]$HttpPort,
    [parameter(ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [uint32]$HttpsPort,
    [parameter(ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [string]$Folder,
    [parameter(ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [ValidateScript(
      {
        if( (Test-Path -Path $_) ){
          $true
        }else{
          throw "Cannot find encryption file $_"
        }
      }
    )]
    [string]$CredKeyFile,
    [parameter(ParameterSetName = "Default")]
    [parameter(ParameterSetName = "ConfigurationFile")]
    [switch]$NoDcomReset,
    [parameter(ParameterSetName = "ConfigurationFile", Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript(
      {
        if( (Test-Path -Path $_) ){
          $true
        }else{
          throw "Cannot find configuration file $_"
        }
      }
    )]
    [string]$ConfigurationFile
  )
  begin{
    if($PSCmdlet.ParameterSetName -ieq "Default"){
      if($PSBoundParameters.containsKey('DbInstance') -and -not $PSBoundParameters.containsKey('DbServer')){
        Throw "/dbserver must be included when using /dbinstance"
      }
      if($PSBoundParameters.containsKey('DbUser') -and -not $PSBoundParameters.containsKey('DbServer')){
        Throw "/dbserver must be included when using /dbuser"
      }
      if($PSBoundParameters.containsKey('DbPassword') -and -not $PSBoundParameters.containsKey('DbServer')){
        Throw "/dbserver must be included when using /dbpassword"
      }
      if($PSBoundParameters.containsKey('DbUser') -and -not $PSBoundParameters.containsKey('DbPassword')){
        throw "/dbuser must be included when using /dbpassword"
      }
      if($PSBoundParameters.containsKey('DbPassword') -and -not $PSBoundParameters.containsKey('DbUser')){
        throw "/dbpassword must be included when using /dbuser"
      }
      if($PSBoundParameters.containsKey('DbUserConfig') -and -not $PSBoundParameters.containsKey('DbServer')){
        Throw "/dbserver must be included when using /dbuserconfig"
      }
      if($PSBoundParameters.containsKey('HttpPort') -and -not $PSBoundParameters.containsKey('WebServer')){
        Throw "/webserver must be included when using /httpport"
      }
      if($PSBoundParameters.containsKey('HttpsPort') -and -not $PSBoundParameters.containsKey('WebServer')){
        Throw "/webserver must be included when using /httpsport"
      }
    }
  }
  process{
    $returnParameters = switch($PSBoundParameters.Keys){
      "parts" { "/parts=""$Parts""" }
      "dbserver" { "/dbserver=""$DbServer""" }
      "dbinstance" { "/dbinstance=""$DbInstance""" }
      "dbuser" { "/dbuser=""$DbUser""" }
      "dbpassword" { "/dbpassword=""$DbPassword""" }
      "dbuserconfig" { "/dbuserconfig=""$dbuserconfig""" }
      "allowdboverwrite" { "/allowdboverwrite" }
      "webserver" { "/webserver=""$webserver""" }
      "httpport" { "/httpport=$httpport" }
      "httpsport" { "/httpsport=httpsport" }
      "folder" { "/folder=""$folder""" }
      "credkeyfile" { "/credkeyfile=""$credkeyfile""" }
      "noDCOMReset" { "/noDCOMReset" }
      "ConfigurationFile" { "/ConfigurationFile=""$ConfigurationFile""" }
    }
  }
  end{
    $returnParameters -join " "
  }
}


$PP = Get-PackageParameters
$InstallParams = " "
$InstallParams += Test-InstallerParameters @PP -Verbose
Write-Host "Installer Parameters = $InstallParams"
<#
if($PP['parts']){$InstallParams += "/parts=""$($PP['parts'])"" "}
if($PP['dbserver']){$InstallParams += "/dbserver=""$($PP['dbserver'])"" "}
if($PP['dbinstance']){$InstallParams += "/dbinstance=""$($PP['dbinstance'])"" "}
if($PP['dbuser']){$InstallParams += "/dbuser=""$($PP['dbuser'])"" "}
if($PP['dbpassword']){$InstallParams += "/dbpassword=""$($PP['dbpassword'])"" "}
if($PP['dbuserconfig']){$InstallParams += "/dbuserconfig=""$($PP['dbuserconfig'])"" "}
if($PP['allowdboverwrite']){$InstallParams += "/allowdboverwrite=""$($PP['allowdboverwrite'])"" "}
if($PP['webserver']){$InstallParams += "/webserver=""$($PP['webserver'])"" "}
if($PP['httpport']){$InstallParams += "/httpport=$($PP['httpport']) "}
if($PP['httpsport']){$InstallParams += "/httpsport=$($PP['httpsport']) "}
if($PP['folder']){$InstallParams += "/folder=""$($PP['folder'])"" "}
if($PP['credkeyfile']){$InstallParams += "/credkeyfile=""$($PP['credkeyfile'])"" "}
if($PP['noDCOMReset']){$InstallParams += "/noDCOMReset=""$($PP['noDCOMReset'])"" "}
if($PP['ConfigurationFile']){$InstallParams += "/ConfigurationFile=""$($PP['ConfigurationFile'])"" "}

if( ($PP['httpport'] -or $PP['httpsport']) -and ! $PP['webserver'] ){
  Write-Error -Message "/httpport or /httpsport cannot be specified without also providing /webserver"
}
#>

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'exe'
  url           = 'https://cdn.lansweeper.com/download/8.0.130/23/LansweeperSetup.exe'
  url64bit      = 'https://cdn.lansweeper.com/download/8.0.130/23/LansweeperSetup.exe'
  softwareName  = 'Lansweeper'
  checksum      = 'fac81e47b7f6c916c6624638fef87a6522b89322e9e06955119ad05cd10ee2b9'
  checksumType  = 'sha256'
  checksum64    = 'fac81e47b7f6c916c6624638fef87a6522b89322e9e06955119ad05cd10ee2b9'
  checksumType64= 'sha256'
  silentArgs   = '/verysilent /accepteula /install',$InstallParams
  validExitCodes= @(0)
}

if($PP['Upgrade']){
  $packageArgs.silentArgs = $packageArgs.silentArgs.Replace("/install","/upgrade")
}

Install-ChocolateyPackage @packageArgs 
