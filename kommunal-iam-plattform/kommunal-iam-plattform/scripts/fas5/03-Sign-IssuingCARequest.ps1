<#
.SYNOPSIS
  Steg 2: signerar den utfärdande CA:ns begäran på rot-CA:n.

.DESCRIPTION
  Kör på ROOT-CA som lokal administratör. Skriptet skickar in begäran, utfärdar
  certifikatet och hämtar det som .crt. Kopiera sedan .crt och rotens .crt/.crl
  till ISSUING-CA01 samt PKI-webben.

.EXAMPLE
  .\03-Sign-IssuingCARequest.ps1 -RequestFile C:\Temp\IssuingCA01.req
#>
#Requires -RunAsAdministrator
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$RequestFile,
  [string]$RootCaConfig = "$env:COMPUTERNAME\LabbRootCA",
  [string]$OutFile = 'C:\Temp\IssuingCA01.crt'
)
$ErrorActionPreference = 'Stop'

$submit = certreq -submit -config $RootCaConfig $RequestFile
$line = $submit | Select-String 'RequestId:\s*(\d+)'
if (-not $line) { throw "Kunde inte läsa RequestId. Utdata: $submit" }
$requestId = $line.Matches[0].Groups[1].Value

certutil -config $RootCaConfig -resubmit $requestId
certreq -config $RootCaConfig -retrieve $requestId $OutFile

Write-Output "Certifikat utfärdat: $OutFile (RequestId $requestId)"
