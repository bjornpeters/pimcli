# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project goal

`pimcli` is a PowerShell module that provides an interactive CLI for **Privileged Identity Management (PIM)** covering **both Azure resources (ARM) and Entra ID roles**. Users should be able to view, request, activate, approve, deny, and otherwise manage PIM assignments from the terminal.

End goal: publish to the **PowerShell Gallery** as a consumable module.

### Non-negotiable constraints

| Constraint | Detail |
|---|---|
| Runtime | PowerShell **7.x** only (`PowerShellVersion = '7.0'` in the manifest). No Windows PowerShell 5.1 support. |
| Cross-platform | Must run on Windows, Linux and macOS — the devcontainer is Ubuntu. Never assume Windows-only paths, APIs or hosts. |
| Authentication | **Az PowerShell module only** (`Az.Accounts`). Tokens come from `Get-AzAccessToken`. Do not add MSAL, Azure CLI shelling out, or `Connect-MgGraph` for auth. |
| PIM operations | **Direct REST calls** against the ARM and Microsoft Graph APIs via `Invoke-RestMethod`. Do not use `Microsoft.Graph.*` cmdlets or `Az.Resources` PIM cmdlets for PIM logic. |
| Dependencies | Declared in `RequiredModules` with a minimum version so the Gallery installs them automatically. Keep the surface minimal — anything beyond `Az.Accounts`/`Az.Resources` needs an explicit decision first. |
| Code style | PowerShell best practices — approved verbs, `[CmdletBinding()]`, comment-based help, `ShouldProcess` on state-changing functions, PSScriptAnalyzer clean. |

## Repository layout

```
pimcli.psd1                  Module manifest (version, exports, dependencies)
pimcli.psm1                  Root module — recursively dot-sources private/ then public/
public/                      Exported functions (one function per file, file named after the function)
private/core/                Navigation, provider dispatch, tokens, config, rendering
private/providers/azure/     Azure resource PIM against ARM
private/providers/entra/     Entra ID role PIM against Microsoft Graph
private/screens/             One file per interactive screen
PSScriptAnalyzerSettings.psd1  Lint config; exclusions are documented inline
New-OfflineImport.ps1        Dev helper: imports the module from source for local testing
Publish-PimCli.ps1           Publishes to the PowerShell Gallery using $env:NUGET_API_KEY
.github/workflows/           CI: publish.yaml runs Publish-PimCli.ps1 on a `v*` tag push
.devcontainer/               Ubuntu devcontainer with pwsh, Az, Microsoft.Graph modules
```

`private/` is searched recursively, so the subfolders are organisation only. Dot-sourcing just defines functions, so load order never matters.

### Conventions

- **One function per file.** File name matches the function name exactly.
- New **exported** function: add the file to `public/`, then add the name to `FunctionsToExport` in `pimcli.psd1` **and** to the `$publicFunctions` array in `pimcli.psm1`. Both lists are maintained by hand and must stay in sync.
- New **internal** function: add the file to `private/` only. No manifest change.
- Approved PowerShell verbs only.

Naming has three tiers, and picking the wrong one is how the provider split leaks into the UI:

| Tier | Pattern | Example | Lives in |
|---|---|---|---|
| Neutral | `*-Pim*` | `Get-PimAccessToken`, `Show-PimTable` | `private/core/`, `private/screens/` |
| Azure provider | `*-AzPim*` | `Get-AzPimEligibleRole` | `private/providers/azure/` |
| Entra provider | `*-EntraPim*` | `Get-EntraPimEligibleRole` | `private/providers/entra/` |

Screens and core code are always neutral. Only a provider function may name its surface.

## Architecture

Both PIM surfaces are the same engine with different serialization — the endpoints mirror each other one for one. So Entra ID is a **second backend behind one set of screens**, not a second half of the UI. Three pieces hold that together.

**Provider registry.** `Initialize-PimProvider` maps each provider to the function implementing each operation. `Invoke-PimProviderOperation` is the only thing screens call:

