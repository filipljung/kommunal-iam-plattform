<#
.SYNOPSIS
  Skapar och verifierar Entra Kerberos-serverobjektet för cloud Kerberos trust.

.DESCRIPTION
  Kör på en server med åtkomst till domänkontrollant, som Domain Admin.
  Kräver modulen AzureADHybridAuthenticationManagement. Följ Microsofts aktuella
  guide för Windows Hello for Business cloud Kerberos trust, eftersom parametrar
  kan ändras mellan versioner.

.EXAMPLE
  .\Set-CloudKerberosTrust.ps1
#>
[CmdletBinding()]
param(
  [string]$Domain = $env:USERDNSDOMAIN
)

if (-not (Get-Module -ListAvailable -Name AzureADHybridAuthenticationManagement)) {
  Install-Module -Name AzureADHybridAuthenticationManagement -AllowClobber -Scope CurrentUser
}

$cloudCred  = Get-Credential -Message 'Entra-konto, t.ex. Hybrid Identity Administrator'
$domainCred = Get-Credential -Message 'Domain Admin i lokal AD'

Set-AzureADKerberosServer -Domain $Domain -CloudCredential $cloudCred -DomainCredential $domainCred
Get-AzureADKerberosServer -Domain $Domain -CloudCredential $cloudCred -DomainCredential $domainCred

Write-Output 'Aktivera sedan Windows Hello for Business med "Use cloud trust for on-premises authentication" via Intune eller GPO.'
Write-Output 'Verifiera på klienten med: klist'
