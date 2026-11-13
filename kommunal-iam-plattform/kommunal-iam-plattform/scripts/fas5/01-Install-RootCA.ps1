<#
.SYNOPSIS
  Installerar och konfigurerar en offline Root CA (standalone).

.DESCRIPTION
  Kör på ROOT-CA (arbetsgrupp, ej domänansluten) som lokal administratör.
  Skriptet skapar CAPolicy.inf, installerar rollen AD CS, konfigurerar
  publiceringsvägar och skapar första CRL:en.

.PARAMETER CaName
  Common name för rot-CA:n.

.PARAMETER ConfigDN
  Konfigurationskontextens DN, t.ex. 'CN=Configuration,DC=labb,DC=local'.

.PARAMETER PkiUrl
  Bas-URL (HTTP) där CA-certifikat och CRL publiceras.

.EXAMPLE
  .\01-Install-RootCA.ps1 -ConfigDN 'CN=Configuration,DC=labb,DC=local'
#>
#Requires -RunAsAdministrator
[CmdletBinding()]
param(
  [string]$CaName = 'LabbRootCA',
  [Parameter(Mandatory)][string]$ConfigDN,
  [string]$PkiUrl = 'http://pki.labb.local/pki'
)
$ErrorActionPreference = 'Stop'

$capolicy = @'
[Version]
Signature="$Windows NT$"

[Certsrv_Server]
RenewalKeyLength=4096
RenewalValidityPeriod=Years
RenewalValidityPeriodUnits=20
CRLPeriod=Weeks
CRLPeriodUnits=26
'@
Set-Content -Path "$env:SystemRoot\CAPolicy.inf" -Value $capolicy -Encoding ASCII

Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools | Out-Null

Install-AdcsCertificationAuthority -CAType StandaloneRootCa `
  -CACommonName $CaName `
  -KeyLength 4096 -HashAlgorithmName SHA256 `
  -CryptoProviderName 'RSA#Microsoft Software Key Storage Provider' `
  -ValidityPeriod Years -ValidityPeriodUnits 20 -Force

$certEnroll = "$env:SystemRoot\System32\CertSrv\CertEnroll"

certutil -setreg CA\DSConfigDN $ConfigDN
certutil -setreg CA\ValidityPeriod 'Years'
certutil -setreg CA\ValidityPeriodUnits 5          # längsta giltighet för utfärdande CA
certutil -setreg CA\CRLPeriod 'Weeks'
certutil -setreg CA\CRLPeriodUnits 26
certutil -setreg CA\CRLOverlapPeriod 'Weeks'
certutil -setreg CA\CRLOverlapUnits 2
certutil -setreg CA\CACertPublicationURLs "1:${certEnroll}\%3%4.crt\n2:${PkiUrl}/%3%4.crt"
certutil -setreg CA\CRLPublicationURLs "1:${certEnroll}\%3%8.crl\n2:${PkiUrl}/%3%8.crl"

Restart-Service certsvc
Start-Sleep -Seconds 5
certutil -crl

Write-Output "Klart. Kopiera ${CaName}.crt och ${CaName}.crl från $certEnroll till PKI-webben."
Write-Output "Publicera roten i AD från en domänansluten dator:"
Write-Output "  certutil -dspublish -f ${CaName}.crt RootCA"
Write-Output "  certutil -addstore -f root ${CaName}.crt"
