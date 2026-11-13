<#
.SYNOPSIS
  Tilldelar en eligible (tidsbegränsad) katalogroll via PIM.

.PARAMETER RoleDefinitionId
  Id för rolldefinitionen (Get-MgRoleManagementDirectoryRoleDefinition).

.PARAMETER PrincipalId
  Objekt-id för användaren eller gruppen som ska få rollen.

.PARAMETER Days
  Hur länge tilldelningen gäller (standard 180 dagar).

.EXAMPLE
  .\New-PimEligibleAssignment.ps1 -RoleDefinitionId <id> -PrincipalId <id> -Days 90
#>
#Requires -Modules Microsoft.Graph.Identity.Governance
[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory)][string]$RoleDefinitionId,
  [Parameter(Mandatory)][string]$PrincipalId,
  [int]$Days = 180
)

Connect-MgGraph -Scopes 'RoleEligibilitySchedule.ReadWrite.Directory' -NoWelcome

$params = @{
  action           = 'adminAssign'
  justification    = 'Labb: eligible tilldelning'
  roleDefinitionId = $RoleDefinitionId
  directoryScopeId = '/'
  principalId      = $PrincipalId
  scheduleInfo     = @{
    startDateTime = (Get-Date).ToUniversalTime()
    expiration    = @{ type = 'afterDuration'; duration = "P${Days}D" }
  }
}

if ($PSCmdlet.ShouldProcess($PrincipalId, "Eligible roll i $Days dagar")) {
  New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params
}
