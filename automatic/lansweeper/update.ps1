import-module au

$releases = 'https://www.lansweeper.com/changelog/'

function global:au_SearchReplace {
    @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*url\s*=\s*)('.*')"        = "`$1'$($Latest.URL32)'"
            "(?i)(^\s*url64bit\s*=\s*)('.*')"   = "`$1'$($Latest.URL32)'"
            "(?i)(^\s*checksum\s*=\s*)('.*')"   = "`$1'$($Latest.Checksum32)'"
            "(?i)(^\s*checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
        }
    }
}
 
function global:au_GetLatest {
    $re = '\>(?<Version>[\d\.]+),'
 
    $global:ProgressPreference = 'SilentlyContinue'
    $release_page = Invoke-WebRequest -Uri $releases -UseBasicParsing
    $Global:ProgressPreference = 'Continue'
    $download_page_template = "https://cdn.lansweeper.com/download/{0}.{1}.{2}/{3}/LansweeperSetup.exe"
    $version = $release_page.links | ? outerhtml -match $re | select -First 1 -Expand outerhtml | % {
        if ($_ -imatch $re) { [version]$Matches['Version'] }
    }
    $url = $download_page_template -f $version.Major, $version.minor, $version.build, $version.revision
     
    $current_checksum = (gi $PSScriptRoot\tools\chocolateyInstall.ps1 | sls '\bchecksum\b') -split "=|'" | Select -Last 1 -Skip 1
    if ($current_checksum.Length -ne 64) { throw "Can't find current checksum" }
    $global:ProgressPreference = 'SilentlyContinue'
    $remote_checksum = Get-RemoteChecksum $url
    $Global:ProgressPreference = 'Continue'
    if ($current_checksum -ne $remote_checksum) {
        Write-Host 'Remote checksum is different then the current one, forcing update'
        $global:au_old_force = $global:au_force
        $global:au_force = $true
    }
    @{
        Version    = $version
        URL32      = $url
        Checksum32 = $remote_checksum
    }
}
 
if ($MyInvocation.InvocationName -ne '.') {
    # run the update only if script is not sourced
    update -ChecksumFor none
    if ($global:au_old_force -is [bool]) { $global:au_force = $global:au_old_force }
}