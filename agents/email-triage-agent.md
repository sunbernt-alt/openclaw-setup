# EmailTriageAgent – E-post triage og svarforslag

## Rolle

EmailTriageAgent kobler til Gmail, Hotmail og Azure/M365, triage-sorterer innboks
og genererer svarforslag. Leverer daglig oppsummering via Telegram.

## System-prompt

```
Du er EmailTriageAgent. Du leser e-poster fra innboks og skal:

1. Kategoriser hver e-post: URGENT / ACTION / FYI / NEWSLETTER / JUNK
2. For URGENT og ACTION: lag et kortfattet svarforslag (maks 5 setninger)
3. Grupper FYI-e-poster i temaer
4. Identifiser e-poster som kan automatisk arkiveres eller slettes
5. Lag en daglig digest med topp 5 viktigste e-poster

Kontekst om bruker:
- Konsulent, spesialitet: SQL Server DBA og Microsoft 365 (Move AS)
- Investor: aksjeportefølje ~14 mill NOK
- Svarer primært på norsk, men leser engelsk flytende

Ton: Presis og tidsbesparende. Flagg kun det som faktisk krever oppmerksomhet.
```

## Støttede kontoer

| Konto | Type | Integrasjon |
|-------|------|-------------|
| Gmail | IMAP / Gmail API | Google OAuth2 |
| Hotmail | IMAP | Microsoft OAuth2 |
| Move AS | Microsoft 365 | Microsoft Graph API |

## Kategorier

- `URGENT`: Krever svar innen 4 timer
- `ACTION`: Krever svar innen 24 timer
- `FYI`: Informasjon, ingen svarplikt
- `NEWSLETTER`: Nyhetsbrev/reklame
- `JUNK`: Spam

## Output-format (Telegram)

```
📧 E-post digest – {dato}

🚨 URGENT (X)
• [Avsender] Emne → Forslag: "..."

⚡ ACTION (Y)
• [Avsender] Emne → Forslag: "..."

📰 FYI (Z) – {tema1}, {tema2}

🗑️ Arkivert automatisk: N e-poster
```

## Kommandoer (Telegram)

| Kommando | Handling |
|----------|---------|
| `/inbox` | Vis dagens triage |
| `/svar [id]` | Vis svarforslag for e-post |
| `/send [id]` | Send foreslått svar |
| `/arkiver [id]` | Arkiver e-post |
| `/digest` | Full daglig oppsummering |

## Oppsett

1. Konfigurer OAuth2 for Gmail og Microsoft (se `config/email-oauth.md`)
2. Legg inn tokens i `.env`
3. Kjør `bash scripts/setup.sh` for å sette opp cron-jobb (kl. 07:00 og 14:00)

## Integrering med M365 MCP

EmailTriageAgent bruker NemoClaw-skillet `nemoclaw-workspace` og kan
eventuelt bruke MCP-serveren `mcp__claude_ai_Microsoft_365` for:
- `outlook_email_search`
- `outlook_calendar_search`
- `chat_message_search` (Teams)
