# Fas 5: PKI

Mål: bygga en tvånivå-PKI med AD CS, autoenrollment via GPO och övervakning av certifikat. Certifikaten används sedan för TLS, SAML-signering och, valfritt, certifikatbaserad inloggning (fas 3 och 4).

## 5.1 Arkitektur

| Server | Roll | Domän | Anmärkning |
|---|---|---|---|
| ROOT-CA | Offline Root CA (standalone) | Nej, arbetsgrupp | Slås på bara vid signering och CRL-förnyelse. Stängs av och säkerhetskopieras. |
| ISSUING-CA01 | Enterprise Issuing CA (subordinate) | Ja | Utfärdar certifikat från mallar, integrerad med AD. |
| PKI-WEB (kan vara samma server i labben) | CDP/AIA över HTTP | Ja | Publicerar CA-certifikat och CRL på `http://pki.labb.local/pki/`. |

**Designval att motivera:**

- Varför två nivåer: rotens privata nyckel hålls offline.
- Varför HTTP och inte bara LDAP för CRL: klienter utanför domänen och molnintegration (t.ex. Entra CBA).
- Varför roten får lång giltighet (20 år) medan utfärdande CA får kortare (5 år).

## 5.2 Offline Root CA

Kör [`scripts/fas5/01-Install-RootCA.ps1`](../scripts/fas5/01-Install-RootCA.ps1) på ROOT-CA. Skriptet skapar `CAPolicy.inf`, installerar rollen, konfigurerar publiceringsvägar och skapar första CRL:en.

Därefter:

1. Kopiera `LabbRootCA.crt` och `LabbRootCA.crl` från `C:\Windows\System32\CertSrv\CertEnroll` till PKI-webben.
2. Publicera roten i AD från en domänansluten dator:

   ```powershell
   certutil -dspublish -f LabbRootCA.crt RootCA
   certutil -addstore -f root LabbRootCA.crt
   ```

## 5.3 Enterprise Issuing CA

1. [`02-Install-IssuingCA.ps1`](../scripts/fas5/02-Install-IssuingCA.ps1) på ISSUING-CA01: installerar rollen och skapar certifikatbegäran. Installera inte Web Enrollment om det inte behövs (risk för ESC8, NTLM relay mot certifikattjänsten).
2. [`03-Sign-IssuingCARequest.ps1`](../scripts/fas5/03-Sign-IssuingCARequest.ps1) på ROOT-CA: signerar begäran.
3. [`04-Complete-IssuingCA.ps1`](../scripts/fas5/04-Complete-IssuingCA.ps1) på ISSUING-CA01: installerar certifikatet, sätter giltighet och CRL-perioder.
4. Kontrollera hälsan i `pkiview.msc`. Alla kontroller ska vara OK. Spara en skärmdump.

## 5.4 Certifikatmallar

Duplicera standardmallar i stället för att ändra originalen.

| Mall (namn) | Baserad på | Användning | Viktiga inställningar |
|---|---|---|---|
| LabbWorkstation | Workstation Authentication | Klientcertifikat för 802.1X, Wi-Fi, VPN | Namn hämtas från AD. RSA 2048. Giltighet 1 år. Read + Enroll + Autoenroll för Domain Computers. |
| LabbWebServer | Web Server | TLS för interna webbappar | Endast Server Authentication, ta bort Client Authentication. Enroll begränsad till `grp-pki-webadmins`. Giltighet 1 år. |
| LabbUser | User | Signering och kryptering, ev. certifikatbaserad inloggning | Namn från AD (UPN). Autoenroll för Domain Users. Giltighet 1 år. |

**Säkerhetsregler för mallar**

- Tillåt aldrig "Supply in the request" på en mall med Client Authentication, annars uppstår angreppet ESC1 (vem som helst kan begära ett certifikat i en annan användares namn).
- Begränsa enrollment-rättigheter till grupper, inte "Authenticated Users".
- Ge ingen mallrättighet (Write, Full Control) till vanliga användare.
- Publicera bara de mallar som används på CA:n.

## 5.5 Autoenrollment via GPO

