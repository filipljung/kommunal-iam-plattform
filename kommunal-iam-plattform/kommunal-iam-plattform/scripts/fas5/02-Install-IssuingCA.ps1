<#
.SYNOPSIS
  Steg 1 för utfärdande CA: installerar rollen och skapar certifikatbegäran.

.DESCRIPTION
  Kör på ISSUING-CA01 (domänansluten) som Enterprise Admin. Installera inte
  Web Enrollment om det inte behövs (risk för ESC8, NTLM relay).
  Kopiera begäran (.req) till rot-CA:n och kör 03-Sign-IssuingCARequest.ps1.

.EXAMPLE
  .\02-Install-IssuingCA.ps1
#>
#Requires -RunAsAdministrator
[CmdletBinding()]
param(
  [string]$CaName = 'LabbIssuingCA01',
  [string]$RequestFile = 'C:\Temp\IssuingCA01.req'
)
$ErrorActionPreference = 'Stop'

New-Item -ItemType Directory -Path (Split-Path $RequestFile) -Force | Out-Null

Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools | Out-Null

Install-AdcsCertificationAuthority -CAType EnterpriseSubordinateCA `
  -CACommonName $CaName `
  -KeyLength 2048 -HashAlgorithmName SHA256 `
  -CryptoProviderName 'RSA#Microsoft Software Key Storage Provider' `
  -OutputCertRequestFile $RequestFile

Write-Output "Begäran skapad: $RequestFile"
Write-Output 'Nästa steg: kopiera filen till ROOT-CA och kör 03-Sign-IssuingCARequest.ps1.'
