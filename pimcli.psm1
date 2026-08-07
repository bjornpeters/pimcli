# pimcli.psm1
# Root module file for the pimcli PowerShell module

# private/ is organised into core/, providers/ and screens/, so the search is
# recursive. Dot-sourcing only defines functions, so load order does not matter.
$privateScripts = Get-ChildItem -Path "$PSScriptRoot/private" -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue
foreach ($script in $privateScripts) {
    try {
        . $script.FullName
    }
    catch {
        Write-Error "Failed to import private function $($script.FullName): $_"
    }
}

# Import all the public functions
$publicScripts = Get-ChildItem -Path "$PSScriptRoot/public" -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue
foreach ($script in $publicScripts) {
    try {
        . $script.FullName
    }
    catch {
        Write-Error "Failed to import public function $($script.FullName): $_"
    }
}

# Public functions to export. Kept in sync by hand with FunctionsToExport in
# pimcli.psd1.
$publicFunctions = @(
    'Start-PimCli'
)

# Export only the public functions
Export-ModuleMember -Function $publicFunctions
