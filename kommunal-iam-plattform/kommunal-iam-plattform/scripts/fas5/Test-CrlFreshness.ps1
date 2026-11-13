<#
.SYNOPSIS
  Kontrollerar att CRL:er är nåbara och inte håller på att gå ut.

.DESCRIPTION
  Hämtar varje CRL via HTTP och läser NextUpdate med certutil. En utgången CRL
  stoppar inloggning och TLS, så detta bör köras dagligen. Returnerar exitkod 1
  om någon CRL är nära utgång eller inte kan läsas.
  OBS: certutil-utdata och datumformat beror på Windows-språk. Justera
  tolkningen av NextUpdate om skriptet inte hittar datumet.

.EXAMPLE
  .\Test-CrlFreshness.ps1 -CrlUrl http://pki.labb.local/pki/LabbIssuingCA01.crl,http://pki.labb.local/pki/LabbRootCA.crl
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string[]]$CrlUrl,
  [int]$WarnHours = 48
)

$exitCode = 0

foreach ($url in $CrlUrl) {
  $tmp = Join-Path $env:TEMP ("crl_{0}.crl" -f [guid]::NewGuid())
  try {
    Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing -ErrorAction Stop
    $line = certutil -dump $tmp | Select-String 'NextUpdate' | Select-Object -First 1
    if (-not $line) { throw 'Hittade inte NextUpdate i certutil-utdata.' }

    $text = ($line.Line -replace '^\s*NextUpdate:\s*', '').Trim()
    $next = [datetime]::Parse($text, [System.Globalization.CultureInfo]::CurrentCulture)
    $left = $next - (Get-Date)

    if ($left.TotalHours -lt $WarnHours) {
      Write-Warning ("{0}: går ut {1} (om {2:N0} h)" -f $url, $next, $left.TotalHours)
      $exitCode = 1
    } else {
      Write-Output ("{0}: OK, nästa uppdatering {1}" -f $url, $next)
    }
  } catch {
    Write-Warning "${url}: $_"
    $exitCode = 1
  } finally {
    Remove-Item $tmp -ErrorAction SilentlyContinue
  }
}

exit $exitCode