- Read operations fan out over every provider allowed by the scope filter and return one merged collection.
- Providers are isolated. One failing lands in `Errors`; the others still return rows.
- An operation not implemented yet lands in `Unavailable`, rendered as a note. **An unimplemented backend must never contribute an empty result that reads as "you have no access".** New provider functions throw `NotImplementedException` until they are real.
- Write operations require `-Provider`; fanning a decision across surfaces is never meant.

**Normalized objects.** Providers project their payloads through `New-PimEligibleRole`, `New-PimActiveRole` and `New-PimApprovalRequest`, so screens see one shape and the original payload stays on `Raw`. A new surface costs a projection, not a screen.

**Navigation stack.** Screens never call each other. Each takes `-Session` and `-Context`, renders, reads input, and returns a directive from `New-PimNavigation` (`Push`/`Pop`/`Home`/`Stay`/`Exit`). `Invoke-PimNavigation` owns the stack. The call stack stays flat at any depth, and `back` behaves the same everywhere. Register a new screen in `Get-PimScreen`.

### UI rules

- **Action-first navigation.** The top level is the task, not the surface. Azure and Entra rows appear in the same list with a `Source` column. Provider is an attribute, never a menu level.
- **Scope filter.** `Session.Scope` is `All`, `Azure` or `Entra`, shown in every header. Narrowing it means the other provider is never queried.
- Read input through `Read-PimChoice` so `b`/`q`/`r` work everywhere; render lists with `Show-PimTable`; report gaps with `Show-PimProviderNote`.
- Pause with `Wait-PimKey`, never a bare `Read-Host` — a bare call emits the typed line into the screen's output and corrupts the navigation directive.
- Never default a justification. It is written to the audit record and read by an approver.

## Local development

Import the module from source:

```powershell
./New-OfflineImport.ps1
```

Then run the CLI:

```powershell
Start-PimCli
```

Note that `New-OfflineImport.ps1` skips the import when the module is already loaded — use `Import-Module ./pimcli.psd1 -Force` to pick up edits in an existing session.

## Branching strategy

`main` is the only long-lived branch. It must always be in a releasable state, because release tags are cut from it and a `v*` tag triggers the publish workflow. Never commit directly to `main` — all work lands through a pull request.

Branch off `main`, prefix by intent:

| Prefix | Use for |
|---|---|
| `feature/` | New functionality — a new cmdlet, a new menu action, Entra ID support. |
| `bug/` | Fixing broken behaviour in existing functionality. |
| `chore/` | Repo plumbing that is neither a feature nor a bug — `.gitignore`, CI workflow edits, manifest metadata, dependency bumps. |
| `docs/` | Documentation only — `README.md`, `CLAUDE.md`, comment-based help. |
| `release/` | Version bump and release prep before tagging (see Publishing). |

Naming: `<prefix>/<short-description>`. The existing `feature/roleActivation` branch uses camelCase; prefer kebab-case (`feature/role-activation`, `bug/psm1-path-separator`) for new branches so the descriptive part stays readable, and rename rather than adding a third style.

Merging: pull requests into `main` are **squash-merged**, so one branch becomes one commit on `main`. Keep the PR title in the imperative mood — it becomes the commit subject and, in practice, the changelog line. Work-in-progress commit hygiene on the branch itself matters less because of the squash.

Delete branches after merge.

## Publishing

Publishing is tag-driven: pushing a `v*` tag triggers `.github/workflows/publish.yaml`, which runs `Publish-PimCli.ps1` with the `POWERSHELL_GALLERY_API_KEY` secret. Bump `ModuleVersion` in `pimcli.psd1` before tagging — the Gallery rejects a re-publish of an existing version.

Release flow: cut a `release/x.y.z` branch, bump `ModuleVersion` (and `ReleaseNotes` in `PrivateData.PSData`), merge to `main`, then tag that merge commit `vx.y.z` and push the tag. Tag `main` only — the workflow publishes whatever the tag points at, so a tag on an unmerged branch would ship unreviewed code. There are no tags in the repo yet; nothing has been published.

