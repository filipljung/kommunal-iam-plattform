<#
.SYNOPSIS
  Steg 3: installerar det signerade certifikatet och konfigurerar utfärdande CA.

.DESCRIPTION
  Kör på ISSUING-CA01. Sätter giltighet, CRL-perioder och publiceringsvägar,
  startar tjänsten och skapar första CRL:en.

.EXAMPLE
  .\04-Complete-IssuingCA.ps1 -CertificateFile C:\Temp\IssuingCA01.crt
#>
#Requires -RunAsAdministrator
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$CertificateFile,
  [string]$PkiUrl = 'http://pki.labb.local/pki'
)
$ErrorActionPreference = 'Stop'

certutil -installcert $CertificateFile
Start-Service certsvc

$certEnroll = "$env:SystemRoot\System32\CertSrv\CertEnroll"

certutil -setreg CA\ValidityPeriod 'Years'
certutil -setreg CA\ValidityPeriodUnits 2          # längsta giltighet för utfärdade certifikat
certutil -setreg CA\CRLPeriod 'Weeks'
certutil -setreg CA\CRLPeriodUnits 1
certutil -setreg CA\CRLDeltaPeriod 'Days'
certutil -setreg CA\CRLDeltaPeriodUnits 1
certutil -setreg CA\CACertPublicationURLs "1:${certEnroll}\%3%4.crt\n2:${PkiUrl}/%3%4.crt"
certutil -setreg CA\CRLPublicationURLs "65:${certEnroll}\%3%8%9.crl\n6:${PkiUrl}/%3%8%9.crl"

Restart-Service certsvc
Start-Sleep -Seconds 5
certutil -crl

Write-Output 'Klart. Kontrollera hälsan i pkiview.msc (alla kontroller ska vara OK).'
Write-Output 'Kopiera CA-certifikat och CRL från CertEnroll till PKI-webben.'
