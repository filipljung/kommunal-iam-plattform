# Fas 3: Autentisering och säker åtkomst

Mål: bygga MFA, Conditional Access, PIM och Kerberos cloud trust i en hybridmiljö (AD + Entra ID), och kunna visa och motivera designvalen.

**Förutsättningar:** domänkontrollant och Entra Cloud Sync (fas 1), Entra-tenant med P2-funktioner, en Windows 11-klient (hybrid- eller Entra-ansluten), två testanvändare och en testadmin.

## 3.1 Break-glass-konton

Skapa två molnbaserade konton (inte synkade från AD) med rollen Global Administrator, till exempel `breakglass1@labb.onmicrosoft.com`.

- Långa slumpmässiga lösenord, förvarade offline (t.ex. kassaskåp). Dokumentera vem som har tillgång.
- Registrera en FIDO2-nyckel eller certifikatbaserad inloggning på kontot. Microsofts krav på MFA för administrationsportaler gör att ett rent lösenordskonto inte längre är en pålitlig nödväg.
- Lägg båda kontona i gruppen `grp-breakglass` och undanta gruppen från Conditional Access (se 3.3), men inte från varningarna.
- Skapa en larmregel som skickar e-post vid inloggning (se [`queries/break-glass-signin.kql`](../queries/break-glass-signin.kql)).
- Testa en inloggning var tredje månad och dokumentera testet.

## 3.2 Autentiseringsmetoder

1. Stäng av Security defaults om de är på (de går inte att kombinera med Conditional Access). Granska också Microsofts egna hanterade CA-policyer så att du inte dubblerar dem.
2. Entra admin center > Protection > Authentication methods > Policies:
   - **Microsoft Authenticator:** på för alla, med number matching.
   - **FIDO2/passkeys:** på för administratörer och en pilotgrupp.
   - **Temporary Access Pass (TAP):** på för en grupp, engångsanvändning, giltighet 1 timme. Används vid första registrering och när någon tappat sin metod.
   - **SMS och röstsamtal:** av, eller endast som reservfall.
3. Aktivera registreringskampanjen (registration campaign) så att användare uppmanas välja Authenticator.
4. Testa flödet: ny användare får TAP, registrerar Authenticator och loggar in med MFA.

## 3.3 Conditional Access

Bygg varje policy i **report-only** först. Granska utfallet (se [`queries/ca-report-only-impact.kql`](../queries/ca-report-only-impact.kql)) och slå sedan på.

| ID | Policy | Målgrupp | Kontroll |
|---|---|---|---|
| CA001 | Admins kräver phishing-resistent MFA | Katalogroller (Global Admin m.fl.) | Authentication strength: Phishing-resistant MFA |
| CA002 | MFA för alla användare | Alla användare, alla appar | Kräv MFA |
| CA003 | Blockera legacy authentication | Alla användare | Blockera (klienttyper Exchange ActiveSync och "other") |
| CA004 | Registrering av säkerhetsinformation | Alla användare, åtgärd "Register security information" | Kräv MFA (TAP uppfyller kravet) |
| CA005 | Riskbaserad åtkomst (P2) | Alla användare | Inloggningsrisk medel eller högre: kräv MFA. Användarrisk hög: kräv lösenordsbyte |
| CA006 | Blockera inloggning utanför Sverige och EU | Alla utom resande-grupp | Blockera (named location, länder) |

Alla policyer utom CA006 undantar `grp-breakglass`. Namnmönster: `CAxxx - Syfte - Målgrupp`.

**Skript:** [`scripts/fas3/New-CAPolicyBlockLegacy.ps1`](../scripts/fas3/New-CAPolicyBlockLegacy.ps1) skapar CA003 i report-only-läge och kan användas som mall för övriga policyer.

**Skolans tenant:** Använd samma grunder men med separata policyer. Personal får MFA. För elever behöver kravet vägas mot praktiken, till exempel MFA utanför skolans nätverk, tydlig supportprocess och att yngre elever kanske inte har egen telefon. Dokumentera avvägningen.

## 3.4 PIM (Privileged Identity Management)

- Gör alla administratörsroller **eligible** i stället för permanenta. Permanent tilldelning får bara break-glass-kontona ha.
- Rolleninställningar för Global Administrator: aktivering högst 4 timmar, kräv MFA vid aktivering, kräv motivering, kräv godkännande från en andra person, notifiering till säkerhetsansvarig.
- Mindre känsliga roller (t.ex. Helpdesk Administrator): MFA och motivering räcker.
- Skapa en **access review** av rolltilldelningar var tredje månad.
- Dokumentera aktiveringen med skärmdumpar: begäran, godkännande, tidsbegränsad åtkomst.

**Skript:** [`scripts/fas3/New-PimEligibleAssignment.ps1`](../scripts/fas3/New-PimEligibleAssignment.ps1)

## 3.5 Kerberos cloud trust (Windows Hello for Business)

Målet är att en användare loggar in med Windows Hello eller FIDO2 och sedan når lokala resurser (filserver, intern webbapp) utan lösenord. Det visar förståelse för bryggan mellan Entra ID och AD.

**Krav:** Windows 10 21H2 eller senare (eller Windows 11), domänkontrollanter med Windows Server 2016 eller senare, synkade användare och ett Entra Kerberos-serverobjekt.

1. Kör [`scripts/fas3/Set-CloudKerberosTrust.ps1`](../scripts/fas3/Set-CloudKerberosTrust.ps1) för att skapa och verifiera serverobjektet.
2. Aktivera Windows Hello for Business via Intune (eller GPO) med inställningen **Use cloud trust for on-premises authentication**.
3. Verifiera med `klist` på klienten: en Kerberos-biljett för en lokal tjänst utan lösenordsinmatning.

*Alternativ eller komplement:* Seamless SSO för äldre klienter. Jämför de två i din dokumentation och förklara varför cloud trust är att föredra.

## 3.6 Uppföljning

- **Användare utan MFA:** [`scripts/fas3/Get-UsersWithoutMfa.ps1`](../scripts/fas3/Get-UsersWithoutMfa.ps1) skapar en CSV och flaggar administratörer utan MFA.
- **KQL** (kräver att inloggningsloggar skickas till Log Analytics): [`legacy-auth.kql`](../queries/legacy-auth.kql), [`break-glass-signin.kql`](../queries/break-glass-signin.kql) och [`ca-report-only-impact.kql`](../queries/ca-report-only-impact.kql).

## 3.7 Testplan

| Test | Förväntat resultat |
|---|---|
| Vanlig användare loggar in från ny enhet | MFA krävs |
| Inloggning med IMAP eller äldre klient | Blockeras (CA003) |
| Administratör loggar in utan FIDO2 | Nekas (CA001) |
| Ny användare registrerar metod med TAP | Lyckas, TAP förbrukas |
| Aktivera Global Administrator i PIM | MFA, motivering och godkännande krävs |
| Break-glass-inloggning | Fungerar och larm skickas |
| Inloggning mot lokal filserver med Windows Hello | Biljett utfärdas utan lösenord |

## Så pratar du om det på intervju

- Varför report-only kommer först, och hur du hanterar break-glass och skolans elever.
- Varför cloud trust är ett bättre val än äldre lösningar i hybridmiljöer.
- Hur MFA-kraven blir icke-funktionella krav vid upphandling (se [fas 7](fas7-01-icke-funktionella-krav.md)).
