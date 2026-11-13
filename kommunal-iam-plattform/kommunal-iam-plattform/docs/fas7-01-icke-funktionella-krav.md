# Fas 7, del 1: Icke-funktionella IAM-krav

**Syfte:** återanvändbar kravkatalog som kan klippas in i kravspecifikationer vid anskaffning av nya eller väsentligt förändrade IT-system.

**Kravnivåer:** **Ska** = obligatoriskt (utesluter leverantören om det inte uppfylls). **Bör** = meriterande (poängsätts).

**Verifiering:** D = dokumentation, T = test/demo i testmiljö, R = referens.

*Version 0.1, utkast. Nivåer som anges (t.ex. tillgänglighet och loggretention) är exempel och ska fastställas av verksamhet och informationssäkerhet.*

## 1.1 Autentisering och SSO

| ID | Krav | Nivå | Verif. |
|---|---|---|---|
| SSO-01 | Systemet ska stödja federerad inloggning via SAML 2.0 eller OpenID Connect mot kommunens identitetsleverantör (Entra ID och/eller MobilityGuard OneGate). | Ska | T |
| SSO-02 | Systemet ska inte kräva lokal lagring av lösenord för personal- eller elevkonton när SSO är aktiverat. | Ska | D |
| SSO-03 | Systemet ska stödja Single Logout eller motsvarande sessionsavslut. | Bör | T |
| SSO-04 | Signerade SAML-assertions och validering av tokens (signatur, audience, utgångstid) ska vara standard. | Ska | D/T |
| SSO-05 | Certifikat för SAML-signering ska kunna bytas utan driftavbrott, med metadata som kan uppdateras automatiskt. | Bör | T |
| SSO-06 | Systemet ska stödja OAuth 2.0 med Authorization Code Flow och PKCE för publika klienter. Implicit flow ska inte användas. | Ska | D |
| SSO-07 | Lokala nödinloggningar (break-glass) ska vara dokumenterade, begränsade till ett fåtal konton och loggas. | Ska | D |

## 1.2 Multifaktorautentisering (MFA)

| ID | Krav | Nivå | Verif. |
|---|---|---|---|
| MFA-01 | MFA ska kunna komma från kommunens identitetsleverantör, så att systemet inte behöver en egen MFA-lösning. | Ska | T |
| MFA-02 | Systemet ska respektera Conditional Access-beslut och acceptera MFA-claims (t.ex. amr/acr) från identitetsleverantören. | Ska | T |
| MFA-03 | Administratörsinloggning ska alltid kräva MFA, även vid lokal inloggning. | Ska | T |
| MFA-04 | Systemet bör stödja phishing-resistenta metoder (FIDO2/passkeys, certifikatbaserad inloggning). | Bör | D |
| MFA-05 | Stöd för step-up-autentisering vid känsliga åtgärder bör finnas. | Bör | T |

## 1.3 Identitetsförsörjning och behörighetsstyrning

| ID | Krav | Nivå | Verif. |
|---|---|---|---|
| PRV-01 | Systemet ska stödja automatisk provisionering och avprovisionering via SCIM 2.0 eller dokumenterat API. | Ska | T |
| PRV-02 | Avslut av en identitet ska inaktivera åtkomst inom 24 timmar, helst i realtid. | Ska | T |
| PRV-03 | Systemet ska stödja rollbaserad eller gruppbaserad behörighetsstyrning som kan styras utifrån attribut från katalogen. | Ska | D |
| PRV-04 | Det ska gå att ta ut behörighetsrapporter (vem har åtkomst till vad) för access reviews. | Ska | T |
| PRV-05 | Systemet ska hantera omorganisationer, d.v.s. förändrade enhetstillhörigheter, utan manuell omregistrering av användare. | Bör | T |
| PRV-06 | Systemet ska stödja separata administrationsroller (minst privilegium) och dokumentera vilka rättigheter varje roll ger. | Ska | D |
| PRV-07 | Tjänstekonton och API-nycklar ska kunna roteras och ha begränsad giltighet. | Ska | D |

