# Fas 7, del 2: Leverantörsgranskning

**Användning:** fyll i checklistan under leverantörsdialog och inför produktionssättning. Skala per punkt: **2** = uppfyller fullt, **1** = uppfyller delvis (kräver åtgärd), **0** = uppfyller inte, **N/A** = ej tillämpligt. En tom mall finns i [`templates/leverantorsbedomning.md`](../templates/leverantorsbedomning.md).

## 2.1 Identitet och åtkomst

- Stöd för SAML 2.0 eller OIDC verifierat i testmiljö
- SCIM eller API för provisionering verifierat, inklusive avprovisionering
- MFA hanteras via kommunens IdP, inte lokalt
- Minst-privilegiumroller finns och är dokumenterade
- Break-glass-konton är beskrivna och loggas

## 2.2 Säkerhet

- Säkerhetscertifiering eller oberoende granskning finns (ISO 27001, SOC 2 eller liknande)
- Penetrationstest genomfört under senaste 12 månaderna
- Sårbarhetshantering och patchtider dokumenterade
- TLS 1.2+ och kryptering i vila bekräftat
- Incidentrutin finns, inklusive tidsfrister för att meddela kommunen

## 2.3 Dataskydd och juridik

- Personuppgiftsbiträdesavtal (PUB-avtal) finns och är granskat
- Lista över underbiträden och platser för databehandling
- Överföring till tredje land är bedömd (inklusive supportåtkomst)
- Rutiner för registerutdrag och radering finns
- Konsekvensbedömning (DPIA) har gjorts eller stöd för den erbjuds

## 2.4 Drift och kontinuitet

- SLA med mätbara nivåer och ersättning vid avvikelse
- RTO/RPO dokumenterade och testade
- Backup- och återställningsrutin testad
- Supportnivåer, öppettider och eskalering beskrivna

## 2.5 Förvaltning och exit

- API-versionering och aviseringstid vid ändringar
- Exitplan och dataexport verifierade
- Raderingsintyg ingår i avtalet
- Leverantörens beroende av underleverantörer bedömt (koncentrationsrisk)

## 2.6 Beslutsmall

| Poäng | Beslut |
|---|---|
| Alla Ska-krav uppfyllda (2) | Godkänd |
| Enstaka punkter med 1 | Godkänd med åtgärdsplan och tidsgräns |
| Någon Ska-punkt med 0 | Ej godkänd, eller dispens från informationssäkerhetsfunktionen |

---

## Exempel: bedömd leverantör (fiktiv)

**Leverantör:** Exempel Skolsystem AB (fiktiv)
**System:** webbaserat administrationssystem för elevärenden i skolan (SaaS)
**Bedömare:** IAM-specialist, tillsammans med informationssäkerhet och upphandling
**Datum:** 2026-11-13

| Område | Poäng | Kommentar |
|---|---|---|
| SSO (SAML/OIDC) | 2 | OIDC med PKCE fungerar mot Entra ID i testmiljön. |
| MFA via IdP | 2 | Conditional Access-beslut respekteras, MFA-claim valideras. |
| Provisionering | 1 | SCIM stöds för användare men inte för grupper. Avprovisionering kräver manuell körning. **Åtgärd:** leverantören levererar gruppstöd i nästa version, senast Q2 2027. |
| Loggning | 1 | Loggar kan hämtas via API men saknar export till SIEM i realtid. **Åtgärd:** kommunen bygger en schemalagd hämtning under övergångsperioden. |
| Kryptering | 2 | TLS 1.2+ och kryptering i vila redovisade. |
| Säkerhetsgranskning | 2 | ISO 27001-certifikat och penetrationstest från de senaste 12 månaderna. |
| PUB-avtal och underbiträden | 1 | Support utanför EU/EES har åtkomst vid felsökning. **Åtgärd:** kräv EU-baserad support eller kompletterande skyddsåtgärder. |
| Tillgänglighet och SLA | 2 | 99,7 % per månad, RTO 4 h, RPO 1 h. |
| Exit | 2 | Export i JSON och CSV utan kostnad, raderingsintyg inom 30 dagar. |
| WCAG | 1 | Delvis uppfyllt, tillgänglighetsredogörelse har brister. **Åtgärd:** handlingsplan krävs. |

**Slutsats:** godkänd med åtgärdsplan. Inga Ska-krav har poängen 0, men fyra punkter med 1 kräver åtgärder med tidsgräns. Produktionssättning får ske efter att supportåtkomsten har lösts (tredjeland) och SIEM-hämtningen är på plats.

**Kvarstående risker:** se [riskregistret](fas7-03-riskanalys.md), risk R5 och R6.
