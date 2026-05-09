# Teams-oppsett – Steg-for-steg

To deler: Del 1 tar 2 minutter og gir deg push-varsler med en gang.
Del 2 gir deg to-veis kommandoer og tar ~15 minutter.

---

## Del 1 – Incoming Webhook (varsler, ingen Azure-konto nødvendig)

### 1.1 Opprett webhook i Teams

1. Åpne Teams → velg kanalen du vil bruke (eller lag en ny, f.eks. «OpenClaw»)
2. Klikk `···` (Mer) ved siden av kanalnavn → **Connectors**
3. Søk etter **Incoming Webhook** → **Legg til** → **Konfigurer**
4. Gi den et navn: `OpenClaw`
5. Last opp logo om ønskelig → klikk **Opprett**
6. Kopier URL-en som vises

### 1.2 Legg inn URL i .env

```bash
nano .env
# Lim inn:
TEAMS_WEBHOOK_URL=https://outlook.office.com/webhook/din-url-her
```

### 1.3 Test

```bash
bash scripts/teams-notify.sh "Test" "OpenClaw er klar til bruk!"
```

Du skal se en melding dukke opp i Teams-kanalen umiddelbart.

---

## Del 2 – Teams Bot (to-veis kommandoer)

### 2.1 Registrer app i Azure

1. Gå til [portal.azure.com](https://portal.azure.com)
2. Søk etter **App registrations** → **New registration**
   - Name: `OpenClaw Bot`
   - Supported account types: **Accounts in any organizational directory** (for privat bruk: Single tenant)
   - Klikk **Register**
3. Noter **Application (client) ID** → dette er `TEAMS_BOT_APP_ID`
4. Gå til **Certificates & secrets** → **New client secret**
   - Description: `openclaw-bot`
   - Expires: 24 months
   - Klikk **Add** → noter **Value** (vises kun én gang) → dette er `TEAMS_BOT_APP_PASSWORD`

### 2.2 Opprett Azure Bot Service

1. Søk etter **Azure Bot** → **Create**
   - Bot handle: `openclaw-bot`
   - Subscription: velg din
   - Resource group: lag ny eller gjenbruk
   - Pricing tier: **F0** (gratis)
   - Microsoft App ID: **Use existing app registration** → lim inn `TEAMS_BOT_APP_ID`
2. Klikk **Review + create** → **Create**
3. Gå til ressursen → **Channels** → legg til **Microsoft Teams**

### 2.3 Eksponere bot-serveren

Bot Framework krever en HTTPS-URL. To alternativer:

**Alternativ A – ngrok (enklest for test):**
```bash
# Installer ngrok
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install ngrok

# Start tunnel (kjør i separat tmux-vindu)
ngrok http 3978
# Kopier HTTPS-URL, f.eks. https://abc123.ngrok.io
```

**Alternativ B – Caddy reverse proxy (permanent, anbefalt):**
```bash
# Krever at serveren har et domenenavn eller statisk IP
# Caddy håndterer SSL automatisk
sudo apt install caddy
# Legg til i /etc/caddy/Caddyfile:
# openclaw.dittdomene.no {
#     reverse_proxy localhost:3978
# }
```

### 2.4 Sett messaging endpoint i Azure Bot

1. Azure Bot → **Configuration**
2. **Messaging endpoint**: `https://din-url/api/messages`
3. Klikk **Apply**

### 2.5 Start boten

```bash
# Installer avhengigheter
cd scripts && npm install && cd ..

# Legg inn i .env:
TEAMS_BOT_APP_ID=din-app-id
TEAMS_BOT_APP_PASSWORD=din-client-secret
TEAMS_BOT_PORT=3978

# Start (i tmux)
node scripts/teams-bot.js
```

### 2.6 Test i Teams

Finn boten i Teams: Søk etter `OpenClaw Bot` → åpne chat → skriv `/hjelp`

Du skal se kommandolisten som svar.

---

## Feilsøking

| Problem | Løsning |
|---------|---------|
| Webhook gir 400 | Sjekk at JSON er gyldig, bruk `teams-notify.sh` ikke manuell curl |
| Bot svarer ikke | Sjekk at `teams-bot.js` kjører og at messaging endpoint er satt i Azure |
| 401 Unauthorized | Sjekk `TEAMS_BOT_APP_ID` og `TEAMS_BOT_APP_PASSWORD` i `.env` |
| ngrok-URL utløper | ngrok gratis-tier gir ny URL ved restart – bruk Alternativ B for permanet oppsett |
