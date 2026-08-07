# pimcli

Simple CLI for managing Privileged Identity Management (PIM) from the terminal, covering both **Azure resource roles** and **Entra ID directory roles**. Since it is an experimental project, it is not recommended for production use.

## Installation

In the PowerShell terminal, run the following command to import the module:

```powershell
./New-OfflineImport.ps1
```

## Usage

From the PowerShell terminal, run the following command to start the CLI:

```powershell
Start-PimCli
```

The menu is organised by what you want to do, not by which surface the role lives on. Azure resource roles and Entra ID directory roles appear in the same list with a `Source` column, so there is one place to look:

```
  Activate a role                    Scope: All surfaces

  #  Role                     Scope      Type           Via     Source
  1  Key Vault Administrator  rg-shared  resourcegroup  Group   Azure
  2  Owner                    sub-prod   subscription   Direct  Azure
  3  Global Reader            Directory  Directory      Direct  Entra

  [s] change scope   [b] back   [r] refresh   [q] quit
```

To work with one surface only, narrow the scope with `s`, or start the CLI already filtered:

```powershell
Start-PimCli -Scope Azure
```

Narrowing the scope also means the other surface is never queried.

### Keys

The same keys work on every screen:

| Key | Action |
|---|---|
| number | select the numbered item |
| `b` | back |
| `r` | refresh the current list |
| `s` | change the scope filter |
| `q` | quit |

## Status

Entra ID support is scaffolded but not yet wired to the API. Where an operation is not implemented, the CLI says so on the screen rather than showing an empty list — an empty result always means "nothing found", never "not built yet".

| | Azure resources | Entra ID |
|---|---|---|
| Eligible roles | yes | not yet |
| Approvals (list and decide) | yes | not yet |
| Active roles | not yet | not yet |
| Activate / deactivate | not yet | not yet |

## Requirements

- PowerShell 7.0 or later
- `Az.Accounts` 3.0.0 or later, `Az.Resources` 7.1.0 or later

Authentication uses your existing Az sign-in. Quitting the CLI ends the pimcli session only and leaves that sign-in in place.
