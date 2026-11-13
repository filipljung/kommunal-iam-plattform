<#
.SYNOPSIS
  Begär ett certifikat från mallen LabbWebServer utan GUI.

.EXAMPLE
  .\Request-WebServerCert.ps1 -DnsName app01.labb.local
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$DnsName,
  [string]$Template = 'LabbWebServer'
)

Get-Certificate -Template $Template `
  -DnsName $DnsName `
  -SubjectName "CN=$DnsName" `
  -CertStoreLocation Cert:\LocalMachine\My