## Current state

The navigation, provider dispatch and session layers are complete. All three screens render and are reachable; what varies is how many of the six provider operations are live behind them.

Live against the API:

| Operation | Azure | Entra |
|---|---|---|
| `GetEligibleRole` | `Get-AzPimEligibleRole` — `roleEligibilitySchedules?$filter=asTarget()` | stub |
| `GetApprovalRequest` | `Get-AzPimApprovalRequest` — `roleAssignmentScheduleRequests?$filter=asApprover()` | stub |
| `NewDecision` | `New-AzPimDecisionRequest` — reads `stages`, `PUT`s the decision | stub |
| `GetActiveRole` | stub | stub |
| `NewActivation` | stub | stub |
| `RemoveActiveRole` | stub | stub |

Every stub throws `NotImplementedException` and carries the endpoint and request shape for its implementation in its comment-based help. Nothing fabricates a result.

Supporting code: `Connect-PimSession` / `Disconnect-PimSession`, `Get-PimAccessToken` (cached per audience), `Get-PimPrincipalId`, `Get-AzPimRoleManagementPolicy` (works, not yet wired into the registry — its `SubscriptionId`/`ResourceGroupName`/`ResourceName` signature predates the normalized scope model and needs reshaping first).

Next steps, in dependency order:

1. `Get-AzPimActiveRole` and `Get-EntraPimEligibleRole` / `Get-EntraPimActiveRole` — reads, so they are the cheapest way to prove the merged list against a real tenant.
2. Reshape `Get-AzPimRoleManagementPolicy` around `ScopeId` and register it as a `GetPolicy` operation, so the activation form can source max duration and whether justification or a ticket is mandatory instead of hard-coding a 1–24 hour range.
3. The write operations.

## API reference

Azure resource PIM — base `https://management.azure.com`:

- `providers/Microsoft.Authorization/roleAssignmentScheduleRequests` — activation requests
- `providers/Microsoft.Authorization/roleEligibilitySchedules` — what a user is eligible for
- `providers/Microsoft.Authorization/roleAssignmentSchedules` — currently active assignments
- `{approvalId}/stages` — approval stages; `PUT` a stage to record a decision

Entra ID role PIM — base `https://graph.microsoft.com/v1.0` (some surfaces are `beta`):

- `roleManagement/directory/roleAssignmentScheduleRequests`
- `roleManagement/directory/roleEligibilitySchedules`
- `roleManagement/directory/roleAssignmentScheduleInstances`

Graph requires a Graph-audience token — `Get-AzAccessToken -ResourceUrl 'https://graph.microsoft.com'`, not the default ARM token.

## Known issues and gotchas

These are real defects in the current code. Fix them when touching the surrounding code; don't replicate the patterns.

