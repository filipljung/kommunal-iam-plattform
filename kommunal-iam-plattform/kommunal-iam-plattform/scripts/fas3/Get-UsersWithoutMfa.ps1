<#
.SYNOPSIS
  Rapporterar användare som saknar registrerad MFA-metod.

.DESCRIPTION
  Använder registreringsdetaljer från Microsoft Graph och exporterar en CSV.
  Skriver även en sammanfattning. Administratörer utan MFA flaggas separat.

.EXAMPLE
  .\Get-UsersWithoutMfa.ps1 -OutFile .\users-without-mfa.csv
#>
#Requires -Modules Microsoft.Graph.Reports
[CmdletBinding()]
param(
  [string]$OutFile = '.\users-without-mfa.csv'
)

Connect-MgGraph -Scopes 'AuditLog.Read.All', 'User.Read.All' -NoWelcome

$details = Get-MgReportAuthenticationMethodUserRegistrationDetail -All
$noMfa   = @($details | Where-Object { -not $_.IsMfaRegistered })

$noMfa |
  Select-Object UserPrincipalName, UserType, IsAdmin, DefaultMfaMethod |
  Export-Csv -Path $OutFile -NoTypeInformation -Encoding UTF8

$adminsWithout = @($noMfa | Where-Object { $_.IsAdmin }).Count

Write-Output ("MFA saknas för {0} av {1} användare." -f $noMfa.Count, @($details).Count)
if ($adminsWithout -gt 0) {
  Write-Warning "$adminsWithout administratörer saknar MFA. Åtgärda omedelbart."
}
Write-Output "Rapport sparad: $OutFile"
