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
pimcli.psd1              Module manifest (version, exports, dependencies)
pimcli.psm1              Root module — dot-sources private/ then public/, exports public functions
public/                  Exported functions (one function per file, file named after the function)
private/                 Internal helpers (not exported)
New-OfflineImport.ps1    Dev helper: imports the module from source for local testing
Publish-PimCli.ps1       Publishes to the PowerShell Gallery using $env:NUGET_API_KEY
.github/workflows/       CI: publish.yaml runs Publish-PimCli.ps1 on a `v*` tag push
.devcontainer/           Ubuntu devcontainer with pwsh, Az, Microsoft.Graph modules
```

### Conventions

- **One function per file.** File name matches the function name exactly.
- New **exported** function: add the file to `public/`, then add the name to `FunctionsToExport` in `pimcli.psd1` **and** to the `$publicFunctions` array in `pimcli.psm1`. Both lists are maintained by hand and must stay in sync.
- New **internal** function: add the file to `private/` only. No manifest change.
- Naming: `*-AzPim*` for Azure/ARM resource PIM, and use `*-EntraPim*` for Entra ID directory-role PIM as that surface is built out.
- Approved PowerShell verbs only (`Get-`, `New-`, `Invoke-`, `Show-`, `Connect-`, `Disconnect-`, `Start-`).

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

Delete branches after merge. `origin/feature/roleActivation` currently carries 7 unmerged commits adding role activation and eligibility retrieval — that work is not on `main`, so check it before rebuilding anything in that area.

## Publishing

Publishing is tag-driven: pushing a `v*` tag triggers `.github/workflows/publish.yaml`, which runs `Publish-PimCli.ps1` with the `POWERSHELL_GALLERY_API_KEY` secret. Bump `ModuleVersion` in `pimcli.psd1` before tagging — the Gallery rejects a re-publish of an existing version.

Release flow: cut a `release/x.y.z` branch, bump `ModuleVersion` (and `ReleaseNotes` in `PrivateData.PSData`), merge to `main`, then tag that merge commit `vx.y.z` and push the tag. Tag `main` only — the workflow publishes whatever the tag points at, so a tag on an unmerged branch would ship unreviewed code. There are no tags in the repo yet; nothing has been published.

## Current state

Implemented today (Azure resource PIM only):

- `Start-PimCli` — entry point, auth + main menu loop.
- `Connect-AzPim` / `Disconnect-AzPim` — wrap `Connect-AzAccount` / `Disconnect-AzAccount`, plus a heuristic PIM-access check.
- `Get-AzPimRequest` — `GET roleAssignmentScheduleRequests?$filter=asApprover()` (api-version `2022-04-01-preview`).
- `Invoke-PimRequestApproval` — interactive list, detail view, approve/deny flow.
- `New-AzPimDecisionRequest` — reads approval `stages`, then `PUT`s the decision (api-version `2021-01-01-preview`).
- `Show-Banner`, `Show-MainMenu`, `Show-AzPimRequestDetail` — console UI.

Main menu options 2 (request activation) and 3 (view active roles) are stubs. Nothing for Entra ID roles exists yet.

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

- **`pimcli.psm1` uses backslash path separators** (`"$PSScriptRoot\private\*.ps1"`). On Linux and macOS a backslash is a literal filename character, so function loading silently finds nothing and the module exports broken stubs. Use `Join-Path` or forward slashes.
- **`.Trim('providers/Microsoft.Authorization/roleAssignmentApprovals/')` in `Invoke-PimRequestApproval`** — `String.Trim` takes a *character set*, not a substring, so this strips arbitrary leading/trailing characters from the GUID. Use `-replace` or `Split('/')[-1]`.
- **Token handling** — `Get-AzAccessToken -AsSecureString` returns a `SecureString`, which is what `Invoke-RestMethod -Authentication Bearer -Token` expects. Keep it a `SecureString`; never `ConvertFrom-SecureString` it to plaintext or log it.
- **Tokens are fetched per call and never refreshed** across a long-running session. Long menu sessions can outlive the token.
- **`Connect-AzPim`'s PIM check** is a wildcard match over `Get-AzRoleAssignment` names (`*Administrator*`, `*Owner*`, …). It is a guess, not an authorization check, and it only ever produces a warning.
- **`New-AzPimDecisionRequest` writes raw API responses to the host** and always returns `$true` from `end{}` even after a caught failure — the caller's success check is meaningless.
- **`Disconnect-AzPim` calls `Disconnect-AzAccount`**, which tears down the user's whole Az session, not just this module's.
- **Preview API versions** are pinned inline in each function. Prefer a single shared constant when adding more calls.
- **No tests, no PSScriptAnalyzer config, no LICENSE file** yet. There is no build or lint step in CI — only publish.

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

## Open decisions

- **Entra ID scope.** Whether Entra ID role PIM ships in the same module surface (`Start-PimCli` menu) or as separate top-level cmdlets.
- **Interactive-only vs. scriptable.** The module currently exports only the interactive `Start-PimCli`. Publishing to the Gallery generally implies also exporting non-interactive cmdlets that can be scripted.
