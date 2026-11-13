# Fas 7, del 3: Riskanalys med koppling till NIS2/cybersäkerhetslagen och GDPR

*Version 0.1, utkast. Juridiska hänvisningar ska verifieras mot aktuell lydelse innan dokumentet används skarpt. Kontrollera även att den aktuella organisationen omfattas av cybersäkerhetslagen och vilken nivå som gäller.*

## 3.1 Avgränsning

Analysen gäller identitets- och åtkomsthantering: Active Directory, Entra ID (förvaltning och skola), MIM, MobilityGuard OneGate, PKI/AD CS samt integrationer mot verksamhetssystem.

## 3.2 Regelverksöversikt

**NIS2 / cybersäkerhetslagen (2025:1506):** verksamheter som omfattas ska vidta lämpliga och proportionella åtgärder för att hantera risker i nät- och informationssystem. Bland åtgärderna finns riskanalys och policy för informationssäkerhet, incidenthantering, kontinuitet, säkerhet i leverantörskedjan, kryptering, åtkomstkontroll och hantering av tillgångar samt användning av MFA och säker kommunikation. Betydande incidenter ska rapporteras i steg: tidig varning inom 24 timmar, incidentanmälan inom 72 timmar och slutrapport inom en månad. Ledningen ansvarar för att åtgärderna godkänns och följs upp.

**GDPR:** relevanta artiklar är art. 5 (principer, inklusive integritet och konfidentialitet), art. 24 och 25 (ansvar, inbyggt dataskydd), art. 28 (personuppgiftsbiträde), art. 30 (register), art. 32 (säkerhet), art. 33 och 34 (personuppgiftsincident, anmälan till IMY inom 72 timmar) och art. 35 (konsekvensbedömning). Skolan behandlar uppgifter om barn och i vissa fall skyddade personuppgifter, vilket höjer kraven.

## 3.3 Bedömningsskala

Sannolikhet (1 till 5) × Konsekvens (1 till 5) = riskvärde. **1–5** låg, **6–12** medel, **13–25** hög.

## 3.4 Riskregister

| ID | Risk | S | K | Värde | Regelverkskoppling | Åtgärd (krav-ID) |
|---|---|---|---|---|---|---|
| R1 | Komprometterat privilegierat konto (domänadmin eller global admin) leder till full kontroll över miljön | 3 | 5 | 15 | NIS2: åtkomstkontroll, MFA. GDPR art. 32 | Tiering, PIM, phishing-resistent MFA för admin (MFA-03, MFA-04, SEC-04) |
| R2 | Konton för personal som slutat eller bytt roll behåller åtkomst | 4 | 4 | 16 | NIS2: åtkomstkontroll. GDPR art. 5, 32 | Automatisk avprovisionering, access reviews (PRV-02, PRV-04, PRV-05) |
| R3 | MIM är en föråldrad produkt och blir en säkerhets- och driftsrisk (stöd upphör, få kompetenta) | 4 | 4 | 16 | NIS2: tillgångshantering, kontinuitet | Migreringsplan till Entra ID Governance eller API-baserad provisionering, med tidsatt färdplan |
| R4 | Utgångna eller felkonfigurerade certifikat orsakar driftstopp i autentisering och federation | 4 | 3 | 12 | NIS2: kryptering, kontinuitet | Certifikatinventering, övervakning med varning 60/30/14 dagar, automatisering (SSO-05, SEC-03) |
| R5 | Leverantör saknar SIEM-export eller har bristfällig loggning, vilket fördröjer upptäckt av incidenter | 3 | 4 | 12 | NIS2: incidenthantering (24/72 h). GDPR art. 33 | LOG-01, LOG-02, krav på tidsfrister för leverantörens incidentmeddelande |
| R6 | Support utanför EU/EES kommer åt personuppgifter från skolan | 3 | 4 | 12 | GDPR art. 28, 44–46 | EXT-04, EXT-05, tillägg i PUB-avtal, EU-baserad support |
| R7 | Single point of failure i federation (MobilityGuard OneGate eller en IdP) stoppar inloggning till verksamhetssystem | 3 | 5 | 15 | NIS2: kontinuitet och krishantering | Redundans, dokumenterad nödinloggning, återställningsövningar (AVL-02, SSO-07) |
| R8 | Legacy-protokoll (NTLM, Kerberos med svaga krypteringar, legacy auth i Entra) utnyttjas | 3 | 4 | 12 | NIS2: säker kommunikation. GDPR art. 32 | Blockera legacy auth, kartlägg och fasa ut NTLM, härda Kerberos (SEC-01) |
| R9 | Leverantör utsätts för en attack i leverantörskedjan (SaaS-leverantör eller underleverantör) | 2 | 5 | 10 | NIS2: säkerhet i leverantörskedjan | Leverantörsgranskning, säkerhetsgranskningar, exitplan (SEC-05, SEC-06, EXT-03) |
| R10 | Omorganisation ger felaktiga behörigheter eller bryter integrationer | 4 | 3 | 12 | GDPR art. 5 (minimering), art. 32 | Process för omorganisation, automatisk behörighetsflytt, attestering efter förändring (PRV-05) |
| R11 | Elevers personuppgifter exponeras via för breda behörigheter i skolans tenant | 3 | 5 | 15 | GDPR art. 5, 25, 32, 35 | DPIA, rollmodell med minsta möjliga behörighet, loggning av åtkomst (PRV-03, PRV-06, LOG-01) |
| R12 | Bristande dokumentation och kunskapsberoende hos en enskild person | 4 | 3 | 12 | NIS2: styrning och kontinuitet | Dokumenterade rutiner, avbytare, kunskapsöverföring |

## 3.5 Prioriterade åtgärder (första 6 månaderna)

1. **R2 och R3:** inventera identitetsflöden och ta fram en migreringsplan från MIM.
2. **R1 och R7:** inför tiering, PIM och phishing-resistent MFA för administratörer, och testa nödinloggning.
3. **R11:** genomför DPIA för skolans identitetsflöden.
4. **R4:** certifikatinventering och övervakning (se [fas 5](fas5-pki.md)).
5. **R5, R6, R9:** lägg in kraven i upphandlingsmallen och använd [leverantörsgranskningen](fas7-02-leverantorsgranskning.md) vid alla nya anskaffningar.

## 3.6 Uppföljning

Riskregistret ses över minst en gång per år och vid större förändringar (omorganisation, ny leverantör, incident). Informationssäkerhetsfunktionen äger registret, IAM-specialisten är ansvarig för identitetsrelaterade risker. Ledningen ska informeras om risker med värde 13 eller högre.
