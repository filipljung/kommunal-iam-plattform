<#
.SYNOPSIS
  Skapar Conditional Access-policyn "CA003 - Blockera legacy authentication".

.DESCRIPTION
  Policyn skapas som standard i report-only-läge. Granska utfallet (se
  queries/ca-report-only-impact.kql) innan du sätter -State enabled.
  Break-glass-gruppen undantas.

.PARAMETER BreakGlassGroupId
  Objekt-id för gruppen med break-glass-konton.

.PARAMETER State
  enabledForReportingButNotEnforced (standard), enabled eller disabled.

.EXAMPLE
  .\New-CAPolicyBlockLegacy.ps1 -BreakGlassGroupId 00000000-0000-0000-0000-000000000000
#>
#Requires -Modules Microsoft.Graph.Identity.SignIns
[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory)][string]$BreakGlassGroupId,
  [ValidateSet('enabledForReportingButNotEnforced', 'enabled', 'disabled')]
  [string]$State = 'enabledForReportingButNotEnforced'
)

Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess', 'Policy.Read.All' -NoWelcome

$params = @{
  displayName = 'CA003 - Blockera legacy authentication - Alla'
  state       = $State
  conditions  = @{
    clientAppTypes = @('exchangeActiveSync', 'other')
    applications   = @{ includeApplications = @('All') }
    users          = @{
      includeUsers  = @('All')
      excludeGroups = @($BreakGlassGroupId)
    }
  }
  grantControls = @{
    operator        = 'OR'
    builtInControls = @('block')
  }
}

if ($PSCmdlet.ShouldProcess('Conditional Access', "Skapa policy ($State)")) {
  New-MgIdentityConditionalAccessPolicy -BodyParameter $params
}