- **Token handling** — `Get-AzAccessToken -AsSecureString` returns a `SecureString`, which is what `Invoke-RestMethod -Authentication Bearer -Token` expects. Keep it a `SecureString`; never `ConvertFrom-SecureString` it to plaintext or log it. Go through `Get-PimAccessToken`, never `Get-AzAccessToken` directly, or the call escapes the refresh and the per-audience cache.
- **`[nullable[T]]` parameters are unwrapped by PowerShell** to a plain `T`, so `$Param.Value` silently yields `$null`. Use the parameter directly. This bit both `Format-PimTimeSpan` and `New-PimActiveRole`.
- **`[int]` rounds, it does not truncate.** `[int]5.7` is `6`. Use `[Math]::Floor` for elapsed and remaining time, or the CLI overstates how long privileged access has left to run.
- **A `foreach` assigned to a variable collapses to a scalar** when it yields one item, and `+=` then concatenates instead of appending. Wrap in `@()`. This bit `Show-PimFooter`.
- **`Get-PimProvider` returns hashtables**, so `(Get-PimProvider -Scope Entra)[0]` indexes the hashtable by the key `0` and returns `$null`. Wrap in `@()` first.
- **`Get-AzPimRoleManagementPolicy` references an undefined `$authHeader`** on its `resource` scope branch. That path throws. It predates the provider layer and is not registered as an operation yet.
- **`Get-PimPrincipalId` returns `$null` rather than throwing** when the identity cannot be resolved, so read-only sessions still work. Write paths must check it.
- **API versions have drifted** across four values and are now consolidated in `Get-PimConfig`. The values there are the ones already in production use — treat a bump as its own reviewed change, not a tidy-up.
- **No tests and no LICENSE file** yet. CI has no build or lint step — only publish. `PSScriptAnalyzerSettings.psd1` exists; run it locally:

  ```powershell
  Invoke-ScriptAnalyzer -Path $PWD -Recurse -Settings ./PSScriptAnalyzerSettings.psd1
  ```

  Pass `$PWD` rather than `.` — a relative directory path makes the analyzer throw a null reference before it reports anything.

  The current baseline is two `PSAvoidUsingWriteHost` findings in `New-OfflineImport.ps1`, a dev-only helper. Module code is clean.

Fixed in the Entra groundwork rework, kept here because the patterns are worth not repeating: the activation request that reported success without calling the API; `(Get-Date).AddHours($n).Hour()` calling a property as a method; `POST`ing self-activation to `roleEligibilityScheduleRequests` instead of `roleAssignmentScheduleRequests`; `principalId` set to a UPN instead of an object ID; `String.Trim` used to strip a substring when it takes a character set; the decision function returning `$true` from `end{}` regardless of outcome; `Disconnect-AzPim` tearing down the whole Az session; and the wildcard `Get-AzRoleAssignment` "PIM access" guess.

## Dependencies

Dependencies are declared in `RequiredModules` in `pimcli.psd1` as hashtables with a minimum version:

```powershell
RequiredModules = @(
    @{ ModuleName = 'Az.Accounts'; ModuleVersion = '3.0.0' }
    @{ ModuleName = 'Az.Resources'; ModuleVersion = '7.1.0' }
)
```

`ModuleVersion` means *minimum*, not exact. These become NuGet dependencies in the published package, so `Install-Module pimcli` (or `Install-PSResource pimcli`) pulls Az.Accounts and Az.Resources automatically. Az itself is not vendored into the repo — it is far too large, ships platform-specific native assemblies, and is signed by Microsoft.

Why these floors:

- **Az.Accounts 3.0.0** — `Get-AzAccessToken -AsSecureString` is the token path this module depends on. It first appeared in Az.Accounts 2.17.0, but 3.0.0 is the clean major where the SecureString return became the recommended path, and it is the version paired in the Az 12.0.0 rollup.
- **Az.Resources 7.1.0** — the matching Az.Resources from that same Az 12.0.0 rollup, so the two floors are a combination Microsoft actually ships together.

When adding a dependency, or raising a floor because a newer cmdlet or parameter is needed, note the specific cmdlet/parameter that forced the bump.

Verify a manifest change resolves correctly:

```powershell
Test-ModuleManifest ./pimcli.psd1
```

## Decisions made

- **Entra ID ships in the same surface**, merged into the existing screens rather than as a separate menu branch or separate cmdlets. Navigation is action-first and provider is a filter. Settled when the groundwork landed.

## Open decisions

- **Interactive-only vs. scriptable.** The module currently exports only the interactive `Start-PimCli`. Publishing to the Gallery generally implies also exporting non-interactive cmdlets that can be scripted. The provider functions (`Get-AzPimEligibleRole` and friends) are already shaped like the cmdlets this would export — they take plain parameters and emit objects — so the decision is which names become public, not a rewrite.
- **Graph permissions.** Reading Entra PIM through an Az-issued Graph token depends on what the Az client application is consented for in the tenant. Worth confirming against a real tenant before building out the Entra reads, since it may constrain the approach.
