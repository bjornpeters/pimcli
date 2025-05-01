# pimcli.psm1
# Root module file for the pimcli PowerShell module

# The nested modules in the module manifest will automatically load all the functions,
# but we need to make sure only the public ones are exported.

# All functions defined in the Public directory are considered public and will be exported
$publicFunctions = @(
    'Start-PimCli'
)

# Export public functions
Export-ModuleMember -Function $publicFunctions
# Don't export any aliases or variables
Export-ModuleMember -Alias * -Variable *