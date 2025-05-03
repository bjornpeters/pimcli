# pimcli.psm1
# Root module file for the pimcli PowerShell module

# Import all the private functions first
$privateScripts = Get-ChildItem -Path "$PSScriptRoot/private/*.ps1" -ErrorAction SilentlyContinue
foreach ($script in $privateScripts) {
    try {
        . $script.FullName
    }
    catch {
        Write-Error "Failed to import private function $($script.FullName): $_"
    }
}

# Import all the public functions
$publicScripts = Get-ChildItem -Path "$PSScriptRoot/public/*.ps1" -ErrorAction SilentlyContinue
foreach ($script in $publicScripts) {
    try {
        . $script.FullName
    }
    catch {
        Write-Error "Failed to import public function $($script.FullName): $_"
    }
}

# Public functions to export
$publicFunctions = @(
    'Start-PimCli'
)

# Export only the public functions
Export-ModuleMember -Function $publicFunctions