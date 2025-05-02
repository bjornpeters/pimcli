# Get the directory where the script is located
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleName = 'pimcli'

# Import module when it
if (-not (Get-Module -Name $moduleName)) {
    Write-Host "Import module '$moduleName'."
    Import-Module -Name "$scriptPath/$moduleName.psd1"
}
else {
    Write-Host "Module already imported."
}