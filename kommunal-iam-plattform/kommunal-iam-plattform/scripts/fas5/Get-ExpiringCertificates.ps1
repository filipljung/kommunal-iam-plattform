<#
.SYNOPSIS
  Hittar certifikat som går ut inom ett visst antal dagar på en eller flera servrar.

.DESCRIPTION
  Skriver en CSV och returnerar exitkod 1 om certifikat hittas, så att en
  schemalagd uppgift eller övervakning kan larma. Rekommenderade
  tröskelvärden: 60, 30 och 14 dagar.

.EXAMPLE
  .\Get-ExpiringCertificates.ps1 -Computers SRV01,SRV02 -WarnDays 60
#>
[CmdletBinding()]
param(
  [string[]]$Computers = @($env:COMPUTERNAME),
  [int]$WarnDays = 60,
  [string]$OutFile = '.\expiring-certs.csv'
)

$limit = (Get-Date).AddDays($WarnDays)

$found = foreach ($c in $Computers) {
  try {
    Invoke-Command -ComputerName $c -ErrorAction Stop -ArgumentList $limit -ScriptBlock {
      param($limit)
      Get-ChildItem Cert:\LocalMachine\My |
        Where-Object { $_.NotAfter -lt $limit } |
        Select-Object @{n = 'Computer'; e = { $env:COMPUTERNAME }}, Subject, Thumbprint, NotAfter,
          @{n = 'DaysLeft'; e = { [int]($_.NotAfter - (Get-Date)).TotalDays }}
    }
  } catch {
    Write-Warning "Kunde inte läsa ${c}: $_"
  }
}

if ($found) {
  $found | Sort-Object NotAfter | Export-Csv $OutFile -NoTypeInformation -Encoding UTF8
  $found | Format-Table -AutoSize
  exit 1
} else {
  Write-Output "Inga certifikat går ut inom $WarnDays dagar."
}