## 1.4 Loggning och spårbarhet

| ID | Krav | Nivå | Verif. |
|---|---|---|---|
| LOG-01 | Inloggningar, misslyckade inloggningar, behörighetsändringar och administrativa åtgärder ska loggas med tidsstämpel och användar-ID. | Ska | T |
| LOG-02 | Loggarna ska kunna exporteras till kommunens SIEM (t.ex. syslog, CEF, API eller Event Hub). | Ska | T |
| LOG-03 | Loggar ska vara skyddade mot ändring och kunna lagras minst 12 månader (nivå fastställs av informationssäkerhetsfunktionen). | Ska | D |
| LOG-04 | Loggarna ska inte innehålla lösenord, tokens eller onödiga personuppgifter. | Ska | D |
| LOG-05 | Tidssynkronisering (NTP) ska användas. | Ska | D |

## 1.5 Informationssäkerhet och kryptering

| ID | Krav | Nivå | Verif. |
|---|---|---|---|
| SEC-01 | All kommunikation ska krypteras med TLS 1.2 eller högre. Svaga chiffer ska vara avstängda. | Ska | T |
| SEC-02 | Data i vila ska krypteras. Leverantören ska beskriva nyckelhantering. | Ska | D |
| SEC-03 | Systemet ska kunna använda certifikat från kommunens PKI (AD CS) eller publik CA, och certifikatbyte ska kunna ske utan driftstopp. | Ska | T |
| SEC-04 | Leverantören ska redovisa hur sårbarheter hanteras (patchtid, CVE-rutin, penetrationstester). | Ska | D |
| SEC-05 | Leverantören ska kunna visa en oberoende säkerhetsgranskning (t.ex. ISO/IEC 27001, SOC 2 eller penetrationstestrapport). | Bör | D |
| SEC-06 | Systemet ska ha en dokumenterad SBOM eller komponentlista för tredjepartsberoenden. | Bör | D |

## 1.6 Tillgänglighet, kontinuitet och drift

| ID | Krav | Nivå | Verif. |
|---|---|---|---|
| AVL-01 | Tillgänglighet ska vara minst 99,5 % per månad för kritiska system (nivå sätts efter verksamhetens konsekvensanalys). | Ska | D |
| AVL-02 | RTO och RPO ska dokumenteras och överensstämma med kommunens krav. | Ska | D |
| AVL-03 | Backup och återställning ska vara testade och beskrivna. | Ska | D |
| AVL-04 | Planerade underhållsfönster ska aviseras i förväg. | Bör | D |
| AVL-05 | Systemet ska uppfylla WCAG 2.1 AA (webbtillgänglighet, enligt DOS-lagen). | Ska | D/T |

## 1.7 Förvaltning och integration

| ID | Krav | Nivå | Verif. |
|---|---|---|---|
| INT-01 | Systemet ska ha ett dokumenterat och versionerat API. | Ska | D |
| INT-02 | Förändringar som påverkar integrationer ska meddelas minst 90 dagar i förväg. | Ska | D |
| INT-03 | Miljöer för test och produktion ska vara separerade. | Ska | D |
| INT-04 | Teknisk dokumentation ska finnas på svenska eller engelska. | Ska | D |

## 1.8 Dataskydd och exit

| ID | Krav | Nivå | Verif. |
|---|---|---|---|
| EXT-01 | All kommunens data ska kunna exporteras i ett öppet, maskinläsbart format utan extra kostnad vid avtalets slut. | Ska | D |
| EXT-02 | Leverantören ska radera all data och intyga raderingen skriftligen inom 30 dagar efter avslutad exit. | Ska | D |
| EXT-03 | Leverantören ska medverka i en exitplan och överföring till ny leverantör under en överenskommen period. | Ska | D |
| EXT-04 | Personuppgifter ska behandlas inom EU/EES, eller med dokumenterad rättslig grund om överföring sker till tredje land. | Ska | D |
| EXT-05 | Underbiträden ska redovisas och godkännas i förväg. | Ska | D |
