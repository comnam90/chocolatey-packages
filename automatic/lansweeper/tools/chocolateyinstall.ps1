
$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"


function Test-InstallerParameters {
  [cmdletbinding(DefaultParameterSetName="Default")]
  param(
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
Write-Verbose "Installer Parameters = $InstallParams"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'exe'
  url           = 'https://cdn.lansweeper.com/download/8.4.0/9/LansweeperSetup.exe'
  url64bit      = 'https://cdn.lansweeper.com/download/8.4.0/9/LansweeperSetup.exe'
  softwareName  = 'Lansweeper'
  checksum      = '862558e1aedad6d07349358623702edb9f39a751355f3e4a54acdd513794aa1e'
  checksumType  = 'sha256'
  checksum64    = '862558e1aedad6d07349358623702edb9f39a751355f3e4a54acdd513794aa1e'
  checksumType64= 'sha256'
  silentArgs   = '/verysilent /accepteula /install',$InstallParams
  validExitCodes= @(0)
}

if($PP['Upgrade']){
  $packageArgs.silentArgs = $packageArgs.silentArgs.Replace("/install","/upgrade")
}

if(Get-AppInstallLocation -AppNamePattern $packageArgs.packageName){
  Write-Host "Detected Lansweeper installation - Upgrading"
  $packageArgs.silentArgs = '/verysilent /accepteula /upgrade'
}

Install-ChocolateyPackage @packageArgs 
