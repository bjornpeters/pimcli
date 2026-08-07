@{
    # PSScriptAnalyzer configuration for pimcli.
    #
    # Run against the repository root:
    #   Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1
    #
    # The default rule set is on. Only the exclusions below are turned off, and
    # each one is a rule that misfires against a deliberate pattern in this
    # module rather than a standard being waived.

    IncludeDefaultRules = $true

    ExcludeRules = @(
        # Fires on every New-* function. Most of ours are in-memory object
        # factories (New-PimEligibleRole, New-PimNavigation) that touch nothing
        # outside the pipeline, so there is no state change to confirm. The
        # functions that genuinely change state - the activation, decision and
        # deactivation calls - declare SupportsShouldProcess explicitly.
        'PSUseShouldProcessForStateChangingFunctions',

        # Every screen function takes -Session and -Context so the navigator can
        # invoke them all the same way, and several do not need both. The
        # not-yet-implemented provider functions also declare the parameters
        # their implementation will take. Both are intentional.
        'PSReviewUnusedParameter'
    )
}
