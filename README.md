# openclaw-setup

Personlig AI-infrastruktur basert på [NVIDIA NemoClaw](https://github.com/NVIDIA/NemoClaw) og [OpenClaw](https://openclaw.ai) (Claude Code).

## Hva dette er

Et oppsett for å kjøre spesialiserte AI-agenter lokalt på RTX 4090 + Claude API for:

- **Aksjeportefølje** – bull/bear-analyse, posisjonsstørrelse, alternativer
- **E-post** – automatisk triage og svarforslag (Gmail, Hotmail, M365)
- **Arbeidsautomatisering** – rapporter, Slack, møtereferater

## Rask start

```bash
# 1. Klon repoet
git clone https://github.com/<ditt-brukernavn>/openclaw-setup.git
cd openclaw-setup

# 2. Kopier og fyll ut miljøvariabler
cp .env.example .env
nano .env

# 3. Kjør oppsett-script
bash scripts/setup.sh
```

## Forutsetninger

- Ubuntu 22.04+ (testet på 24.04)
- Node.js 22+
- Docker 29+
- NemoClaw v0.1.0 installert (`nemoclaw --version`)
- Claude API-nøkkel
- Perplexity Pro API-nøkkel (for aksjenyhet)
- Microsoft Teams Incoming Webhook URL (se `config/teams-setup.md`)

## Agents

| Agent | Fil | Beskrivelse |
|-------|-----|-------------|
| BullAgent | `agents/bull-agent.md` | Optimistisk case per selskap |
| BearAgent | `agents/bear-agent.md` | Pessimistisk case per selskap |
| RiskRewardAgent | `agents/risk-reward-agent.md` | Sammenstiller bull/bear, anbefaler posisjonsstørrelse |
| EmailTriageAgent | `agents/email-triage-agent.md` | Triage av Gmail, Hotmail og M365 |

## Struktur

```
openclaw-setup/
├── CLAUDE.md                   # AI-kontekst og arkitektur
├── README.md                   # Denne filen
├── .env.example                # Miljøvariabel-mal
├── agents/
│   ├── bull-agent.md
│   ├── bear-agent.md
│   ├── risk-reward-agent.md
│   └── email-triage-agent.md
├── config/
│   └── teams-setup.md          # Steg-for-steg Teams og Azure-oppsett
└── scripts/
    ├── setup.sh                # Oppsett-script
    ├── teams-notify.sh         # Send varsler til Teams via webhook
    └── teams-bot.js            # Teams Bot-server (to-veis kommandoer)
```

## Hardware

| Ressurs | Verdi |
|---------|-------|
| GPU | RTX 4090 24 GB VRAM |
| RAM | 64 GB |
| OS | Ubuntu 24.04 |
| Lokal modell | Qwen3 14B → 32B (ny disk) |
| Cloud | Claude API Sonnet |