1. Skapa GPO `PKI - Autoenrollment` och länka den till OU:erna för förvaltning och skola.
2. Computer Configuration > Policies > Windows Settings > Security Settings > Public Key Policies > **Certificate Services Client - Auto-Enrollment**: Enabled, med kryssrutorna för förnyelse av utgångna certifikat och uppdatering av certifikat.
3. Gör samma inställning under User Configuration.
4. Kör `gpupdate /force` på en testdator och verifiera med `certlm.msc` (dator) och `certmgr.msc` (användare).
5. Verifiera förnyelsen genom att tillfälligt ställa in en mall med kort giltighet och se att certifikatet byts ut.

## 5.6 Certifikatautomatisering och övervakning

| Skript | Syfte |
|---|---|
| [`Request-WebServerCert.ps1`](../scripts/fas5/Request-WebServerCert.ps1) | Begär ett certifikat från `LabbWebServer` utan GUI |
| [`Get-ExpiringCertificates.ps1`](../scripts/fas5/Get-ExpiringCertificates.ps1) | Listar certifikat som går ut inom N dagar. Exitkod 1 vid fynd, så att övervakning kan larma |
| [`Test-CrlFreshness.ps1`](../scripts/fas5/Test-CrlFreshness.ps1) | Kontrollerar att CRL:er är nåbara och inte håller på att gå ut |

Kör skripten som schemalagda uppgifter dagligen och lägg till larm (e-post, Teams-webhook eller Event Log). Använd tröskelvärdena 60, 30 och 14 dagar. Det matchar åtgärden för risk R4 i [riskanalysen](fas7-03-riskanalys.md).

## 5.7 Härdning av PKI

- Rot-CA:n är avstängd och offline. Dess virtuella disk eller nyckel är säkerhetskopierad på två platser. Valfritt: nyckeln i HSM.
- CA-servrar och CA-administratörer ingår i **Tier 0**. Begränsa vem som får logga in och vem som är CA Administrator eller Certificate Manager.
- Aktivera CA-auditering och skicka händelserna till loggplattformen.
- Säkerhetskopiera CA:n med `certutil -backup C:\Backup\CA -p <lösenord>` och testa en återställning.
- Granska konfigurationen med **Locksmith** eller **PingCastle** före och efter åtgärder. Spara rapporterna som bevis på förbättring.
- Kontrollera att CRL förnyas innan den går ut, både för root och utfärdande CA.

## 5.8 Integration med fas 3 och 4

- **TLS:** installera ett `LabbWebServer`-certifikat på testappen och visa att klienter litar på det utan varning.
- **SAML-signering:** använd ett certifikat från den egna PKI:n för SAML-signering i en testapp och dokumentera certifikatbytet utan driftstopp.
- **Certifikatbaserad inloggning (valfritt):** ladda upp rotens och den utfärdande CA:ns publika certifikat som certificate authorities i Entra ID och aktivera Entra CBA som phishing-resistent metod. Kräver att CRL är nåbar från internet, vilket du kan lösa med en publik testserver eller bara beskriva i dokumentationen.

## 5.9 Testplan

| Test | Förväntat resultat |
|---|---|
| `pkiview.msc` | Alla kontroller OK |
| Ny domänansluten dator | Får `LabbWorkstation` automatiskt |
| Användare loggar in | Får `LabbUser` automatiskt |
| Webbapp med `LabbWebServer` | Klient litar på certifikatet |
| Återkalla ett certifikat och publicera CRL | Klienten nekar certifikatet efter CRL-uppdatering |
| Övervakningsskriptet körs mot servrar | Listar certifikat som går ut inom 60 dagar |
| Locksmith före och efter härdning | Färre funna problem i rapporten |
| Återställning av CA från backup | CA startar och utfärdar certifikat |

## Så pratar du om det på intervju

- Rita PKI-arkitekturen och förklara varför roten är offline och vad som händer om en CRL går ut.
- Visa en mall och förklara ESC1, och hur rapporten förbättrades efter härdning.
- Koppla till annonsen: AD CS, PowerShell och certifikatautomatisering är uttryckliga krav.
